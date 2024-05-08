
JAMFHELPER='/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper'
TITLE="HashiCorp IT Security Message"
HEADING="Password Change Required"
ICON="/Library/HashicorpIT/Logos/HashiCorp_Logomark_Black_zoomed.png"
DATE="June 30, 2024"
DESC="Due to Hashicorp's new endpoint password policy, you will need to change your password the next time you restart your computer.

Please note that you will need to change your password even if it is already compliant with our new policy. 

Questions? Please contact the Hashicorp ServiceDesk.
"

#show popup using variables above. This window features 1 button which closes the window. 
RESULT=$("$JAMFHELPER" -windowType hud -lockHUD -title "$TITLE" -heading "$HEADING" -description "$DESC" -icon "$ICON" -button1 "Acknowledge" -cancelButton 1) &

#report back to Jamf that we displayed the popup to the user
echo "Displayed Password Change popup to user"
exit 0