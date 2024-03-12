## Machine Configuration

The machines are installed on VirtualBox. There are 5 machines: 3 Almalinux, one Windows Server, and one OPNsense (serves as a firewall and DNS).

<u>Machine Addressing Plan</u>:
- OPNSense: 192.168.1.1
- Centreon: 192.168.1.2
- Ansible: 192.168.1.3
- Client (Linux): 192.168.1.4
- Client (Windows): 192.168.1.5

All machines are on an internal network: "intra". And the OPNSense machine is also in NAT.

<br>

#### OPNSense Machines
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
ssh-copy-id -i /path/.ssh/id_rsa.pub root@<ip_client>
```

- Disabling the firewall on the client:
```bash
systemctl disable firewalld
systemctl stop firewalld
```

<br>

#### Client Machine (Windows)
Manual configuration of the machine:

Configuration of WinRM:

<br><br>

## Configuration des playbooks
