#!/bin/bash

# mdk-sdk version to install
MDK_VERSION="v0.16.0"

# default architecture
ARCH="amd64"

set -eu -o pipefail # fail on error , debug all lines

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

if [ "$#" -eq 1 ]; then
    ARCH=$1
fi

if [ "$ARCH" != "amd64"  ] && [ "$ARCH" != "arm64" ] && [ "$ARCH" != "armhf" ]; then
    echo "Invalid architecture ($ARCH) should be one of amd64, arm64 or armhf"
    exit 1
fi

echo Installing the MDK-SDK libraries for $ARCH

echo Downloading the MDK-SDK Version $MDK_VERSION
wget -q -O /tmp/mdk-sdk-linux.tar.xz https://github.com/wang-bin/mdk-sdk/releases/download/$MDK_VERSION/mdk-sdk-linux.tar.xz

echo Extracting the archive
tar -x -f /tmp/mdk-sdk-linux.tar.xz -C /tmp

echo Making sure the install directory exists and is empty
mkdir -p "/lib/mythqml"
rm -rf /lib/mythqml/*

echo Installing the MDK-SDK libraries
cp -rf /tmp/mdk-sdk/lib/$ARCH/* /lib/mythqml/

echo Cleaning up
rm /lib/mythqml/libffmpeg.so.*
rm -rf /tmp/mdk-sdk
rm /tmp/mdk-sdk-linux.tar.xz

echo DONE
