#!/bin/bash

#Author: Cameron Shelton
#Date: 4.25.23
#About: This script nags a user to re-enable SIP at a Jamf-determined interval. 


#check for hashi logo
if [[ -e /Library/HashiCorpIT/Logos/HashiCorp_Logomark_White_zoomed.png ]]; then
  ICON="/Library/HashiCorpIT/Logos/HashiCorp_Logomark_White_zoomed.png"
else
  #if running script from jamf, jamf policy -event hashiBranding
  #ICON="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns"
  /usr/local/bin/jamf policy -event hashiBranding
  ICON="/Library/HashiCorpIT/Logos/HashiCorp_Logomark_White_zoomed.png"
fi

#Final, pre-poup check for OS version
#This helps us account for devices that have upgraded but have not updated ther inventory yet. 





 #Define variables to fill Jamf Helper popup with
JAMFHELPER='/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper'
TITLE="HashiCorp IT Security Message"
HEADING="Unsupported Operating System Detected"
DESC="IT has detected that this device is running an unsupported version of macOS, which could leave your device vulnerable or inoperable due to incompatibilities or security risks. 

Please upgrade the OS on this device to the latest version available as soon as possible.

Follow these instructions to upgrade your device: 

1)   From the Apple menu in the top-left corner of your screen, choose 
     SYSTEM SETTINGS or SYSTEM PREFERENCES, depending on your OS version. 

2a)  If you chose SYSTEM SETTINGS: click General on the left side of the window. 
      Then click Software Update on the right.

2b)  If you chose SYSTEM PREFERENCES: click Software Update in the window.

3)  Software Update then checks for new software. Click the button to install updates. 

If needed, please contact the Help Desk for further assistance.
"

#show popup
RESULT=$("$JAMFHELPER" -windowType hud -lockHUD -title "$TITLE" -heading "$HEADING" -description "$DESC" -icon "$ICON" -button1 "Dismiss" -cancelbutton 1) &
echo "Displayed unsupported OS popup to user"


exit 0
