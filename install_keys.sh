#!/usr/bin/env bash

SILENT=false

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
    -s|--silent)
    SILENT=true
    shift 
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

log() {
    if ! $SILENT; then
        echo $1
    fi
}

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
    log "User \"$username\" does not exist!"
    exit 1
else
    if ! grep -qF "$key" ~/.ssh/authorized_keys;
    then
        log "One or more of the keys does not exist. Adding all keys to ~/.ssh/authorized_keys"
        log $key >> ~/.ssh/authorized_keys
    else
        log "Key already exist!"
    fi
fi
