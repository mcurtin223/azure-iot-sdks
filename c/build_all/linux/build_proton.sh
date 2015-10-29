#!/bin/bash

set -e

proton_repo="https://github.com/dcristoloveanu/qpid-proton"
proton_branch="0.9-IoTClient"
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
    echo 'build_proton.sh [options]'
    echo 'options'
    echo ' -s, --source    destination directory for proton source'
    echo '                 (default: $HOME/qpid-proton)'
    echo ' -i, --install   destination root directory for proton installation'
    echo '                 (default: $HOME)'
    echo ' -q, --quiet     no interactive prompts'
    exit 1
}

process_args ()
{
    build_root="$HOME/qpid-proton"
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

sync_proton ()
{
    echo Azure IoT SDK has a dependency on apache qpid-proton-c
    echo https://github.com/apache/qpid-proton/blob/master/LICENSE

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
    cd /tmp
    curl -L $proton_repo/archive/$proton_branch.zip -o proton.zip
    mkdir proton
    unzip proton.zip -d proton
    mv ./proton/qpid-proton-$proton_branch/ $build_root/
    rm proton.zip
    rm -rf proton
}

build ()
{
    if [ ! -d $build_root/build ]
    then
        mkdir $build_root/build
    fi

    push_dir $build_root/build

    cmake .. -DCMAKE_INSTALL_PREFIX="$install_root" -DSYSINSTALL_BINDINGS=ON
    make
    make install

    pop_dir
}

process_args $*
echo "Source: $build_root"
echo "Install: $install_root"
sync_proton
build
