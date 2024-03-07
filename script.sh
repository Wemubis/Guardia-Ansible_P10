#!/bin/bash

# Define some variables
INVENTORY="inventory"

# Define playbook directories
PLAYBOOKS_DIR="/root/playbooks"
LIN_DIR="$PLAYBOOKS_DIR/linux"
WIN_DIR="$PLAYBOOKS_DIR/windows"

# Lists of playbooks to install and uninstall for Linux and Windows
I_LINUX=("snmp.yml" "usr_pwd.yml")
I_WINDOWS=()
U_LINUX=("del_snmp.yml" "del_usr_pwd.yml")
U_WINDOWS=()

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
    check_playbooks_existence "$LIN_DIR" "${I_LINUX[@]}"
    check_playbooks_existence "$WIN_DIR" "${I_WINDOWS[@]}"
elif [[ "$1" == "-r" || "$1" == "--remove" ]]; then
    check_playbooks_existence "$LIN_DIR" "${U_LINUX[@]}"
    check_playbooks_existence "$WIN_DIR" "${U_WINDOWS[@]}"
fi

# Execute appropriate playbooks based on provided argument
case "$1" in
    -i | --install)
        execute_playbooks "$LIN_DIR" "${I_LINUX[@]}"
        execute_playbooks "$WIN_DIR" "${I_WINDOWS[@]}"
        ;;
    -r | --remove)
        execute_playbooks "$LIN_DIR" "${U_LINUX[@]}"
        execute_playbooks "$WIN_DIR" "${U_WINDOWS[@]}"
        ;;
esac
