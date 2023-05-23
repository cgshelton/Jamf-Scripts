#!/bin/bash

#Author: Cameron Shelton
#Date: 5.18.23
#About: This script nags a user to upgrade their MacOS version at a Jamf-determined interval

#check for hashi logo
if [[ -e /Library/HashiCorpIT/Logos/HashiCorp_Logomark_White_zoomed.png ]]; then
  ICON="/Library/HashiCorpIT/Logos/HashiCorp_Logomark_White_zoomed.png"
else
  #if running script from jamf, jamf policy -event hashiBranding
  #ICON="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns"
  /usr/local/bin/jamf policy -event hashiBranding
  ICON="/Library/HashiCorpIT/Logos/HashiCorp_Logomark_White_zoomed.png"
fi

###Final, pre-poup check for OS version###
#This helps us account for devices that have upgraded but have not updated ther inventory yet. 

#Pull OS version and truncate to the first 2 characters, giving us a Major Version number only
OSVERS=$(/usr/bin/sw_vers -productVersion | cut -c1-2)

#If $OSVERS is 13, we are running Ventura, tell this to Jamf and Exit
if [ "$OSVERS" = "13" ]
then
echo "Device is now running Ventura, exiting..."
exit 0
fi

#If $OSVERS is 12, we are running Monterey, tell this to Jamf and Exit
if [ "$OSVERS" = "12" ]
then
echo "Device is now running Monterey, exiting..."
exit 0
fi

###After OS Version Checks, display popup to user###

#Define variables to fill Jamf Helper popup with
JAMFHELPER='/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper'
TITLE="HashiCorp IT Security Message"
HEADING="Unsupported Operating System Detected"
DESC="IT has detected that this device is running an unsupported version of macOS, which could leave your device vulnerable or inoperable due to incompatibilities or security risks.  Please upgrade the OS on this device to the latest version available as soon as possible.

Follow these instructions to upgrade your device to MacOS Monterey or Ventura: 

1) From the Apple menu in the top-left corner of your screen, click System Preferences. 

2) Click Software Update in the window that appears. Software Update will check for new software. 

3) Click the button to install any available upgrades & updates. Multiple reboots may be required.

If needed, please contact the Help Desk for further assistance.

"

#show popup using variables above. This window features 1 button which closes the window. 
RESULT=$("$JAMFHELPER" -windowType hud -lockHUD -title "$TITLE" -heading "$HEADING" -description "$DESC" -icon "$ICON" -button1 "Dismiss" -cancelbutton 1) &

#report back to Jamf that we displayed the popup to the user
echo "Displayed unsupported OS popup to user"

exit 0