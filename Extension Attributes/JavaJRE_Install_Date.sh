#!/usr/bin/env bash

InstallReceipt="/var/db/receipts/com.oracle.jre.plist"
#Check and see if Java Plugin is installed
if [ -e /Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin/Contents/Home/bin/java ] ; then
  #if so, check for install receipt & read data from it
  if [ -f $InstallReceipt ] ; then
  #Key that stores InstallDate
  Result=$(/usr/bin/defaults read $InstallReceipt InstallDate)
fi
else
Result="Not Installed"
fi

echo "<Result>$Result</Result>"

exit 0
