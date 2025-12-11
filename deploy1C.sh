#!/bin/bash
# set -e

download1C() { 
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
  
  client_link=$(curl -s -G \
      -b /tmp/cookies.txt \
      --data-urlencode "nick=Platform83" \
      --data-urlencode "ver=$VERSION" \
      --data-urlencode "path=Platform\\${VERSION//./_}\\client_${VERSION//./_}.deb64.zip" \
      https://releases.1c.ru/version_file | grep -oP '(?<=a href=")[^"]+(?=">Скачать дистрибутив<)')
      
  echo 'client_link:' \'$client_link\'
  
  server_link=$(curl -s -G \
      -b /tmp/cookies.txt \
      --data-urlencode "nick=Platform83" \
      --data-urlencode "ver=$VERSION" \
      --data-urlencode "path=Platform\\${VERSION//./_}\\deb64_${VERSION//./_}.zip" \
      https://releases.1c.ru/version_file | grep -oP '(?<=a href=")[^"]+(?=">Скачать дистрибутив<)')
      
  echo 'server_link:' \'$server_link\'
  
  platform_link=$(curl -s -G \
      -b /tmp/cookies.txt \
      --data-urlencode "nick=Platform83" \
      --data-urlencode "ver=$VERSION" \
      --data-urlencode "path=Platform\\${VERSION//./_}\\server64_${VERSION//./_}.zip" \
      https://releases.1c.ru/version_file | grep -oP '(?<=a href=")[^"]+(?=">Скачать дистрибутив<)')
      
  echo 'platform_link:' \'$platform_link\'
  
  mkdir -p dist
  
  echo 'client:'
  curl --progress-bar --fail -b /tmp/cookies.txt -o dist/client.zip -L "$client_link"
  echo 'server:'
  curl --progress-bar --fail -b /tmp/cookies.txt -o dist/server.zip -L "$server_link"
  # echo 'platform:'
  # curl --progress-bar --fail -b /tmp/cookies.txt -o dist/platform.zip -L "$platform_link"
  
  rm /tmp/cookies.txt 
}

unzip1C() { 
  sudo apt update && sudo apt install -y unzip
  unzip -o ./dist/client.zip -d ./dist/client
  unzip -o ./dist/server.zip -d ./dist/server
  # unzip -o ./dist/platform.zip -d ./dist/platform
}

install_server() {

  sudo apt update && sudo apt install -y gdebi
  
  packages_server=(
    "-common_"
    "-common-nls_"
    "-server_"
    "-server-nls_"
    "-ws_"
    "-ws-nls_"
    "-crs_"
  )
  for pkg in "${packages_server[@]}"; do
      mask=./dist/server/*${pkg}*
      sudo dpkg -i $mask
  done
  
  apt-get install libwebkitgtk-1.0-0
  apt-get -f install
}

install_client() {

  sudo apt update && sudo apt install -y gdebi
  
  packages_client=(
    "-thin-client_"
    "-thin-client-nls_"
    "-client_"
    "-client-nls_"
  )
  for pkg in "${packages_client[@]}"; do
      mask=./dist/client/*${pkg}*
      sudo dpkg -i $mask
  done
  
  # depends?
  
}
main() {
    if [ "$1" = "download1C" ]; then
        download1C
    elif [ "$1" = "unzip1C" ]; then
        unzip1C
    elif [ "$1" = "install_server" ]; then
        install_server
    elif [ "$1" = "install_client" ]; then
        install_client
    elif [ "$1" = "all" ]; then
        download1C
        unzip1C
        install_server
    else
        echo "download1C, unzip1C, install_server, install_client, all"
        exit 1
    fi
}

main "$1"
