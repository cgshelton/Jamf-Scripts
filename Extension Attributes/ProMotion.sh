#!/bin/sh

# Check if the Refresh Rate is set to ProMotion for MacBook Pro 14 or 16 inch with Apple Silicon. We need to know this because of a bug when updating to macOS Ventura 13.6. If the Internal Display is set to something else than ProMotion (120 Hertz) the update to macOS 13.6 can cause a boot loop and won't return a login window.

modelNumber="$(/usr/sbin/system_profiler SPHardwareDataType | grep "Model Identifier:" | awk '{print $3}')"
statusAppleClamshellState=$( ioreg -r -k AppleClamshellState -d 1 | grep AppleClamshellState | head -1 )
statusProMotionInternalDisplay=$( osascript -l 'JavaScript' -e 'ObjC.import("AppKit"); $.NSApplication.sharedApplication; for (const thisScreen of $.NSScreen.screens.js) { if ($.CGDisplayIsBuiltin(thisScreen.deviceDescription.js.NSScreenNumber.js)) { thisScreen.maximumFramesPerSecond; break } }' )

if [[ "$modelNumber" == "MacBookPro18,1" || "$modelNumber" == "MacBookPro18,2" || "$modelNumber" == "MacBookPro18,3" || "$modelNumber" == "MacBookPro18,4" || "$modelNumber" == "Mac14,5" || "$modelNumber" == "Mac14,6" || "$modelNumber" == "Mac14,9" || "$modelNumber" == "Mac14,10"   ]]; then
	if [[ $statusAppleClamshellState =~ "= No" ]]; then
		if [[ $statusProMotionInternalDisplay = 120 ]]; then
			echo "<result>enabled</result>"
		elif [[ $statusProMotionInternalDisplay != 120 ]]; then
			echo "<result>disabled</result>"
		fi
	elif [[ $statusAppleClamshellState =~ "= Yes" ]]; then
		echo "<result>clamshell</result>"
	fi
else
	echo "<result>hardware not applicable</result>"
fi