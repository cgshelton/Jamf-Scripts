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

#final check for SIP status, in case inventory hasn't fully updated in Jamf
status=$( /usr/bin/csrutil status 2>/dev/null )
case "$status" in
# SIP is enabled
  "System Integrity Protection status: enabled.")
  finalstatus="Enabled"
  ;;
# SIP is disabled
  "System Integrity Protection status: disabled.")
  finalstatus="Disabled";;
# SIP is not supported
  "")
  finalstatus= "Not Supported";;
esac

echo "SIP is $finalstatus on this Device"

#if $finalstatus is 'Disabled', execute JamfHelper popup
if [ "$finalstatus" = "Disabled" ]
  then
    #Define variables to fill Jamf Helper popup with
    JAMFHELPER='/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper'
    TITLE="HashiCorp IT Security Message"
    HEADING="SIP is Disabled"
    DESC="SIP Is disabled on this device. To avoid disruptions to your work, please re-enable SIP as soon as possible. 

    If needed, please contact the Help Desk for further assistance "

    #show popup
    RESULT=$("$JAMFHELPER" -windowType hud -lockHUD -title "$TITLE" -heading "$HEADING" -description "$DESC" -icon "$ICON" -button1 "Dismiss" -cancelbutton 1)
fi

exit 0
