#!/usr/bin/env bash

# Try to locate the original rpm under current directory
echo -e "\e[33m\xe2\x8f\xb3 Locating insync-<VERSION>-fc34.x86_64.rpm...\e[m"
VERSION="$(curl -L --silent 'https://www.insynchq.com/downloads' | grep -oP "(?<=\"linux\":\s\")(\d+)(\.\d+)+")"
JS_URL="$(curl -L --silent 'https://www.insynchq.com/downloads' | grep -oP "https:\/\/([a-zA-Z0-9_\.\/-]+)downloads\.js")"
DOWNLOAD_URL="$(curl -L --silent "${JS_URL}" | grep -oP "(?<=var\srpmLink\s=\s')https:\/\/([a-zA-Z0-9_\.\/-]+)")"
DOWNLOADURL="${DOWNLOAD_URL}${VERSION}-fc34.x86_64.rpm"
echo -e "\e[33m\xE2\x9C\x93 latest version is: $VERSION"
echo -e "\e[33m\xE2\x9C\x93 download URL is: $DOWNLOADURL"
curl -L -C - -O $DOWNLOADURL
INSTALLER="$(find . -maxdepth 1 | sort -r | grep --max-count=1 -oP "\.\/insync\-\d+[\.\d+]+\-fc34\.x86\_64\.rpm")"
if [ "$INSTALLER" = '' ]; then
## Cannot download or find installer
    echo -e "\e[31m\xe2\x9d\x8c Cannot download or find insync-<VERSION>-fc34.x86_64.rpm under current directory\e[m"
    exit 1
else
    echo -e "\e[33m\xE2\x9C\x93 Found insync-<VERSION>-fc34.x86_64.rpm\e[m"
    rpm2cpio insync-*.rpm | cpio -ivdm --directory=$PWD
    pushd $PWD/usr/lib/insync/
#     rm libX11.so*
#     rm libxkbcommon.so*
#     rm libtinfo.so*
#     rm libpng16.so*
#     rm lib{drm,GLX,GLdispatch}.so*
#     rm libgdk_pixbuf-2.0.so*
    popd
    pushd $PWD/usr/bin/
    if output=$(rg '/usr/lib/insync/insync' "$(fd -a insync .)"); then
        sd "/usr/lib/insync/insync" "/usr/lib64/insync/insync" "$(fd -a insync .)"
    fi
    if ! output=$(rg 'ca-path' "$(fd -a insync .)"); then
        sd '"\$@"' '"$@" --ca-path /var/cache/ca-certs/anchors/ --qt-qpa-platform xcb' "$(fd -a insync .)"
        sd 'LC_TIME=C' 'LC_TIME=C QT_QPA_PLATFORM=xcb' "$(fd -a insync .)"
    fi
    popd
fi
