#!/bin/bash

# Variables
SECRETS="/root/vault/secrets.yml"
PASSWORD="/root/vault/password.txt"


if [[ "$1" == "-c" && -f $SECRETS ]]; then
    echo "create vault $SECRETS\n"
    mkdir vault
    ansible-vault create $SECRETS --vault-password-file=$PASSWORD
elif [[ "$1" == "-e" ]]; then
    echo "create vault $SECRETS with $PASSWORD\n"
    ansible-vault encrypt $SECRETS --vault-password-file=$PASSWORD
elif [[ "$1" == "-d" ]]; then
    echo "decrypt vault $SECRETS with $PASSWORD\n"
    ansible-vault decrypt $SECRETS --vault-password-file=$PASSWORD
fi