#!/bin/bash
# set -e
USERNAME="Trogdin"
PASSWORD="6gDek----JsO"
VERSION="8.3.8.2167"

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
