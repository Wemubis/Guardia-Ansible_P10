#!/bin/bash

# Define some variables
INVENTORY="inventory"

# Define playbook directories
PLAYBOOKS_DIR="/root/playbooks"

# Lists of playbooks to install and uninstall for Linux and Windows
I_FILES=("snmp.yml" "usr.yml")
R_FILES=("del_snmp.yml" "del_usr.yml")

# Function to check the existence of playbooks
check_playbooks_existence() {
    local playbook_dir=$1
    shift
    local playbooks=("$@")

    for playbook in "${playbooks[@]}"; do
        if [ ! -f "$playbook_dir/$playbook" ]; then
            echo "[-] Playbook $playbook does not exist in $playbook_dir."
            exit 1
        fi
    done
}

# Function to execute playbooks
execute_playbooks() {
    local playbook_dir=$1
    shift
    local playbooks=("$@")

    if [ ${#playbooks[@]} -gt 0 ]; then
        echo "Executing playbooks for $playbook_dir..."
        for playbook in "${playbooks[@]}"; do
            ansible-playbook -i "$INVENTORY" "$playbook_dir/$playbook"
        done
        echo "Playbooks executed successfully for $playbook_dir."
    fi
}

# Check the number of arguments
if [ "$#" -ne 1 ]; then
    echo "Invalid argument. Usage: $0 [-i | --install | -r | --remove]"
    exit 1
fi

# Check existence of playbooks based on action to be performed
if [[ "$1" == "-i" || "$1" == "--install" ]]; then
    check_playbooks_existence "$PLAYBOOKS_DIR" "${I_FILES[@]}"
elif [[ "$1" == "-r" || "$1" == "--remove" ]]; then
    check_playbooks_existence "$PLAYBOOKS_DIR" "${R_FILES[@]}"
fi

# Execute appropriate playbooks based on provided argument
case "$1" in
    -i | --install)
        execute_playbooks "$PLAYBOOKS_DIR" "${I_FILES[@]}"
        ;;
    -r | --remove)
        execute_playbooks "$PLAYBOOKS_DIR" "${R_FILES[@]}"
        ;;
esac
