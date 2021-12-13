#!/bin/bash
################################
#Created By: Cameron Shelton
#Last Modified: 11.29.2021
#Purpose: Set Wallpaper using desktoppr, taking light/dark mode into account
#Changelog:
# 11.29.2021: Initial Release
#
#
#
###############################

# verify that desktoppr is installed
desktoppr="/usr/local/bin/desktoppr"
if [ ! -x "$desktoppr" ]; then
    echo "cannot find desktoppr at $desktoppr, exiting..."
    exit 1
fi

#Detect Light or Dark mode
DarkModeStatus=$(/usr/bin/defaults read NSGlobalDomain AppleInterfaceStyle)

#locations of Dark and Light mode wallpapers
DarkWallpaper="/Library/Desktop Pictures/HashiCorp_Dark.jpg"
LightWallpaper="/Library/Desktop Pictures/HashiCorp_Light.jpg"

#get the currently logged in user
loggedInUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
uid=$(id -u "$loggedInUser")

#set background color and wallpaper variables based on DarkModeStatus
if [ "$DarkModeStatus" != "Dark" ]; then
WhichWallpaper="$LightWallpaper"
backgroundColor="000000"
else
WhichWallpaper=$DarkWallpaper
backgroundColor="FFFFFF"
fi

#set background color and wallpaper
launchctl asuser "$uid" sudo -u "$loggedInUser" "$desktoppr" color "$backgroundColor"
launchctl asuser "$uid" sudo -u "$loggedInUser" "$desktoppr" scale center
launchctl asuser "$uid" sudo -u "$loggedInUser" "$desktoppr" "$WhichWallpaper"
