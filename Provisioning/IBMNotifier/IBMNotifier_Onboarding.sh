#!/bin/bash

#define policies to run for onboarding
#policy_Array=("install-Rosetta" "set-ComputerName" "install-CrowdStrike" "enable-firewall" "install-OktaVerify" "install-Orbit" "install-Slack" "install-Zoom" "install-GoogleChrome" "install-GoogleDrive" "customize-wallpaper" "customize-dock-standard")
policy_Array=("install-Zoom" "install-Slack" "install-GoogleChrome") #Shortened workflow for testing
#Location of binary & HashiCorp onboarding JSON file
binary_Path="/Library/HashiCorpIT/bin/IBM Notifier.app/Contents/MacOS/IBM Notifier"
JSON_Path="/Library/HashiCorpIT/bin/onboarding.JSON"

#Look for IBM Notifer Binary, if it doesn't exist, install it


#Launch IBM Notifier in Onboarding mdoe w/ our specificed JSON file
"${binary_Path}" -type onboarding -payload "${JSON_Path}"&
#-accessory_view_type progressbar -accessory_view_payload "/percent automatic /top_message "TEST" /bottom_message "TEST" 
# loop through enrollment policies while the employee looks through the enrollment app
for policy in "${policy_Array[@]}"; do
    jamf policy -event "${policy}"
    #update percentage here?
    #can we update the content of the main window here, or in the JSON? do we even need the JSON if we're 
done

# We'll pop up a message letting them know that the system will reboot
"${binary_Path}" -type popup -title "HashiCorp Enrollment Complete!" \
-subtitle "This computer will be restarted in approximately one minute to enable FileVault. \
\n\n After logging back in check out the IBM App Store located in your dock to install additional software." \
-accessory_view_type timer -accessory_view_payload "Reboot in -- %@" -timeout 59 -main_button_label "Got it!" -always_on_top &

jamf reboot -minutes 1 -background -startTimerImmediately

exit 0

