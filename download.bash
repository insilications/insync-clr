#!/usr/bin/env bash

# Try to locate the original rpm under current directory
echo -e "\e[33m\xe2\x8f\xb3 Locating insync-<VERSION>-fc33.x86_64.rpm...\e[m"
VERSION="$(curl -L --silent 'https://www.insynchq.com/downloads' | grep -oP "(?<=\"linux\":\s\")(\d+)(\.\d+)+")"
JS_URL="$(curl -L --silent 'https://www.insynchq.com/downloads' | grep -oP "https:\/\/([a-zA-Z0-9_\.\/-]+)downloads\.js")"
DOWNLOAD_URL="$(curl -L --silent "${JS_URL}" | grep -oP "(?<=var\srpmLink\s=\s')https:\/\/([a-zA-Z0-9_\.\/-]+)")"
DOWNLOADURL="${DOWNLOAD_URL}${VERSION}-fc33.x86_64.rpm"
echo -e "\e[33m\xE2\x9C\x93 latest version is: $VERSION"
echo -e "\e[33m\xE2\x9C\x93 download URL is: $DOWNLOADURL"
curl -L -C - -O $DOWNLOADURL
INSTALLER="$(find . -maxdepth 1 | sort -r | grep --max-count=1 -oP "\.\/insync\-\d+[\.\d+]+\-fc33\.x86\_64\.rpm")"
if [ "$INSTALLER" = '' ]; then
## Cannot download or find installer
    echo -e "\e[31m\xe2\x9d\x8c Cannot download or find insync-<VERSION>-fc33.x86_64.rpm under current directory\e[m"
    exit 1
else
    echo -e "\e[33m\xE2\x9C\x93 Found insync-<VERSION>-fc33.x86_64.rpm\e[m"
    rpm2cpio insync-*.rpm | cpio -ivdm --directory=$PWD
    pushd $PWD/usr/lib/insync/
    rm libX11.so.6
    rm libxkbcommon.so.0
    rm libtinfo.so.6
    rm libpng16.so.16
    popd
    pushd $PWD/usr/bin/
    sd "/usr/lib/insync/insync" "/usr/lib64/insync/insync" $(fd insync .)
    sd '"\$@"' '"$@" --ca-path /var/cache/ca-certs/anchors/ --qt-qpa-platform xcb' $(fd insync .)
    popd
fi
