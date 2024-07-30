swapoff -a
rm -rf /swap/swapfile
pacman -Syy --noconfirm
yes | pacman -S --needed iptables-nft

module_names=("overlay" "br_netfilter")
> /etc/modules-load.d/k8s.conf
for module_name in "${module_names[@]}"; do
    echo $module_name >> /etc/modules-load.d/k8s.conf   
    modprobe $module_name
    if ! lsmod | grep -Eq "^$module_name"; then
        echo "$module_name module not loaded. Exiting."
        exit 1
    fi
done

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sysctl -q --system

sysctl_test=$(sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward | cut -d' ' -f3 | tr -d '\n')
if [ "$sysctl_test" != "111" ]; then
    echo "sysctl params not set correctly. Exiting."
    exit 1
fi

pacman -S --noconfirm --needed containerd
if systemctl enable --now containerd; then
    echo "containerd enabled and started"
    mkdir -p /etc/containerd
    containerd config default > /etc/containerd/config.toml
    sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
    if systemctl restart containerd; then echo "containerd restarted";else echo "containerd restart failed" exit 1; fi
else
    echo "containerd failed to start"
    exit 1
fi

pacman -S --noconfirm --needed cni-plugins crictl kubectl kubelet kubeadm

crictl config \
    --set runtime-endpoint=unix:///run/containerd/containerd.sock \
    --set image-endpoint=unix:///run/containerd/containerd.sock

if systemctl enable --now kubelet; then
    echo "kubelet enabled and started"
else
    echo "kubelet failed to start"
    exit 1
fi


cat <<EOF | sudo tee /etc/default/kubelet
KUBELET_EXTRA_ARGS='--node-ip ${PRIMARY_IP}'
EOF
