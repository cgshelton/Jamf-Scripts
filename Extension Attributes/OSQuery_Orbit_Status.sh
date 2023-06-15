


#check to see if Orbit is present
if [ -f "/Library/LaunchDaemons/com.fleetdm.orbit.plist" ]
then
    echo "Installed"
else
    echo "Not Installed"
fi

Exit 0