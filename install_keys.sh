#!/usr/bin/env bash

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -u|--username)
    username="$2"
    shift # past argument
    shift # past value
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters


if [[ ! -d ~/.ssh ]]; then
    mkdir ~/.ssh
    chmod 700 ~/.ssh
fi

if [[ ! -f ~/.ssh/authorized_keys ]]; then
    touch ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
fi

if [[ ! -n $username ]]; then
    read -p "Enter launchpad user: " username
fi

key="$(curl --fail --silent "https://launchpad.net/~$username/+sshkeys")" && success=true || success=false

if [[ $success == false ]]; then
    echo "User \"$username\" does not exist!"
else
    if ! grep -qF "$key" ~/.ssh/authorized_keys;
    then
        echo "One or more of the keys does not exist. Adding all keys to ~/.ssh/authorized_keys"
        echo $key >> ~/.ssh/authorized_keys
    else
        echo "Key already exist!"
    fi
fi
