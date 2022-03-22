#!/usr/bin/env bash


#Stole this code from Jamf's extension attribute
PATH_EXPR=/Library/Java/JavaVirtualMachines/jdk-17*.jdk/Contents/Info.plist
KEY="CFBundleShortVersionString"

RESULTS=()
IFS=$'\n'
for PLIST in ${PATH_EXPR}; do
	RESULTS+=( $(/usr/bin/defaults read "${PLIST}" "${KEY}" 2>/dev/null) )
done
RESULTS=( $(/usr/bin/sort -V -r <<< "${RESULTS[*]}") )
unset IFS



#Combine results from Jamf's code with our known info about the Install Receipt, this will most likely fail if there are multiple installs
Result="Exception"

InstallReceipt="/var/db/receipts/com.oracle.jdk-$RESULTS.plist"
if [ -e "$InstallReceipt" ] ; then
  InstallDate=$(/usr/bin/defaults read $InstallReceipt InstallDate)
  Result="$InstallDate"
else
  Result="Not Installed"
fi

  echo "<Result>$Result</Result>"

exit 0
