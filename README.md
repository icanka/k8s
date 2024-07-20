# libvirt
First, install libvirt, api for controlling virtualization engines such as kvm,qeumu.

`$ sudo pacman -Syy libvirt`

## vagrant-libvirt

Set VAGRANT_DISABLE_STRICT_DEPENDENCY_ENFORCEMENT=1 if you are getting conflicting version error about the **date** package

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

Then example output of **vagrant status** might be:

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
