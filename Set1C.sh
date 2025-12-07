#!/bin/bash
# set -e

dow1C() { 
  USERNAME="Trogdin"
  PASSWORD="6gDek----JsO"
  VERSION="8.3.27.1859"
  
  SRC=$(curl -c /tmp/cookies.txt -s -L https://releases.1c.ru)
  ACTION=$(echo "$SRC" | grep -oP '(?<=form method="post" id="loginForm" action=")[^"]+(?=")')
  EXECUTION=$(echo "$SRC" | grep -oP '(?<=input type="hidden" name="execution" value=")[^"]+(?=")')
  
  curl -s -L \
      -o /dev/null \
      -b /tmp/cookies.txt \
      -c /tmp/cookies.txt \
      --data-urlencode "inviteCode=" \
      --data-urlencode "execution=$EXECUTION" \
      --data-urlencode "_eventId=submit" \
      --data-urlencode "username=$USERNAME" \
      --data-urlencode "password=$PASSWORD" \
      https://login.1c.ru"$ACTION"
  
  if ! grep -q "TGC" /tmp/cookies.txt
  then
      echo "Auth failed"
      exit 1
  fi
  
  CLIENTLINK=$(curl -s -G \
      -b /tmp/cookies.txt \
      --data-urlencode "nick=Platform83" \
      --data-urlencode "ver=$VERSION" \
      --data-urlencode "path=Platform\\${VERSION//./_}\\client_${VERSION//./_}.deb64.zip" \
      https://releases.1c.ru/version_file | grep -oP '(?<=a href=")[^"]+(?=">Скачать дистрибутив<)')
      
  echo 'CLIENTLINK:' \'$CLIENTLINK\'
  
  SERVERINK=$(curl -s -G \
      -b /tmp/cookies.txt \
      --data-urlencode "nick=Platform83" \
      --data-urlencode "ver=$VERSION" \
      --data-urlencode "path=Platform\\${VERSION//./_}\\deb64_${VERSION//./_}.zip" \
      https://releases.1c.ru/version_file | grep -oP '(?<=a href=")[^"]+(?=">Скачать дистрибутив<)')
      
  echo 'SERVERINK:' \'$SERVERINK\'
  
  PLATFORMLINK=$(curl -s -G \
      -b /tmp/cookies.txt \
      --data-urlencode "nick=Platform83" \
      --data-urlencode "ver=$VERSION" \
      --data-urlencode "path=Platform\\${VERSION//./_}\\server64_${VERSION//./_}.zip" \
      https://releases.1c.ru/version_file | grep -oP '(?<=a href=")[^"]+(?=">Скачать дистрибутив<)')
      
  echo 'PLATFORMLINK:' \'$PLATFORMLINK\'
  
  mkdir -p dist
  
  echo 'client:'
  curl --progress-bar --fail -b /tmp/cookies.txt -o dist/client.zip -L "$CLIENTLINK"
  echo 'server:'
  curl --progress-bar --fail -b /tmp/cookies.txt -o dist/server.zip -L "$SERVERINK"
  # echo 'platform:'
  # curl --progress-bar --fail -b /tmp/cookies.txt -o dist/platform.zip -L "$PLATFORMLINK"
  
  rm /tmp/cookies.txt 
}
unz1C() { 
  sudo apt update && sudo apt install -y unzip
  unzip -o ./dist/client.zip -d ./dist/client
  unzip -o ./dist/server.zip -d ./dist/server
  # unzip -o ./dist/platform.zip -d ./dist/platform
}
set1C() { 
  echo "set1C..."; 
}

main() {
    if [ "$1" = "dow1C" ]; then
        print_one
    elif [ "$1" = "unz1C" ]; then
        print_two
    elif [ "$1" = "set1C" ]; then
        print_three
    elif [ "$1" = "all" ]; then
        dow1C
        unz1C
        set1C
    else
        echo "dow1C, unz1C, set1C, all"
        exit 1
    fi
}

main "$1"
