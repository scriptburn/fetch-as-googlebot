#!/usr/bin/bash



SUB_0=("APIs-Google" "APIs-Google (+https://developers.google.com/webmasters/APIs-Google.html)")
SUB_1=("AdSense" "Mediapartners-Google")
SUB_2=("AdsBot-Mobile-Web-Android"  "Mozilla/5.0 (Linux; Android 5.0; SM-G920A) AppleWebKit (KHTML, like Gecko) Chrome Mobile Safari (compatible; AdsBot-Google-Mobile; +http://www.google.com/mobile/adsbot.html)")
SUB_3=("AdsBot-Mobile-Web" "Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1 (compatible; AdsBot-Google-Mobile; +http://www.google.com/mobile/adsbot.html)")

SUB_4=("Googlebot-Images" "Googlebot-Image/1.0")
SUB_5=("Googlebot-News" "Googlebot-News")
SUB_6=("Googlebot-Video" "Googlebot-Video/1.0")
SUB_7=("Googlebot-Desktop-1" "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)")
SUB_8=("Googlebot-Desktop-2" "Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; Googlebot/2.1; +http://www.google.com/bot.html) Safari/537.36")

SUB_9=("Googlebot-Desktop-3" "Googlebot/2.1 (+http://www.google.com/bot.html)")
SUB_10=("Googlebot-Smartphone" "Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.96 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)")

SUB_11=("Mobile-AdSense" "compatible; Mediapartners-Google/2.1; +http://www.google.com/bot.html")
SUB_12=("Mobile-Apps-Android" "AdsBot-Google-Mobile-Apps")

MAIN_ARRAY=(
    SUB_0[@]
    SUB_1[@]
    SUB_2[@]
    SUB_3[@]
    SUB_4[@]
    SUB_5[@]
    SUB_6[@]
    SUB_7[@]
    SUB_8[@]
    SUB_9[@]
    SUB_10[@]
    SUB_11[@]
    SUB_12[@]
)
MAIN_ARRAY=(
    SUB_0[@]
    SUB_1[@]
    
)

function make_slug()
{
  echo "$1" | iconv -t ascii//TRANSLIT | sed -r s/[^a-zA-Z0-9]+/-/g | sed -r s/^-+\|-+$//g | tr A-Z a-z

}
function join_by { local IFS="$1"; shift; echo "$*"; }

function tui_ua_check()
{

   
    INPUT_URL=$1
    CSV_OUTPUT=0
    if [[ ! -z "$2"   &&  ("$2" -eq 1   ||   "$2" != "1") ]]; then
      CSV_OUTPUT=1
    fi

    INPUT_URL_SLUG=$(make_slug $1) #create url slug to store the output html in that folder

    RAND=$(od -A n -N 5 /dev/urandom |tr -d ' ' )
    CWD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )

    OUT_FOL="$CWD"
    RANDFOL="$OUT_FOL/output/$INPUT_URL_SLUG/$RAND"; #random folder to store this urls all html output

    mkdir -p $RANDFOL

    if [ "$CSV_OUTPUT" -ne 1 ]; then
      echo -e "Output folder: \e[91m$RANDFOL\e[0m"
    fi

    POSTFIX_404=""
    FOUND_404=0;
    COUNT=${#MAIN_ARRAY[@]}
    for ((i=0; i<$COUNT; i++))
    do
        OUTPUT_ARRAY=()
        x=$((i+1))
        UA_NAME=${!MAIN_ARRAY[i]:0:1}
        UA_VALUE=${!MAIN_ARRAY[i]:1:1}

        OUTPUT_FILE="$UA_NAME"
        CMD1="curl -LsD - '$1'   -H 'user-agent: $UA_VALUE'"
        CMD2="$CMD1 >$RANDFOL/$OUTPUT_FILE.html"
        #echo $CMD2
        eval $CMD2 #run the curl command
        LIN1=$(cat "${RANDFOL}/$OUTPUT_FILE.html" | grep -b -o 'HTTP/' |  awk 'BEGIN {FS=":"}{print $1}'  | tail -1)
        HTTP_STATUS_CMD="dd skip=$LIN1  if='$RANDFOL/$OUTPUT_FILE.html' of='$RANDFOL/$OUTPUT_FILE.html_1' bs=1 2> /dev/null &&     head -1 '$RANDFOL/$OUTPUT_FILE.html_1' |  awk 'BEGIN {FS=\" \"}{print \$2}' && rm -f $RANDFOL/$OUTPUT_FILE.html_1"
        
        # && head -1 '$RANDFOL/$OUTPUT_FILE.html' |  awk 'BEGIN {FS=\" \"}{print \$2}'"
        #echo $HTTP_STATUS_CMD
        HTTP_STATUS=$(eval $HTTP_STATUS_CMD) #strip http status code from html output

        if [ "$FOUND_404" -eq 0 ] && [ "$HTTP_STATUS" != "200" ]; then
            FOUND_404=1
            POSTFIX_404="-${HTTP_STATUS}_found"
            mv "$RANDFOL/$OUTPUT_FILE.html" "$RANDFOL/$OUTPUT_FILE$POSTFIX_404.html" #rename url result html file to mark it so we know this has 404 response
            mv "$RANDFOL" "$RANDFOL$POSTFIX_404" #rename output folder to 404 so we know this folder contains atleast one 404 html
            RANDFOL="$RANDFOL$POSTFIX_404"
          fi
        if [ "$CSV_OUTPUT" -eq 1 ]; then
            OUTPUT_ARRAY+=($(echo "$RANDFOL"|base64 --wrap=0))
            OUTPUT_ARRAY+=($(echo "$POSTFIX_404"|base64 --wrap=0))
            OUTPUT_ARRAY+=($(echo "$UA_NAME" |base64 --wrap=0))
            OUTPUT_ARRAY+=($(echo "$HTTP_STATUS" |base64 --wrap=0))
            OUTPUT_ARRAY+=($(echo "$CMD1" |base64 --wrap=0))
        else
          echo -e "$x. Using UserAgent=>\e[92m$UA_NAME\e[0m ,HTTP Response code: \e[92m $HTTP_STATUS \e[0m"
          echo -e "Command used:  \e[93m$CMD1 \e[0m \n"
        fi
        
        if [ "$CSV_OUTPUT" -eq 1 ]; then
            x=$(printf ",%s" "${OUTPUT_ARRAY[@]}")
            echo "$x;"
        fi

    done
}
 tui_ua_check $1 $2 ;

 

