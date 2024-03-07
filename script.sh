#!/bin/bash

# Path playbooks Ansible
LIN_PLAYBOOKS_DIR="/root/playbooks/linux"
WIN_PLAYBOOKS_DIR="/root/playbooks/windows"

# List of playbooks
LIN_PLAYBOOKS=("l_smtp.yml" "l_user_passwd.yml")

# Verify if playbooks exist
for playbook in "${LIN_PLAYBOOKS[@]}"; do
    if [ ! -f "$PLAYBOOKS_DIR/$LIN_PLAYBOOKS" ]; then
        echo "[-] Playbook $LIN_PLAYBOOKS n'existe pas dans $LIN_PLAYBOOKS_DIR."
        exit 1
    fi
done

# Execute playbooks Ansible
echo "Execution of linux playbooks :"
for playbook in "${LIN_PLAYBOOKS[@]}"; do
    echo "[-] $LIN_PLAYBOOKS ..."
    ansible-playbook -i inventory "$LIN_PLAYBOOKS_DIR/$LIN_PLAYBOOKS"
done
