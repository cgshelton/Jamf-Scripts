#!/bin/bash

if [ -e /Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin/Contents/Home/bin/java ]; then
    java_version=`/Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin/Contents/Home/bin/java -version 2>&1 | head -n 1 | cut -d\" -f 2`
    echo "<result>$java_version</result>"
else
    echo "<result>Not Installed</result>"
fi
exit 0
