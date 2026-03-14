#!/bin/bash
# set -e
authReleases1cru() { 
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

  }

downloadServer() { 

    $(authReleases1cru)

    server_link=$(curl -s -G \
        -b /tmp/cookies.txt \
        --data-urlencode "nick=Platform83" \
        --data-urlencode "ver=$VERSION" \
        --data-urlencode "path=Platform\\${VERSION//./_}\\deb64_${VERSION//./_}.zip" \
        https://releases.1c.ru/version_file | grep -oP '(?<=a href=")[^"]+(?=">Скачать дистрибутив<)')
        
    echo 'server_link:' \'$server_link\'

    mkdir -p dist

    echo 'server:'
    curl --progress-bar --fail -b /tmp/cookies.txt -o dist/server.zip -L "$server_link"
  
    rm /tmp/cookies.txt

}

downloadClient() { 
 
    $(authReleases1cru)

    client_link=$(curl -s -G \
        -b /tmp/cookies.txt \
        --data-urlencode "nick=Platform83" \
        --data-urlencode "ver=$VERSION" \
        --data-urlencode "path=Platform\\${VERSION//./_}\\client_${VERSION//./_}.deb64.zip" \
        https://releases.1c.ru/version_file | grep -oP '(?<=a href=")[^"]+(?=">Скачать дистрибутив<)')
        
    echo 'client_link:' \'$client_link\'

    mkdir -p dist
    
    echo 'client:'
    curl --progress-bar --fail -b /tmp/cookies.txt -o dist/client.zip -L "$client_link"
    
    rm /tmp/cookies.txt

}

downloadFull() { 
 
    $(authReleases1cru)

    platform_link=$(curl -s -G \
        -b /tmp/cookies.txt \
        --data-urlencode "nick=Platform83" \
        --data-urlencode "ver=$VERSION" \
        --data-urlencode "path=Platform\\${VERSION//./_}\\server64_${VERSION//./_}.zip" \
        https://releases.1c.ru/version_file | grep -oP '(?<=a href=")[^"]+(?=">Скачать дистрибутив<)')
        
    echo 'platform_link:' \'$platform_link\'
    
    mkdir -p dist
    
    echo 'platform:'
    curl --progress-bar --fail -b /tmp/cookies.txt -o dist/platform.zip -L "$platform_link"
    
    rm /tmp/cookies.txt

}

unzip1C() { 
  sudo apt update && sudo apt install -y unzip
  unzip -o ./dist/client.zip -d ./dist/client
  unzip -o ./dist/server.zip -d ./dist/server
  unzip -o ./dist/platform.zip -d ./dist/platform
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
      sudo gdebi -n $mask
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
      sudo gdebi -n $mask
  done
  
  # depends?
}

install_full() {

    sudo ./dist/platform/setup-full-${VERSION}-x86_64.run --mode unattended --enable-components \
        server,ws,server_admin,liberica_jre,desktop_icons,v8_install_deps,ru

}

main() {
    
    USERNAME="Trogdin"
    PASSWORD="6gDek----JsO"
    VERSION="8.3.27.1859"
 
    if [ "$1" = "dows" ]; then
        downloadServer
    elif [ "$1" = "dowc" ]; then
        downloadClient
    elif [ "$1" = "dowf" ]; then
        downloadFull
    elif [ "$1" = "unzip1C" ] || [ "$1" = "unz1" ]; then
        unzip1C
    elif [ "$1" = "is" ]; then
        install_server
    elif [ "$1" = "ic" ]; then
        install_client
    elif [ "$1" = "if" ]; then
        install_full
    elif [ "$1" = "all" ]; then
        downloadServer
        downloadClient
        downloadFull
        unzip1C
        install_server
        install_client
    else
        echo "download (dows, dowc, dowf), unzip1C (unz1), install (is, ic, if), all"
        exit 1
    fi
}
main "$1"
