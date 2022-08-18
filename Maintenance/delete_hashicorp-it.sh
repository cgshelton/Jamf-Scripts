#!/bin/bash
logfile="/Library/HashiCorpIT/Logs/account_delete.log"

#look for log file
if [ ! -f "$logfile" ] ; then
	#if file does not exist, create it
	touch "$logfile"
fi

###Prep variables for Logging###
#Grab today's Date
today=$(date)
#spacer, to make the log file look pretty
spacer=" : "
#status, to report what happened
status=""
#entry="$today$spacer$status"
#echo "$entry" >> "$logfile"

###### Collect User Credentials to perform the action #####

#Collect current username
CurrentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )

#build and post to logfile
status="Currently logged on user is $CurrentUser"
entry="$today$spacer$status"
echo "$entry" >> "$logfile"

######## Before prompting user for password, check to see if we can successfully remove the account #########

###Validation Checks before we can delete the account###

#check local directory for presence of hashicorp-it account
#accountStatus=$( /usr/bin/dscl . -read /Users/hashicorp-it )
if [[ $(dscl . list /Users | grep hashicorp-it) == "" ]]; then
	accountPresent="No"
	status="hashicorp-it account not present, no action needed"
	entry="$today$spacer$status"
	echo "$entry" >> "$logfile"
	cat "$logfile"
	exit 0
else
	accountStatus="Yes"
	status="hashicorp-it account present, needs to be deleted"
	entry="$today$spacer$status"
	echo "$entry" >> "$logfile"
fi

#confirm currently logged-in user has a secure token to perform the action we need
#currentUserStatus=$( sysadminctl -secureTokenStatus $CurrentUser )
currentUserStatus=$( dscl . -read /Users/$CurrentUser AuthenticationAuthority | grep -o SecureToken )

#check if $currentUserStatus is empty, if so, account has no SecureToken
if [ -z $currentUserStatus ]; then
	tokenPresent="No"
	status="account does not have a SecureToken, manual intervention required"
	entry="$today$spacer$status"
	echo "$entry" >> "$logfile"
	cat "$logfile"
	exit 0
else
	tokenPresent="Yes"
	status="account has a SecureToken, can proceed with account deletion(if needed)"
	entry="$today$spacer$status"
	echo "$entry" >> "$logfile"
fi


#Prompt user for their Password
userPassword=$(/usr/bin/osascript<<END
application "System Events"
activate
set the answer to text returned of (display dialog "Please provide your password:" default answer "" with title "HashiCorp IT Security Action" with hidden answer buttons {"Continue"} default button 1)
END
)

#If users closes prompt & does not enter a password, log an error
if [ -z $userPassword ]; then
status="User did not enter a password"
exit 1
else
status="User provided a password"
fi

#build and post to logfile
entry="$today$spacer$status"
echo "$entry" >> "$logfile"


###Carry out account deletion action###

#Delete account using dscl
/usr/bin/dscl -u $CurrentUser -P $userPassword . -delete /Users/hashicorp-it
#build and post to logfile
status="deleting hashicorp-it account..."
entry="$today$spacer$status"
echo "$entry" >> "$logfile"

#Delete hashicorp-it home folder
/bin/rm -rf /Users/hashicorp-it/
status="deleting hashicorp-it home folder..."
#build and post to logfile
entry="$today$spacer$status"
echo "$entry" >> "$logfile"

#post logfile to console & exit
cat "$logfile"
exit 0

###Final validation###
#status="Performing final validation check"
#entry="$today$spacer$status"
#echo "$entry" >> "$logfile"

#if [ $tokenPresent == "No" ]; then
#	#build and post to logfile
#	status="Unable to delete account, exiting..."
#	entry="$today$spacer$status"
#	echo "$entry" >> "$logfile"
#	#post logfile to jamf logs
#	cat "$logfile"
#	#stop processing commands
#	exit 0
#fi
