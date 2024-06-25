onboarding_JSON='{
   "pages":[
      {
         "title":"Hashicorp Onboarding",
         "subtitle":"Welcome!",
         "body":"Something Something install software blargedy blarg",
         "mediaType":"image",
         "mediaPayload":"/Users/Shared/NA_pic.jpg"
      },
      {
         "title":"Play that video",
         "subtitle":"Look at these cool dudes",
         "body":"This is some sweet introduction",
         "mediaType":"video",
         "mediaPayload":"/Users/Shared/NA_vid.mov"
      }
'

#put JSON where we need it to be
hashi_dir="/Library/HashiCorpIT/"
bin_dir="/Library/HashiCorpIT/bin/"
JSON_Path="/Library/HashiCorpIT/bin/onboarding.JSON"
#Create required folder structure
if ! [[ -e "$hashi_dir" ]]; then /bin/mkdir -p "$hashi_dir" && /usr/bin/chflags hidden "$hashi_dir"; fi
if ! [[ -e "$bin_dir" ]]; then /bin/mkdir -p "$bin_dir"; fi
echo $onboarding_JSON >> $JSON_Path