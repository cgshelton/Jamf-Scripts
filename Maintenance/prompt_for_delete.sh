#!/bin/bash

#Author: 
#Date: 
#About: This script checks for the presence of the hashicorp-it account and prompts the user to remove it if found

#check local directory for presence of hashicorp-it account
if [[ $(/usr/bin/dscl . list /Users | grep hashicorp-it ) == "" ]]; then
	echo "hashicorp-it account not present, no action needed"
#exit 0
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
DESC="HashiCorp IT needs your assistance to remove an old account for security purposes. 

     To remove the account:
     1) Click 'Continue' to open System Preferences
     2) Click the lock in the lower left & provide your password
     3) Click 'Hashicorp-it', click the minus button
     4) Choose 'delete the home folder', then click 'Delete User'

Your assistance is greatly appreciated! 

For help, please email helpdesk@hashicorp.com"

#Display popup & collect what the user did (probably just clicked OK)
RESULT=$("$JAMFHELPER" -windowType hud -lockHUD -title "$TITLE" -heading "$HEADING" -description "$DESC" -button1 "Continue" -button2 "More Info" -defaultButton 1 -icon "$ICON")

#If's to check the $RESULT variable to see what the user did, and take some action. 
if [[ "$RESULT" == 0 ]]; then
    # do button1 stuff
    # echo "OK was pressed!"
    /usr/bin/open -b com.apple.systempreferences /System/Library/PreferencePanes/Accounts.prefPane
    exit 0
elif [[ "$RESULT" == 2 ]]; then
#    # do button2 stuff
  /bin/launchctl asuser "$LOGGED_IN_UID" sudo -iu "$LOGGED_IN_USER" open https://google.com #replace url with some informative doc
fi

exit 0
