#!/bin/bash

set -e

function build
{
    if [ ! -e vala ];
    then
        if [ ! -e vala ];
        then
            git clone git://git.gnome.org/vala
        fi

        cd vala
        git checkout staging
        ./autogen.sh --prefix=$PWD/../build --disable-shared --enable-static --disable-vapigen
        make -j8
        make install
        make clean

        rm -f */*.vala.stamp
        patch -p1 < ../base-set-property.patch
        patch -p1 < ../add-explicit-notify.patch
        ./configure \
            CFLAGS="-fPIC" \
            VALAC=$PWD/../build/bin/valac \
            --prefix=$PWD/../build --disable-shared --enable-static
        make -j8
        make install
        cd ..
    fi
}

function clean
{
    rm -rf vala
    rm -rf build
}

if [ $# -lt 1 ]
then
    echo "$0 [COMMAND]"
    echo "COMMAND:"
    echo "  - build : build bootstrap"
    echo "  - clean : clean bootstrap"
    exit 1
fi

cd bootstrap

if [ $1 == "build" ];
then
    build
elif [ $1 == "clean" ];
then
    clean
fi
