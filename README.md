# Project Documentation

## Table of Contents
1. [Introduction](#introduction)
2. [Machine Configuration](#machine-configuration)
   - [Machine Addressing Plan](#machine-addressing-plan)
   - [OPNSense Configuration](#opnsense-configuration)
   - [AlmaLinux Configuration](#almalinux-configuration)
   - [Windows Client Configuration](#windows-client-configuration)
3. [Playbook Configuration](#playbook-configuration)
   - [Inventory](#inventory)
   - [SNMP](#snmp)
   - [Users](#users)
   - [Vault](#vault)
   - [Centreon](#centreon)
4. [Script for Launching Playbooks](#script-for-launching-playbooks)
   - [Overview](#overview)
   - [Features](#features)
   - [Requirements](#requirements)
   - [Usage](#usage)

<br><br>

## Introduction
This documentation details the setup and management of a virtualized network environment utilizing VirtualBox. It includes configurations for AlmaLinux, Windows Server, and OPNSense for firewall and DNS functionalities.

<br><br>

## Machine Configuration

### Machine Addressing Plan
The network setup consists of five machines interconnected via an "intra" internal network, with OPNSense also set up in NAT mode.

- **OPNSense:** `192.168.1.1`
- **Centreon:** `192.168.1.2`
- **Ansible:** `192.168.1.3`
- **Client (Linux):** `192.168.1.4`
- **Client (Windows):** `192.168.1.5`

<br>

### OPNSense Configuration
Configure the OPNSense machine interfaces:
- **WAN (em0)**
- **LAN (em1)**

Disable the firewall with:
```bash
pfctl -d
```

<br>

### AlmaLinux Configuration

1. **Manual Machine Configuration:**
```bash
nmcli con mod enp0s3 IPv4.method manual
nmcli con mod enp0s3 IPv4.address <IP_host>
nmcli con mod enp0s3 IPv4.gateway <IP_gateway>/<mask>
nmcli con mod enp0s3 IPv4.dns <IP_dns>
````

-  **SSH Configuration:**
- Generate SSH key:
```bash
ssh-keygen -t rsa
```

- Enable root SSH access and restart the SSH service:
```bash
vim /etc/ssh/sshd_config # Uncomment and set: PermitRootLogin yes, PubkeyAuthentication yes, PasswordAuthentication yes
systemctl restart sshd
```

- Copy the public key to the client's `known_hosts`:
```bash
ssh-copy-id -i /root/.ssh/id_rsa.pub root@<ip_client>
```

- Disable the firewall on the client:
```bash
systemctl disable firewalld
systemctl stop firewalld
```

<br>

### Client Machine (Windows)

- **Manual Configuration via Command Prompt:**
```bash
sconfig
```

Then follow the prompts in your terminal.

- **Firewall Configuration with PowerShell:**
```bash
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
```

- **WinRM Configuration:**
[TODO]

<br><br>

# Playbooks Configuration

## INVENTORY

In my [`inventory`](inventory), I've defined groups for hosts:
```bash
[linux]
linux1 ansible_host=192.168.1.4 ansible_name=linux1

[windows]
windows1 ansible_host=192.168.1.5 ansible_name=windows1
```

I've done the same for global variables or those assigned to a specific host group:
```bash
[all:vars]
snmp_community="public"
snmp_version="2c"
...
```

Assigning these variables allows for simplification when modifying the code since I only need to modify it once here.

<br>

### SNMP
Simple Network Management Protocol (SNMP) is essential for network management. It allows for the collection of detailed data from network devices. Before attempting to install or configure SNMP on a target machine, it's crucial to verify whether it's already installed:

- **For Linux:**
  Check the installation status of SNMP using the package management system.
- **For Windows:**
  Use Windows Registry to verify the presence of SNMP configurations.

After verification, SNMP can be installed or configured accordingly. Detailed instructions and playbook examples for managing SNMP can be found in the [`SNMP playbook`](playbooks/snmp.yml).

<br>

### Users
By automating user creation and password management, we maintain consistency and security across our network. The playbooks handle:
- Generating secure passwords.
- Creating users with these passwords.
- Optionally, updating passwords for existing users.

This automation ensures that user accounts on both Linux and Windows systems are consistently managed, improving security and auditability.

For more details, see the user management playbook: [`User Playbook`](playbooks/usr.yml).

<br>

### Vault
Ansible Vault is a feature that allows users to keep sensitive data such as passwords or keys in encrypted files, rather than as plaintext in playbooks or roles.

The vault script ([`create_vault.sh`](create_vault.sh)) simplifies working with Ansible Vault by automating the creation, encryption, and decryption of vault files based on the user's input.

More information on Ansible Vault can be found in the [Ansible documentation](https://docs.ansible.com/ansible/latest/user_guide/vault.html).

<br>

### Centreon
Centreon is a comprehensive IT monitoring solution that enables you to monitor your entire IT infrastructure from a single platform. The centreon script ([`install_centreon.sh`](install_centreon.sh)) install centreon on the machine.

The Centreon playbooks ([`centreon.yml`](playbooks/centreon.yml)) automate tasks such as:
- Checking if machines are already present in Centreon.
- Adding new machines with their SNMP configurations.
- Applying monitoring templates and exporting configurations.

These playbooks facilitate the rapid deployment and management of our monitoring infrastructure, ensuring that new or updated hosts are quickly integrated into your monitoring setup. For an introduction to Centreon and instructions on manual setup, visit the [Centreon documentation](https://docs.centreon.com/current/en/).

<br><br>

# Script to Launch Files

## Overview
This Bash script automates the execution of Ansible playbooks for installing or removing system configurations. It simplifies the management of Ansible playbooks : [`script.sh`](script.sh)

<br>

## Features
- **Install Configurations:** Easily install configurations on systems using predefined Ansible playbooks.
- **Remove Configurations:** Safely remove installed configurations using corresponding Ansible playbooks.

<br>

## Requirements
- **Ansible:** Ensure Ansible is installed and properly configured on the system where the script will be run.
- **Inventory and Playbooks:** An inventory file and playbook files must be correctly set up and accessible to the script.

<br>

## Usage
To use the script, you have the following options:
- **Install Configurations:** `./script.sh -i` or `./script.sh --install`
- **Remove Configurations:** `./script.sh -r` or `./script.sh --remove`

Ensure you run the script from the directory where it's located, or provide the full path to the script.
