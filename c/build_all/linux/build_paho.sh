#!/bin/bash

set -e

paho_repo="https://git.eclipse.org/r/paho/org.eclipse.paho.mqtt.c"
build_root=
quiet=0

push_dir ()
{
    pushd $1 > /dev/null
    echo "In ${PWD#$build_root/}"
}

pop_dir ()
{
    popd > /dev/null
}

usage ()
{
    echo 'build_paho.sh [options]'
    echo 'options'
    echo ' -s, --source    destination directory for paho source'
    echo '                 (default: $HOME/org.eclipse.paho.mqtt.c)'
    echo ' -i, --install   destination root directory for paho installation'
    echo '                 (default: $HOME)'
    echo ' -q, --quiet     no interactive prompts'
    exit 1
}

process_args ()
{
    build_root="$HOME/org.eclipse.paho.mqtt.c"
    install_root="$HOME"

    while [[ $# > 0 ]]
    do
        key="$1"
    
        case $key in
            -s|--source)
            build_root="$2"
            shift # past argument
            ;;
            -i|--install)
            install_root="$2"
            shift # past argument
            ;;
            -q|--quiet)
            quiet=1
            ;;
            *)
            usage # unknown option
            ;;
        esac
        shift # past argument or value
    done
}

sync_paho ()
{
    echo Azure IoT SDK has a dependency on eclipse paho mqtt c sdk
    echo http://www.eclipse.org/legal/CLA.php

    if [ $quiet == 0 ]
    then
        read -p "Do you want to install the component (y/n)?" input_var
    else
        input_var="y"
    fi

    if [ "$input_var" == "y" ] || [ "$input_var" == "Y" ]
    then
        echo "preparing qpid proton-c"
    else
        exit 1
    fi

    rm $build_root -r -f
    mkdir $build_root
    git clone $paho_repo $build_root
}

build ()
{
    push_dir $build_root
    make install
    pop_dir
}

process_args $*
echo "Source: $build_root"
echo "Install: $install_root"
sync_paho
build
