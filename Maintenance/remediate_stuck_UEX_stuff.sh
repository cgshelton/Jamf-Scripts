#!/bin/bash
#package name, matching name in UEX Policy in jamf
    packageName="$4"
    #packageName="Adobe Acrobat Reader DC"
#transform appName from above to shortened version used by the rest of the script
    packageShortName=$(echo "$packageName" | sed 's/ //g')
#path to LaunchDaemon file we are manipulating
    daemonPath="/Library/LaunchDaemons/com.uex.$packageShortName.plist"
#path to plist we are manipulating
    plistPath="/Library/HashicorpIT/UEX/defer_jss/$packageShortName.plist"
#if daemon is running, this variable will not be empty
    daemonStatus="launchctl list | grep $packageShortName"

#clean up Launch Daemon
if [[ -e $daemonPath ]];
then
    #if launch daemon is running, unload it
    if [[ -z "$daemonStatus" ]];
    then 
        launchctl unload "$daemonPath"
        echo "unloaded LaunchDaemon"
    fi

    #if launchDaemon is found delete it
    rm "$daemonPath"
    echo "removed LaunchDaemon"
fi

#if $appName plist is found, delete it
if [[ -e $plistPath ]];
then
    rm "$plistPath"
    echo "removed deferral plist"
fi