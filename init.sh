#!/bin/bash

set -ex;

MASTER_IP=172.26.149.78
#yum update -y;
#which sh || yum install which ;

color_echo() {
  if [ $1 == "green" ]; then
    echo -e "\033[32;40m$2\033[0m"
  elif [ $1 == "red" ]; then
    echo -e "\033[31;40m$2\033[0m"
  fi
}

# Install Docker
install_docker() {
  yum install -y yum-utils \
   device-mapper-persistent-data \
   lvm2;
  yum-config-manager \
   --add-repo \
   https://download.docker.com/linux/centos/docker-ce.repo;
  yum-config-manager --enable docker-ce-edge;
  # yum-config-manager --disable docker-ce-edge
  yum install -y docker-ce;
  systemctl enable docker;
  systemctl start docker;
}

init_net_kernel() {
  which /etc/sysctl.d/k8s.conf || cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
  sysctl --system
}

download_kube_bins() {
  rm -rf /tmp/kubebin;
  mkdir -p /tmp/kubebin;
  cd /tmp/kubebin;
  wget http://p98hfhay7.bkt.clouddn.com/kubebin1.10.3.tar.gz;
  cd /usr/bin;
  tar zxvf /tmp/kubebin/kubebin1.10.3.tar.gz;
}

download_cin_bins() {
  rm -rf /tmp/cni;
  mkdir -p /tmp/cni;
  cd /tmp/cni;
  wget http://p98hfhay7.bkt.clouddn.com/cni-0.7.1.tar.gz;

  # wget https://github.com/containernetworking/plugins/releases/download/v0.6.0/cni-plugins-amd64-v0.6.0.tgz
  # wget https://github.com/projectcalico/cni-plugin/releases/download/v2.0.5/{calico,calico-ipam}
  # chmod +x calico calico-ipam

  mkdir -p /opt/cni/bin ;
  ln -s /opt/cni/bin /usr/bin/cni;
  cd /opt/cni/bin ;
  # mv /tmp/cni/calico /opt/cni/bin/;
  # mv /tmp/cni/calico-ipam /opt/cni/bin/;
  tar zxvf /tmp/cni/cni-0.7.1.tar.gz;
}

init_kubeadm() {
  kubeadm reset;
  kubeadm init --config /etc/kubernetes/kubeadm.yaml;
  mkdir -p $HOME/.kube/;
  cp -i /etc/kubernetes/admin.conf $HOME/.kube/config;
}

start_kubelet() {
  systemctl enable kubelet;
  systemctl start kubelet;
}

init_calico() {
  kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml;
  kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml;
}

init_kubelet_config() {
  cat <<EOF > /etc/systemd/system/kubelet.service
[Unit]
Description=kubelet: The Kubernetes Node Agent
Documentation=http://kubernetes.io/docs/

[Service]
ExecStart=/usr/bin/kubelet
Restart=always
StartLimitInterval=0
RestartSec=10

[Install]
WantedBy=multi-user.target

EOF

  mkdir -p /etc/systemd/system/kubelet.service.d/ ;
  cat <<EOF > /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_SYSTEM_PODS_ARGS=--pod-manifest-path=/etc/kubernetes/manifests --allow-privileged=true --pod-infra-container-image=registry.cn-beijing.aliyuncs.com/wa/pause-amd64:3.1"
Environment="KUBELET_NETWORK_ARGS=--network-plugin=cni --cni-conf-dir=/etc/cni/net.d --cni-bin-dir=/usr/bin/cni"
Environment="KUBELET_DNS_ARGS=--cluster-dns=10.96.0.10 --cluster-domain=cluster.local"
Environment="KUBELET_AUTHZ_ARGS=--authorization-mode=Webhook --client-ca-file=/etc/kubernetes/pki/ca.crt"
# Value should match Docker daemon settings.
# Defaults are "cgroupfs" for Debian/Ubuntu/OpenSUSE and "systemd" for Fedora/CentOS/RHEL
# Environment="KUBELET_CGROUP_ARGS=--cgroup-driver=systemd"
Environment="KUBELET_CADVISOR_ARGS=--cadvisor-port=10257"
Environment="KUBELET_CERTIFICATE_ARGS=--rotate-certificates=true"
Environment="KUBELET_NODE_IP=--node-ip ${MASTER_IP}"
ExecStart=
ExecStart=/usr/bin/kubelet \\
 \$KUBELET_KUBECONFIG_ARGS \\
 \$KUBELET_SYSTEM_PODS_ARGS \\
 \$KUBELET_NETWORK_ARGS \\
 \$KUBELET_DNS_ARGS \\
 \$KUBELET_AUTHZ_ARGS \\
 \$KUBELET_CGROUP_ARGS \\
 \$KUBELET_CADVISOR_ARGS \\
 \$KUBELET_CERTIFICATE_ARGS \\
 \$KUBELET_EXTRA_ARGS \\
 \$KUBELET_NODE_IP

EOF
}

init_kubeadm_config() {
  mkdir -p /etc/kubernetes/;
  cat <<EOF > /etc/kubernetes/kubeadm.yaml
kubernetesVersion: v1.10.3
api:
  advertiseAddress: ${MASTER_IP}
  bindPort: 6443
apiServerExtraArgs:
  service-node-port-range: 30000-60000
authorizationModes:
- Node
- RBAC
certificatesDir: /etc/kubernetes/pki
etcd:
  # endpoints:
  #   - http://127.0.0.1:2379
  image: registry.cn-beijing.aliyuncs.com/wa/etcd:v3.3
imageRepository: registry.cn-beijing.aliyuncs.com/wa
kubeletConfiguration:
  clusterDomain: kubedev.ckeyer.com
kubeProxy:
  config:
    bindAddress: 0.0.0.0
    mode: "iptables"
    portRange: "30000-60000"
    metricsBindAddress: 127.0.0.1:10249
networking:
  dnsDomain: kubedev.ckeyer.com
  podSubnet: 10.100.0.0/16
  serviceSubnet: 10.96.0.0/12
noTaintMaster: true

EOF
}

which docker || install_docker;
which kubelet || download_kube_bins;
test -f /opt/cni/bin/calico-ipam || download_cin_bins;
init_net_kernel;
init_kubelet_config;
init_kubeadm_config;
start_kubelet;
init_kubeadm;
init_calico;
