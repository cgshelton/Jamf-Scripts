#!/bin/bash

#determine currently logged-in user
username=$(/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }')

#calculate date user last changed their password
lastChangeDate=$(date -r $(sudo dscl . -read /Users/$username accountPolicyData | tail -n +2 | plutil -extract passwordLastSetTime xml1 -o - -- - | sed -n "s/<real>\([0-9]*\).*/\1/p") "+%Y-%m-%d %H:%M:%S")

#report back
echo "<result>$lastChangeDate</result>"

