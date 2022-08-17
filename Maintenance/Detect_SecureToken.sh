#!/bin/bash

result=""
userList=$(dscl . list /Users name | awk '{if (substr($1,1,1) != "_") print $1}')
for user in $userList; do
  enabledUser=$(sysadminctl -secureTokenStatus $user  2>&1  | awk -v user="$user" '{if ($7=="ENABLED") print user}')
  result=( "${result[@]}" "$enabledUser" )
done

if [ ${#result[@]} -eq 0 ]; then
  result="None"
fi

echo "<result>${result[*]}</result>"

exit 0
