#!/bin/bash

###### Collect User Credentials to perform the action #####

#Collect current username
CurrentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )
#echo $CurrentUser

#Prompt user for their Password
userPassword=$(/usr/bin/osascript<<END
application "System Events"
activate
set the answer to text returned of (display dialog "Please provide your password:" default answer "" with title "HashiCorp IT Security Action" with hidden answer buttons {"Continue"} default button 1)
END
)

#If users closes prompt & does not enter a password, return an error to Jamf console
if [ -z $userPassword ]
then
echo "ERROR: User did not enter a password"
exit 1
fi

###Validation Checks before we can delete the account###

#check local directory for presence of hashicorp-it account
accountStatus=$( /usr/bin/dscl . -read /Users/hashicorp-it )

#confirm currently logged-in user has a secure token to perform the action we need
currentUserStatus=$( sysadminctl -secureTokenStatus $CurrentUser )



###Carry out account deletion action###

#Delete account using dscl
/usr/bin/dscl -u $CurrentUser -P $userPassword . -delete /Users/hashicorp-it

#Delete hashicorp-it home folder
/bin/rm -f /Users/hashicorp-it

exit 0 #Exit as successful
