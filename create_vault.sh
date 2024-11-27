#!/bin/bash

# Variables
SECRETS="/root/vault/secrets.csv"
PASSWORD="/root/vault/password.txt"


if [[ "$1" == "-c" ]]; then
    echo "create vault $SECRETS\n"
    ansible-vault create $SECRETS --vault-password-file=$PASSWORD
elif [[ "$1" == "-e" ]]; then
    echo "encrypt vault $SECRETS with $PASSWORD\n"
    ansible-vault encrypt $SECRETS --vault-password-file=$PASSWORD
elif [[ "$1" == "-d" ]]; then
    echo "decrypt vault $SECRETS with $PASSWORD\n"
    ansible-vault decrypt $SECRETS --vault-password-file=$PASSWORD
fi
