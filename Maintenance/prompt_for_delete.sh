#!/bin/bash

#check local directory for presence of hashicorp-it account
if [[ $(/usr/bin/dscl . list /Users | grep hashicorp-it ) == "" ]]; then
	echo "hashicorp-it account not present, no action needed"
#exit 0
fi

#unhide account, hopefully
/usr/bin/dscl . create /Users/hashicorp-it IsHidden 0


#Define variables to fill Jamf Helper popup with
JAMFHELPER='/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper'
TITLE="ACTION REQUIRED - Hashicorp IT - ACTION REQUIRED"
DESC="To increase the security of your device, we need your assistance
removing an old account.

      Please follow these instructions:
      1) Click OK below, system preferences will open
      2) Click the lock in the lower left & provide your password
      3) Click 'Hashicorp-it' account, click the minus button
      4) Choose 'delete the home folder', and click 'Delete User'


If you have any questions or concerns, please contact us by emailing helpdesk@hashicorp.com.

Your assistance & cooperation is greatly appreciated!

-Hashicorp IT
"

#Display popup & collect what the user did (probably just clicked OK)
RESULT=$("$JAMFHELPER" -windowType utility -title "$TITLE" -description "$DESC" -button1 "OK")

#If's to check the $RESULT variable to see what the user did, and take some action. 
if [ "$RESULT" == 0 ]; then
    # do button1 stuff
    # echo "OK was pressed!"
    /usr/bin/open -b com.apple.systempreferences /System/Library/PreferencePanes/Accounts.prefPane
    exit 0

#What do if cancel was pressed, enable if you want to put the cancel button back
#elif [ "$RESULT" == 2 ]; then
#    # do button2 stuff
#    echo "Cancel was pressed!"
#    exit 1

fi
