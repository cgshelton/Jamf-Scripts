#!/bin/bash

#Author: Cameron Shelton
#Date: 10.20.22
#About: This script locks a device down and notifes the user that their device is EOL and needs to be updated.
# NOTE: If this script is ran on a device, it must be shut down and restarted before it will be functional again.


#check for hashi logo
if [[ -e /Library/HashiCorpIT/Logos/HashiCorp_Logomark_White_zoomed.png ]]; then
  ICON="/Library/HashiCorpIT/Logos/HashiCorp_Logomark_White_zoomed.png"
else
  #if running script from jamf, jamf policy -event hashiBranding
  #ICON="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns"
  /usr/local/bin/jamf policy -event hashiBranding
  ICON="/Library/HashiCorpIT/Logos/HashiCorp_Logomark_White_zoomed.png"
fi

#Define variables to fill Jamf Helper popup with
JAMFHELPER='/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper'
TITLE="HashiCorp IT"
HEADING="THIS DEVICE HAS REACHED END OF LIFE"
DESC="As of October 24, 2022, MacOS Mojave is no longer supported by our security software. In order to continue using this device, you must upgrade your Operating System.

Please contact the Help Desk for further instructions."

#show popup
RESULT=$("$JAMFHELPER" -windowType fs -lockHUD -title "$TITLE" -heading "$HEADING" -description "$DESC" -icon "$ICON")

exit 0
