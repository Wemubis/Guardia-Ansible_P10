# Machine Configuration

The machines are installed on VirtualBox. There are 5 machines: 3 Almalinux, one Windows Server, and one OPNsense (serves as a firewall and DNS).

<u>Machine Addressing Plan</u>:
- OPNSense: 192.168.1.1
- Centreon: 192.168.1.2
- Ansible: 192.168.1.3
- Client (Linux): 192.168.1.4
- Client (Windows): 192.168.1.5

All machines are on an internal network: "intra". And the OPNSense machine is also in NAT.

<br>

## OPNSense Machines
Configuration of interfaces on OPNsense:
- em0: WAN
- em1: LAN

Disabling firewall rules (OPTION 8):
```bash
pfctl -d
```

<br>

#### Almalinux Machines
1) Manual configuration of machines:
```bash
nmcli con mod enp0s3 IPv4.method manual
nmcli con mod enp0s3 IPv4.address <IP_host>
nmcli con mod enp0s3 IPv4.gateway <IP_gateway>/<mask>
nmcli con mod enp0s3 IPv4.dns <IP_dns>
```

2) SSH configuration:
- Generating SSH key:
```bash
ssh-keygen -t rsa
```

- Uncomment lines in the sshd_config file to allow SSH communication with the root user:
```bash
vim /etc/ssh/sshd_config
```
> PermitRootLogin yes
> 
> PubkeyAuthentication yes
> 
> PasswordAuthentication yes

- Restarting the SSH service:
```bash
systemctl restart sshd
```

- Saving the public key in the client's known_hosts file:
```bash
ssh-copy-id -i /root/.ssh/id_rsa.pub root@<ip_client>
```

- Disabling the firewall on the client:
```bash
systemctl disable firewalld
systemctl stop firewalld
```

<br>

#### Client Machine (Windows)
Manual configuration of the machine via the command prompt:
```bash
sconfig
```

Then, follow the steps displayed on your terminal:
![[Pasted image 20240313115326.png|300]]

Manually configure the firewall with PowerShell:
```bash
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
```

<br>
Configuration of WinRM:
Use these repositories to install and configure it:
[TODO]

<br><br>

## Playbooks Configuration

#### INVENTORY

In my [inventory](inventory), I've defined groups for hosts:
```bash
[linux]
192.168.1.4
...

[windows]
192.168.1.5
...

[central]
192.168.1.2
...
```

I've done the same for global variables or those assigned to a specific host group:
```bash
[all:vars]
snmp_community="public"
snmp_version="2c"
l_username="BobTheBuilder"
lhost_name="linux_client"
ltemplate="OS-Linux-SNMP-Custom"
...

[windows:vars]
ansible_connection=winrm
ansible_user=Administrator
...
```

Assigning these variables allows for simplification when modifying the code since I only need to modify it once here.

<br>

#### SNMP
Before installing and configuring the SNMP service, I check if it already exists.

Linux:
```yaml
- name: Check if SNMP is installed
  shell: "rpm -q net-snmp"
  register: snmp_status
  ignore_errors: true
```
Windows:
```yaml
- name: Check if SNMP exists
  win_reg_stat:
    path: HKLM:\SYSTEM\CurrentControlSet\Services\SNMP
  register: snmp_reg_stat
```

Then I install the service and its dependencies on the corresponding machines and modify the configuration file if necessary.
> See [snmp.yml](playbooks/snmp.yml).

I also wrote a playbook for uninstalling the service as required by the project: [del_snmp.yml](playbooks/del_snmp.yml).

<br>

#### USERS
For this part, I've written a [playbook](playbooks/usr.yml) that creates a user on the target machine and assigns them a random password. Then, it saves the credentials in a [VAULT](#vault) (next section).

First, I generate a random 12-character alphanumeric password:
```yaml
- name: Generate a random password
  set_fact:
    random_password: "{{ lookup('password', '/dev/null length=12 chars=ascii_letters,digits') }}"
```

Then, I add the user if it's not already created on the machine or simply update their password with these properties:
```yaml
user: # win_user: for windows
  name: "{{ l_username }}"
  password: "{{ random_password | password_hash('sha512') }}"
  state: present
  update_password: always
```

Here is the playbook for the deletion of the user : [del_usr.yml](playbooks/del_usr.yml)

<br>

#### VAULT

For the vault, I've created a bash script to handle its creation, encryption, and decryption based on the argument added: [vault.sh](create_vault.sh)

The creation, encryption, and decryption processes require a file with the password located here: [password.txt](vault/password.txt).

```bash
ansible-vault create /path/vault_file.yml --vault-password-file=/path/password.txt
```

For the other steps concerning the encryption or decryption of the vault, the commands are within the script.

Then, to add passwords and usernames into the vault, I used Jinja2 templates (.j2, a template engine written for Python).

```Jinja2
# secrets.yml
users:
  Linux:
    Username: "{{ l_username }}"
    Password: "{{ random_password }}"
  Windows:
    Username: "{{ w_username }}"
    Password: "{{ random_password }}"
```

Finally, this template is copied and then updated in the secret file with the variable values:

```yaml
- name: Create or update secrets.yml file
  template:
    src: "{{ pattern_secret }}"
    dest: "{{ secret_file }}"
  delegate_to: localhost

- name: Load vaulted variables
  include_vars:
    file: "{{ secret_file }}"
  delegate_to: localhost
```

<br>

#### CENTREON


<br><br>

## Script to Launch Files

