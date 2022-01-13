#!/bin/bash

#Variable to locate provisioning log file
logfile="/Library/HashiCorpIT/Logs/provisioning.log"
output="False"

#check to see if Provisioning Complete Log is present on device
if [ -f "$logfile" ] ; then
  #set output to True
  output="True"
fi

echo "<result>$output</result>"

exit 0
