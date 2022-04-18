
#!/usr/bin/env bash

#######################################################################################
# Collects information to determine which version of the Java 17 SE JDK is installed  #
# and returns that version back.  Builds the result as FEATURE.INTERIM.UPDATE         #
#######################################################################################

PATH_EXPR=/Library/Java/JavaVirtualMachines/jdk-17*.jdk/Contents/Info.plist
KEY="CFBundleShortVersionString"

RESULTS=()
IFS=$'\n'
for PLIST in ${PATH_EXPR}; do
	RESULTS+=( $(/usr/bin/defaults read "${PLIST}" "${KEY}" 2>/dev/null) )
done
RESULTS=( $(/usr/bin/sort -V -r <<< "${RESULTS[*]}") )
unset IFS

if [[ ${#RESULTS[@]} -eq 0 ]]; then
	/bin/echo "<result>Not Installed</result>"
else
/bin/echo "<result>${RESULTS[0]}</result>"
fi
