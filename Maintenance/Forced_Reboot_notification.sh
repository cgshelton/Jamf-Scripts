
JAMFHELPER='/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper'
TITLE="HashiCorp IT Security Message"
HEADING="Password Change Required"
ICON="/Library/HashicorpIT/Logos/HashiCorp_Logomark_Black_zoomed.png"
DATE="June 30, 2024"
DESC="Due to Hashicorp's new endpoint password policy, Your computer will reboot in order to initiate a password change.

When your computer reboots, you will be required to set a new password. 

Your computer will reboot in approximately 5 minutes, please save any work and quit any open applications. 

Questions? Please contact the Hashicorp ServiceDesk.
"

#show popup using variables above. This window features 1 button which closes the window. 
RESULT=$("$JAMFHELPER" -windowType hud -lockHUD -title "$TITLE" -heading "$HEADING" -description "$DESC" -icon "$ICON" -button1 "Acknowledge" -cancelButton 1) &

#report back to Jamf that we displayed the popup to the user
echo "Displayed Password Change popup to user"
exit 0