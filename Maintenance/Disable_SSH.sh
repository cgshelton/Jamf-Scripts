#!/bin/bash

#defining variables for cheking the status of the screen sharing service
ScreenSharingStatus=$(/usr/bin/sudo /bin/launchctl list com.apple.screensharing)
ExpectedScreenSharingResult=" Could not find service \"com.apple.screensharing\" in domain for system"

#defining variables for cheking the status of the SSH service
SSH_Status=$(/usr/bin/sudo /usr/sbin/systemsetup -getremotelogin)
ExpectedSSHResult="Remote Login: Off"



#if statement to check if screen sharing is enabled
#This check doesn't work currently. We still get the intended outcome, however.
if [ "$ScreenSharingStatus" != "$ExpectedScreenSharingResult" ]
then
  #Set output variable to notify that Screen Sharing will be turned of, then run command to turn it off
  ScreenSharingOutput="Turning off Screen Sharing"
  /usr/bin/sudo /bin/launchctl unload -w /System/Library/LaunchDaemons/com.apple.screensharing.plist
else
  #Set output variable to notify that Screen Sharing is already disabled
  ScreenSharingOutput="Screen Sharing is already disabled"
fi

#if statement to check if SSH is enabled
if [ "$SSH_Status" != "$ExpectedSSHResult" ]
then
#Set output variable to notify that SSH will be turned of, then run command to turn it off
 SSHOutput="Turning off SSH"
 /usr/bin/sudo /usr/sbin/systemsetup -f -setremotelogin off
else
  #Set output variable to notify that SSH is already disabled
  SSHOutput="SSH Is already disabled"
fi

#Report back on what was done
echo $ScreenSharingOutput
echo $SSHOutput

exit 0
