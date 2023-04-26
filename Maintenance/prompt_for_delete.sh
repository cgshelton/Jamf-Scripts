#!/bin/bash

#Author: Cameron Shelton
#Date: 8.26.22
#About: This script checks for the presence of the hashicorp-it account and prompts the user to remove it if found

#check local directory for presence of hashicorp-it account
if [[ $(/usr/bin/dscl . list /Users | grep hashicorp-it ) == "" ]]; then
	echo "hashicorp-it account not present, no action needed"
exit 0
fi

#unhide account, hopefully
/usr/bin/dscl . create /Users/hashicorp-it IsHidden 0

#get logged in user for launching app under user
LOGGED_IN_USER=$(stat -f%Su /dev/console)
LOGGED_IN_UID=$(id -u "$LOGGED_IN_USER")

#check for hashi logo
if [[ -e /Library/HashiCorpIT/Logos/HashiCorp_Logomark_White_zoomed.png ]]; then
  ICON="/Library/HashiCorpIT/Logos/HashiCorp_Logomark_White_zoomed.png"
else
  #if running script from jamf, jamf policy -event hashiBranding
  ICON="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns"
fi

	#Define variables to fill Jamf Helper popup with
	JAMFHELPER='/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper'
	TITLE="HashiCorp IT"
	HEADING="***ACTION REQUIRED***"
	DESC="HashiCorp IT needs your assistance to remove an old account for security purposes. Please refer to the post named 'Hashicorp Account Removal' in the #hashicorp-announcements channel for more information

	     To remove the account:
	     1) Click 'Continue' to open System Preferences
	     2) Click the lock in the lower left & provide your password
	     3) Click 'hashicorp-it', click the minus button
	     4) Choose 'delete the home folder', then click 'Delete User'

	Your assistance is greatly appreciated!

	For help, please email helpdesk@hashicorp.com"


#Loop showing the popup until the user clicks 'OK'
#while [[ "$RESULT" != 0 ]]; do

#show popup
RESULT=$("$JAMFHELPER" -windowType hud -lockHUD -title "$TITLE" -heading "$HEADING" -description "$DESC" -button1 "Continue" -defaultButton 1 -icon "$ICON")

#check what the user clicked, do stuff
	if [[ "$RESULT" == 0 ]]; then
		# Open System Preferences Accounts pane as planned
		/usr/bin/open -b com.apple.systempreferences /System/Library/PreferencePanes/Accounts.prefPane

	elif [[ "$RESULT" == 2 ]]; then
		#open link to slack post announcing the popup
		/bin/launchctl asuser "$LOGGED_IN_UID" sudo -iu "$LOGGED_IN_USER" open https://google.com #replace url with some informative doc
	fi
#done
echo "Displayed prompt to user..."
exit 0
