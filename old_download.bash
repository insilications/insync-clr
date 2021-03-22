#!/usr/bin/env bash

# Try to locate the original rpm under current directory
echo -e "\e[33m\xe2\x8f\xb3 Locating insync-<VERSION>-fc30.x86_64.rpm...\e[m"
VERSION_URL="$(curl -L 'http://yum.insync.io' | xml sel -t -m "/_:ListBucketResult/_:Contents[_:Key[contains(text(),'fedora/31/x86_64')]]/_:LastModified" -s D:T:- "text()" -v "parent::node()/_:Key" -n | head -1)"
DOWNLOAD_URL="http://yum.insync.io/${VERSION_URL}"
THE_VERSION=$(echo $VERSION_URL | grep -oP "(?<=insync\-)\d+[\.\d+]+(?=\-fc30)")
echo -e "\e[33m\xe2\x8f\xb3 latest version is: $THE_VERSION"
curl -L -C - -O ${DOWNLOAD_URL}
INSTALLER="$(find . -maxdepth 1 | sort -r | grep --max-count=1 -oP "\.\/insync\-\d+[\.\d+]+\-fc30\.x86\_64\.rpm")"
if [ "$INSTALLER" = '' ]; then
    ## Cannot download or find installer
    echo -e "\e[31m\xe2\x9d\x8c Cannot download or find insync-<VERSION>-fc30.x86_64.rpm under current directory\e[m"
    exit 1
else
    echo -e "\e[33m\xe2\x8f\xb3 Found insync-<VERSION>-fc30.x86_64.rpm\e[m"
    rpm2cpio insync-*.rpm | cpio -ivdm --directory=$PWD
    pushd $PWD/usr/lib/insync/
    rm libX11.so.6
    popd
    pushd $PWD/usr/bin/
    find . -type f -name 'insync' -exec sed -i 's/\"\$@\"/\"\$@\" --ca-path \/etc\/ssl\/certs\//g' {} \;
    find . -type f -name 'insync' -exec sed -i 's/\/usr\/lib\/insync/\/usr\/lib64\/insync/g' {} \;
    popd
fi