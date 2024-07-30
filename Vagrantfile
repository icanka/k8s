# -*- mode: ruby -*-
# vi: set ft=ruby :

NUM_MASTER_NODE = 1
NUM_WORKER_NODE = 0
MASTER_IP_START = 10
NODE_IP_START = 20

IP_NW = "192.168.1."
POD_CIDR = "10.1.10.0/24"
SERVICE_CIDR="10.96.0.0/16"

# master ip
#MASTER_IP = IP_NW + "#{MASTER_IP_START}"

def setup_network_filenames(node)
  node.vm.provision "shell", path: "archlinux/network_filenames.sh"
end

def setup_gateway(node)
  node.vm.provision "shell", path: "archlinux/setup_gateway.sh" do |s|
    s.args = [IP_NW]
  end
end

def setup_dns(node)
  node.vm.provision "shell", path: "archlinux/setup_dns.sh"
end

def setup_hosts(node)
  node.vm.provision "shell", path: "archlinux/setup_hosts.sh" do |s|
    s.args = [IP_NW, MASTER_IP_START, NODE_IP_START, NUM_MASTER_NODE, NUM_WORKER_NODE]
  end
end

def setup_ssh(node)
  node.vm.provision "shell", path: "archlinux/ssh.sh"
end

def setup_node(node)
  node.vm.provision "shell", path: "archlinux/node_setup.sh"
end

def provision_kubernetes_node(node)
  setup_network_filenames node
  setup_gateway node
  setup_dns node
  setup_hosts node
  setup_ssh node
  setup_node node
end


def control_plane_setup(node)
  node.vm.provision "shell", path: "archlinux/control_plane.sh" do |s|
    s.args = [POD_CIDR, SERVICE_CIDR]
  end
end


# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "archlinux/archlinux"
  config.vm.boot_timeout = 9000

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  config.vm.box_check_update = false

  (1..NUM_MASTER_NODE).each do |i|
    config.vm.define "kubemaster0#{i}" do |node|
      node.vm.provider "libvirt" do |libvirt|
        libvirt.memory = 4096
        libvirt.cpus = 2
      end
      node.vm.hostname = "kubemaster0#{i}"
      node.vm.network :public_network, ip: IP_NW + "#{MASTER_IP_START + i}", :dev => "enp35s0", :mode => "bridge"
      #node.vm.network "forwarded_port", guest: 22, host: "#{2710 + i}"
      provision_kubernetes_node node
      control_plane_setup node
      node.vm.provision "shell", inline: <<-SHELL
        pacman -S --noconfirm tmux vim
      SHELL
      node.vm.provision "file", source: "archlinux/conf/tmux.conf", destination: "$HOME/.tmux.conf"
      node.vm.provision "file", source: "archlinux/conf/vimrc", destination: "$HOME/.vimrc"
    end
  end

  (1..NUM_WORKER_NODE).each do |i|
    config.vm.define "kubenode0#{i}" do |node|
      node.vm.provider "libvirt" do |libvirt|
        libvirt.memory = 2048
        libvirt.cpus = 2
      end
      node.vm.hostname = "kubenode0#{i}"
      node.vm.network :private_network, ip: IP_NW + "#{NODE_IP_START + i}"
      node.vm.network "forwarded_port", guest: 22, host: "#{2720 + i}"
      provision_kubernetes_node node
    end
  end

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.  # NOTE: This will enable public access to the opened port # config.vm.network "forwarded_port", guest: 80, host: 8080 # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Disable the default share of the current code directory. Doing this
  # provides improved isolation between the vagrant box and your host
  # by making sure your Vagrantfile isn't accessible to the vagrant box.
  # If you use this you may want to enable additional shared subfolders as
  # shown above.
  # config.vm.synced_folder ".", "/vagrant", disabled: true

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
end