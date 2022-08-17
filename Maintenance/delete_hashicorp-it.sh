#!/bin/bash

#Gather some Information
#Collect current user
CurrentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )
echo $CurrentUser
#Collect current user's UID
UIDCurrentUser=$(id -u "$CurrentUser")
echo $UIDCurrentUser
#Prompt user for their Password
userPassword=$(/usr/bin/osascript -e 'Tell application "System Events" to display dialog "Password for user: '${CurrentUser}'" default answer "" with title "Official Looking Notice (No Scamsies, promise)" with text buttons {"Ok"} default button 1 with hidden answer' -e 'text returned of result')
echo $userPassword

currentUserStatus=$( sysadminctl -secureTokenStatus $CurrentUser )
echo $currentUserStatus

/usr/bin/dscl -u $CurrentUser -P $userPassword . -delete /Users/hashicorp-it
