#!/bin/bash


#Disable Screen Sharing if it is enabled
ScreenSharingStatus=$(/usr/bin/sudo /bin/launchctl list com.apple.screensharing)
ExpectedScreenSharingResult=" Could not find service \"com.apple.screensharing\" in domain for system"


#This check doesn't work currently. We still get the intended outcome, however.
if [ "$ScreenSharingStatus" = "$ExpectedScreenSharingResult" ]
then
  ScreenSharingOutput="Screen Sharing is already disabled"
else
  ScreenSharingOutput="Turning off Screen Sharing"
  /usr/bin/sudo /bin/launchctl unload -w /System/Library/LaunchDaemons/com.apple.screensharing.plist
fi

#Disable SSH if it is enabled
SSH_Status=$(/usr/bin/sudo /usr/sbin/systemsetup -getremotelogin)
ExpectedSSHResult="Remote Login: Off"
SSHOutput="SSH Is already disabled"

if [ "$SSH_Status" != "$ExpectedSSHResult" ]
then
 SSHOutput="Turning off SSH"
 /usr/bin/sudo /usr/sbin/systemsetup -f -setremotelogin off
fi

#Report back on what was done
echo $ScreenSharingOutput
echo $SSHOutput

exit 0
