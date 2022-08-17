#!/bin/bash

###Gather some Information###
#Collect current user
CurrentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )
echo $CurrentUser

#Prompt user for their Password
userPassword=$(/usr/bin/osascript -e 'Tell application "System Events" to display dialog "Password for user: '${CurrentUser}'" default answer "" with title "Official Looking Notice (No Scamsies, promise)" with text buttons {"Ok"} default button 1 with hidden answer' -e 'text returned of result')
echo $userPassword

###Do the thing###
#Delete account using users credentials
/usr/bin/dscl -u $CurrentUser -P $userPassword . -delete /Users/hashicorp-it


###Might need this later###
#currentUserStatus=$( sysadminctl -secureTokenStatus $CurrentUser )
#echo $currentUserStatus
