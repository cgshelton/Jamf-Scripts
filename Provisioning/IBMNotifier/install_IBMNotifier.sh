release_Version=v-3.1.0-b-110
release_Name=IBM.Notifier.zip
save_Location=/Library/HashicorpIT/bin/IBMN.zip
hashi_dir="/Library/HashiCorpIT/"
bin_dir="/Library/HashiCorpIT/bin/"

#Create required folder structure
if ! [[ -e "$hashi_dir" ]]; then /bin/mkdir -p "$hashi_dir" && /usr/bin/chflags hidden "$hashi_dir"; fi
if ! [[ -e "$bin_dir" ]]; then /bin/mkdir -p "$bin_dir"; fi

#Download Release Binary
curl -L "https://github.com/IBM/mac-ibm-notifications/releases/download/$release_Version/$release_Name" > $save_Location

#unzip release binary & delete.zip
unzip -u $save_Location -d $bin_dir
rm $save_Location