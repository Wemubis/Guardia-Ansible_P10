#!/bin/bash

# Script Guide:
# This script is designed to manage the execution of Ansible playbooks for installing or removing configurations on systems.
# Usage:
# ./script.sh -i | --install   : To install configurations using defined playbooks.
# ./script.sh -r | --remove    : To remove configurations using defined playbooks.
#
# Requirements:
# - Ansible must be installed and configured on the system running this script.
# - Inventory file and playbook files must be correctly set up and accessible by this script.

# Define some variables
INVENTORY="inventory"
PLAYBOOKS_DIR="/root/playbooks"

# Lists of playbooks to install and uninstall for Linux and Windows
I_FILES=("snmp.yml" "usr.yml" "centreon.yml")
R_FILES=("del_snmp.yml" "del_usr.yml" "del_centreon.yml")

# Function to check the existence of playbooks
check_playbooks_existence() {
    local playbook_dir=$1
    shift
    local playbooks=("$@")

    for playbook in "${playbooks[@]}"; do
        if [ ! -f "$playbook_dir/$playbook" ]; then
            echo "[-] Playbook $playbook does not exist in $playbook_dir." >&2
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
            ansible-playbook -i "$INVENTORY" "$playbook_dir/$playbook" || {
                echo "Error executing playbook $playbook. Please check the playbook and inventory details." >&2
                exit 1
            }
        done
        echo "Playbooks executed successfully for $playbook_dir."
    fi
}

# Check the number of arguments
if [ "$#" -ne 1 ]; then
    echo "Invalid argument. Usage: $0 [-i | --install | -r | --remove]" >&2
    exit 1
fi

# Execute appropriate playbooks based on provided argument
case "$1" in
    -i | --install)
        execute_playbooks "$PLAYBOOKS_DIR" "${I_FILES[@]}"
        ;;
    -r | --remove)
        execute_playbooks "$PLAYBOOKS_DIR" "${R_FILES[@]}"
        ;;
    *)
        echo "Invalid option: $1. Use -i/--install for installation or -r/--remove for removal." >&2
        echo "Please check the usage guide at the beginning of the script for correct options." >&2
        exit 1
        ;;
esac
