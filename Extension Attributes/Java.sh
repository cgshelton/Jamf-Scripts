#!/bin/bash

#Check to see if Java is Installed
jdk_installed=$(/usr/libexec/java_home 2>/dev/null)
result="Not Installed"

if [[ -n "$jdk_installed" ]]; then

#if Java is installed, read version info

java_version=`/Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin/Contents/Home/bin/java -version 2>&1 | head -n 1 | cut -d\" -f 2`

# If an installed JDK is detected, check to see if it's from a known vendor.

   javaJDKVendor=$(defaults read "${jdk_installed%/*}/Info" CFBundleIdentifier | grep -Eo "adoptopenjdk|amazon|apple|azul|openjdk|oracle|sap" | head -1)

   if [[ "$javaJDKVendor" = "adoptopenjdk" ]]; then
        result="AdoptOpenJDK"
   elif [[ "$javaJDKVendor" = "amazon" ]]; then
        result="Amazon"
   elif [[ "$javaJDKVendor" = "apple" ]]; then
        result="Apple"
   elif [[ "$javaJDKVendor" = "azul" ]]; then
        result="Azul"
   elif [[ "$javaJDKVendor" = "openjdk" ]]; then
        result="OpenJDK"
   elif [[ "$javaJDKVendor" = "oracle" ]]; then
        result="Oracle"
   elif [[ "$javaJDKVendor" = "sap" ]]; then
        result="SAP"
   else
        result="Unknown Vendor"
   fi
   result="Vendor:$result Version:$java_version "
fi


echo "<result>$result</result>"

exit 0
