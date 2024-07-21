# Configuration

## Basics

- Check the Virtualization support for your CPU

`$ LC_ALL=C.UTF-8 lscpu | grep Virtualization`

```text
Virtualization:                       AMD-V
```

- Check if the necessary modules, kvm and either kvm_amd or kvm_intel, are available in the kernel with the following command:

`$ zgrep CONFIG_KVM= /proc/config.gz`

```text
CONFIG_KVM=m
```

**y** or **m** means available.

- Then, ensure that the kernel modules are automatically loaded, with the command:

`$ lsmod | grep kvm`

```text
kvm_amd               208896  0
kvm                  1359872  1 kvm_amd
ccp                   180224  1 kvm_amd
```

- Install libvirt, api for controlling virtualization engines such as kvm,qeumu, along with qemu

`$ sudo pacman -Syy libvirt qemu-base qemu-desktop virt-manager`

virt-manager (Virtual Machine Manager) allow you to graphically manage kvm, xen or lxc via libvirt.

## libvirt

Libvirt is moving from a single monolithic daemon to separate modular daemons, with the intention to remove the monolithic daemon.

- First check whether monolithic mode is in use.

  `$ systemctl is-active libvirtd.socket`

  `$ systemctl is-active libvirtd.service`

- Disable monolithic mode if active

  `$ systemctl stop libvirtd.service`

  `$ systemctl stop libvirtd{,-ro,-admin,-tcp,-tls}.socket`

  `$ systemctl disable libvirtd.service`

  `$ systemctl disable libvirtd{,-ro,-admin,-tcp,-tls}.socket`

- Enable the new daemons for the particular virtualizationd driver desired, and any of the secondary drivers to accompany it. The following example enables the QEMU driver and all the secondary drivers:

```console
$ for drv in qemu interface network nodedev nwfilter secret storage
  do
    systemctl unmask virt${drv}d.service
    systemctl unmask virt${drv}d{,-ro,-admin}.socket
    systemctl enable virt${drv}d.service
    systemctl enable virt${drv}d{,-ro,-admin}.socket
  done
```

- Start the sockets for the same set of daemons. There is no need to start the services as they will get started when the first socket connection is established

```console
$ for drv in qemu network nodedev nwfilter secret storage
  do
    systemctl start virt${drv}d{,-ro,-admin}.socket
  done
```

- The easiest way to ensure your user has access to libvirt daemon is to add member to libvirt user group.

`$ sudo usermod -aG libvirt <username>`

- Change the firewall backend to iptables for network connectivity. libvirt will add necessary iptables rules.

`$ sed -i 's/^firewall_backend=nftables/firewall_backend=iptables/' /etc/libvirt/network.conf`

Refer to archlinux wiki for kvm, libvirt or qemu for more detailed info.

## vagrant-libvirt

- Vagrant mounts your project workspace into vms using nfs on your host. If you're using nfs version 3, only tcp is 
activated by default.

`$ sed -i 's/^# udp=n/udp=y/' /etc/nfs.conf`

- Set VAGRANT_DISABLE_STRICT_DEPENDENCY_ENFORCEMENT=1 if you are getting conflicting version error about the **date** package

```console
[izzetcan@jupiter k8s]$ VAGRANT_DISABLE_STRICT_DEPENDENCY_ENFORCEMENT=1 vagrant plugin install vagrant-libvirt
Installing the 'vagrant-libvirt' plugin. This can take a few minutes...
Building native extensions. This could take a while...
Fetching formatador-1.1.0.gem
Fetching fog-core-2.4.0.gem
Fetching fog-xml-0.1.4.gem
Fetching fog-json-1.2.0.gem
Fetching fog-libvirt-0.12.2.gem
Fetching diffy-3.4.2.gem
Fetching vagrant-libvirt-0.12.2.gem
Installed the plugin 'vagrant-libvirt (0.12.2)'!
```

- Then example output of **vagrant status** might be:

```console
[izzetcan@jupiter k8s]$ vagrant status
Current machine states:

kubemaster01              not created (libvirt)
kubenode01                not created (libvirt)
kubenode02                not created (libvirt)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.
```
