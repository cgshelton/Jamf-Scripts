#!/bin/bash

# Date: Aug. 19, 2020
# Author: Shayna Waldman
# Updated Feb. 9, 2022
# This script is meant to check and fulfill prereqs needed to upgrade to a specified macOS

###################################
# AGENTS AND APPS TO CHECK
###################################

# test string to enter into CodeRunner arguments for local testing
#j j j Sonoma Catalina;10.15 7.01;install-crowdstrike;update-crowdstrikeTEST 1.16;install-Orbit 9.2;install-OktaVerifyTEST

IFS=';'
macos_req=( $5 )
crowdstrike=( $6 )
fleet=( $7 )
oktaVerify=( $8 )
unset IFS

os_req_name="${macos_req[0]}"
os_req_vers="${macos_req[1]}"
cs_required="${crowdstrike[0]}"
cs_trigger="${crowdstrike[1]}"
cs_update_trigger="${crowdstrike[2]}"
fleet_required="${fleet[0]}"
fleet_trigger="${fleet[1]}"
ov_required="${oktaVerify[0]}"
ov_trigger="${oktaVerify[1]}"

function cs_local(){ /Applications/Falcon.app/Contents/Resources/falconctl stats 2>/dev/null | grep version | awk '{print $2}' ; }
function fleet_local(){ /usr/local/bin/orbit --version | awk '{print $2}' ; }
function ov_local(){ defaults read /Applications/Okta\ Verify.app/Contents/Info.plist CFBundleShortVersionString ; }

###################################
# VARIABLES
###################################

#get required variables from jamf parameter arrays
macos_name="$4"
macos_name_ns=$( /bin/echo "$macos_name" | tr ' ' '_' ) #macos name without spaces

#variables for user-facing dialogs--OKAY TO CHANGE
heading="$macos_name Prerequisites           "
title="HashiCorp IT"
icon="/Library/HashiCorpIT/Logos/HashiCorp_Logomark_White_zoomed.png"
contact_us="click 'Help' below to file a Helpdesk ticket."

#paths
jamfBin="/usr/local/bin/jamf"
jhBin="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
if ! [[ -e /Library/HashiCorpIT/Logs ]]; then mkdir -p /Library/HashiCorpIT/Logs; fi
logFile="/Library/HashiCorpIT/Logs/'$macos_name_ns'_upgrade.log"
jamfBlacklist="/Library/Application Support/JAMF/.jmf_settings.json"

OSVers=$(sw_vers -productVersion)
OSMaj=$( echo "$OSVers" |awk -F\. '{print$1}' )
OSMin=$( echo "$OSVers" |awk -F\. '{print$2}' )
OSPatch=$( echo "$OSVers" |awk -F\. '{print$3}' )

###################################
# FUNCTIONS
###################################

function log(){ /bin/echo "line $BASH_LINENO: $1"| /usr/bin/tee -a "$logFile" ; }

# templates for user dialog messages
function updateAppDialog(){
	msg=$1
	clickresult=$( "$jhBin" -windowType hud -lockHUD -description "$msg" -heading "$heading" -title "$title" -icon "$icon" -button1 "Continue" -button2 "Cancel" -defaultButton 1 )
	if [[ $clickresult == 2 ]]; then
		log "User clicked cancel. Exiting."
		exit 0
	fi
}

function twoButtonDialog(){
	msg=$1
	clickresult=$( "$jhBin" -windowType hud -lockHUD -description "$msg" -heading "$heading" -title "$title" -icon "$icon" -button1 "OK" -button2 "Help" -defaultButton 1 )
	if [[ $clickresult == 2 ]]; then
		log "User clicked Help. Opening FreshService link."
		osascript -e 'tell application "System Events" to open location "https://hashicorp.freshservice.com/support/tickets/new"'
		exit 0
	fi
}

function noButtonDialog(){
	msg=$1
	"$jhBin" -windowType hud -lockHUD -description "$msg" -title "$title" -icon "$icon" &
}

function killJH(){ 
	jhPID=$(/usr/bin/pgrep -i "jamfHelper")
	/bin/kill "$jhPID"
	/usr/bin/wait "$jhPID" 2>/dev/null #kill jamfhelper without errors reported
}

function checkVersion(){ #compare local version of agent to required version, and put result in $agentStatus
	IFS=$'.'
	reqVersArr=( $1 )
	localVersArr=( $2 )
	unset IFS
	for i in "${!reqVersArr[@]}"; do #compare local to required version
		#remove leading zeros because bash thinks they're octals
		while [[ ${localVersArr[$i]} == "0"* ]]; do localVersArr[$i]="${localVersArr[$i]/0/}"; done
		while [[ ${reqVersArr[$i]} == "0"* ]]; do reqVersArr[$i]="${reqVersArr[$i]/0/}"; done
		#convert respective array index values to int vars and compare
		declare -i reqVersComp="${reqVersArr[$i]}"
		declare -i localVersComp="${localVersArr[$i]}"
		case 1 in
			$((localVersComp < reqVersComp)))agentStatus="lower" && break;;
			$((localVersComp == reqVersComp)));;
			$((localVersComp > reqVersComp)))agentStatus="higher" && break;;
												*);;
		esac
	done
	if [[ $agentStatus == "" ]]; then agentStatus="same"; fi
}

function checkAgentsAndApps(){ #check app/agent versions and update them if they don't meet required version
	name="$1"
	type="$2"
	reqVers="$3"
#	localVers="$4"
	installTrigger="$5"
	updateTrigger="$6"
	if [[ $updateTrigger == "" ]]; then updateTrigger="$installTrigger"; fi
	
	get_localVers="$( "${@:4}" )" #pass array of strings to produce a cmd, and assign the cmd output to this var
	if ! [[ "$get_localVers" =~ ^([0-9]*)(\..*|$) ]]; then #make sure local vers returns a numerical version (rather than an error)
		log "Reported version is $get_localVers. $name is not installed. Installing $name..."
		noButtonDialog "Installing $name. This will take a few minutes..."
		"$jamfBin" policy -forceNoRecon -event "$installTrigger"
		reconRequired=true
		killJH
	fi
	
	checkVersion "$reqVers" "$get_localVers"
	log "$name required version is $reqVers and installed version is $get_localVers. Installed version is $agentStatus."
	if [[ $agentStatus == "lower" ]]; then #check result of checkVersion
		log "$name needs to be updated. Updating $name..."
		reconRequired=true
		if [[ $type == "application" ]]; then
			updateAppDialog "$name must be updated for $macos_name compatibility.

Please click continue to quit and update $name."
				noButtonDialog "Updating $name. This will take a few minutes..."
				/usr/bin/pgrep "$name" | /usr/bin/xargs kill -9
			"$jamfBin" policy -forceNoRecon -event "$updateTrigger"
		elif [[ $type == "agent" ]]; then
			noButtonDialog "Updating $name. This will take a few minutes..."
			"$jamfBin" policy -forceNoRecon -event "$updateTrigger"
		fi
		sleep 5
		killJH
	fi
	agentStatus=""
	
	get_localVers="$( "${@:4}" )"
	checkVersion "$reqVers" "$get_localVers"
	if [[ $agentStatus == lower ]]; then
		log "Failed to update $name. Installed version is $get_localVers"
		twoButtonDialog "Failed to update $name. Please try again.

If this issue persists, please click 'Help' below to file a Helpdesk ticket."
		exit 1
	else
		log "$name: passed"
	fi
	agentStatus=""
}

refreshRestrictions(){
	/bin/rm -f "$jamfBlacklist" #rm jamf blacklist, since it's the only way to immediately update software restrictions
	"$jamfBin" manage
	/bin/launchctl kickstart -k system/com.apple.softwareupdated #make sure softareupdated isn't being stupid
	defaults delete /Library/Preferences/com.apple.SoftwareUpdate.plist && rm -f /Library/Preferences/com.apple.SoftwareUpdate.plist
    killall "System Preferences"
    killJH
}


###############################
# Start Script Actions
###############################

#start log
/bin/echo "" | /usr/bin/tee -a "$logFile"
log "$(date)"
log "** Start $macos_name Prereq Script **"
log "macOS version detected: $OSVers"

#macOS version check
checkVersion "$os_req_vers" "$OSVers"

if [[ $agentStatus == "same" || $agentStatus == "higher" ]]; then
	log "Minimum OS: passed"
	minOS=true
else
	log "Minimum OS: failed"
	minOS=false
fi


##CrowdStrike Check
if [[ $OSVers =~ ^10\.15 ]]; then  #only CS 6.41 req for Catalina
	cs_required="6.41.15404.0"
fi

if [[ "$OSMaj" -ge "11" ]] || [[ "$OSMaj" == "10" && "$OSMin" -ge 14 ]]; then
	checkAgentsAndApps "CrowdStrike" "agent" "$cs_required" "cs_local" "$cs_trigger" "$cs_update_trigger"
else
	log "CrowdStrike: skipping for OS $OSVers"
fi

##Other apps and agents version check
checkAgentsAndApps "Fleet Desktop" "agent" "$fleet_required" "fleet_local" "$fleet_trigger"
checkAgentsAndApps "Okta Verify" "application" "$ov_required" "ov_local" "$ov_trigger"


#UAMDM check
if [[ "$OSMaj" -ge 11 ]] || [[ "$OSMaj" == "10" && $OSMin -ge 14 ]] || [[ "$OSMaj"."$OSMin" == "10.13" && "$OSPatch" -ge 2  ]]; then
	UAMDMStatus=$(profiles status -type enrollment | /usr/bin/grep -i "User Approved")
	if [[ "$UAMDMStatus" != *"User Approved"* ]]; then
		log "Notifying user to approve UAMDM"
		twoButtonDialog 'MDM must be manually approved to upgrade this computer to $macos_name. To approve MDM:
	
1. Open System Preferences and select the "Profiles" pane.
2. Click on the "MDM Profile" and then click the "Approve..." button.
3. Once this has been completed, click "twoButtonDialog" on this pop-up.


Troubleshooting: 
If there is no "Approve" button or if there is an error when trying to approve, please $contact_us for assistance.'
		noButtonDialog "Updating our records. This will take a few minutes..."
		"$jamfBin" recon
		/bin/sleep 1
		killJH
		#error checking
		if [[ "$UAMDMStatus" != *"User Approved"* ]]; then
			twoButtonDialog "Failed to approve MDM. Please try again. If this issue persists, please click 'Help' below to file a Helpdesk ticket."
			log "MDM not approved. Status is $UAMDMStatus."
			exit 1
		fi
	else
		log "UAMDM: passed"
	fi
else
	log "UAMDM: skipping for OS $OSVers"
fi

###
# Check if the Refresh Rate is set to ProMotion for MacBook Pro 14 or 16 inch with Apple Silicon. We need to know this because of a bug when updating to macOS Ventura 13.6. If the Internal Display is set to something else than ProMotion (120 Hertz) the update to macOS 13.6 can cause a boot loop and won't return a login window.
###
#gather device model identifier, clamshell state, and ProMotion Status
modelNumber="$(/usr/sbin/system_profiler SPHardwareDataType | grep "Model Identifier:" | awk '{print $3}')"
statusAppleClamshellState=$( ioreg -r -k AppleClamshellState -d 1 | grep AppleClamshellState | head -1 )
statusProMotionInternalDisplay=$( osascript -l 'JavaScript' -e 'ObjC.import("AppKit"); $.NSApplication.sharedApplication; for (const thisScreen of $.NSScreen.screens.js) { if ($.CGDisplayIsBuiltin(thisScreen.deviceDescription.js.NSScreenNumber.js)) { thisScreen.maximumFramesPerSecond; break } }' )

#Conditional that checks the display status of the device & reports back to the user
if [[ "$modelNumber" == "MacBookPro18,1" || "$modelNumber" == "MacBookPro18,2" || "$modelNumber" == "MacBookPro18,3" || "$modelNumber" == "MacBookPro18,4" || "$modelNumber" == "Mac14,5" || "$modelNumber" == "Mac14,6" || "$modelNumber" == "Mac14,9" || "$modelNumber" == "Mac14,10"   ]]; then
	if [[ $statusAppleClamshellState =~ "= No" ]]; then
		if [[ $statusProMotionInternalDisplay = 120 ]]; then
        #Apple ProMotion is enabled & device is not in clamshell mode
			log "ProMotion Check Passed, continuing..."
		elif [[ $statusProMotionInternalDisplay != 120 ]]; then
        #Apple ProMotion is disabled, let the user know they need to turn it on to upgrade safely
			twoButtonDialog "Your device has ProMotion disabled. You will need revert your Refresh Rate to ProMotion in System Preferences -> Displays prior to upgrading. 
            
If you do not see the option available, you may need to disconnect any external monitors. "
            exit 1
		fi
	elif [[ $statusAppleClamshellState =~ "= Yes" ]]; then
        #Device is in clamshell mode, inform user that they need to open the lid on their device to upgrade safely
			twoButtonDialog "Your device is in clamshell mode, please open the screen prior to upgrading."
            exit 1
	fi
else
	log "device is not succeptible to ProMotion Bug, continuing..."
fi

#update Jamf and inform user of their options
noButtonDialog "We need to update our database. This may take a few minutes..."
if [[ $reconRequired == true ]]; then "$jamfBin" recon; fi

refreshRestrictions

###Tell user how to update
#LID=$(/usr/bin/id -u "$(/usr/sbin/scutil <<< "show State:/Users/ConsoleUser" | /usr/bin/awk '/Name :/ && ! /loginwindow/ { print $3 }')")
if $minOS; then
	twoButtonDialog "You are now ready to upgrade to $macos_name!

To start the upgrade:

1.  Click OK to open Software Update.
2.  Follow the prompts to download $macos_name.
3.  After the download, 'Install macOS $macos_name.app' will launch.
4.  Follow the prompts to install $macos_name.

Tip: Once downloaded, 'Install macOS $macos_name.app' can be found in your Applications folder in Finder.

For help, please $contact_us."
	log "User chose to OK. Launching macOS updater"
	/usr/bin/open "/System/Library/CoreServices/Software Update.app"
else
	log "Instructing user to upgrade to $os_req_name first"
	twoButtonDialog "IMPORTANT: HashiCorp IT requires macOS $os_req_name or higher to upgrade to $macos_name. 

To upgrade to $os_req_name:

1.  Click OK.
2.  The Mac App Store will open to macOS Catalina.
3.  Follow the prompts to download and install Catalina.
4.  Once complete, come back to upgrade to $macos_name.                    
					

For help, please $contact_us.
"
	log "Launching Catalina page in MAS."
	/usr/bin/open 'macappstore://apps.apple.com/ug/app/macos-catalina/id1466841314?mt=12'
fi

exit 0