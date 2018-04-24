#!/bin/bash

set -ex;

yum update -y;

yum install -y vim git;

# install Docker
yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2
yum-config-manager \
  --add-repo \
  https://download.docker.com/linux/centos/docker-ce.repo
yum-config-manager --enable docker-ce-edge
yum install -y docker-ce;

mkdir -p /etc/docker;
cat <<EOF > /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
systemctl start docker;

cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

mkdir bin;
cd bin;
wget https://storage.googleapis.com/kubernetes-release/release/v1.9.6/bin/linux/amd64/{kubeadm,kubelet,kubectl}
chmod 755 *
mkdir cni;
cd cni;
curl https://github.com/containernetworking/plugins/releases/download/v0.6.0/cni-plugins-amd64-v0.6.0.tgz |gzip -dc|tar x
wget https://github.com/projectcalico/cni-plugin/releases/download/v2.0.3/{calico,calico-ipam}
chmod 755 *

cd ../..
mv bin/ /usr/bin/

#
git clone https://github.com/ckeyer/kubebin -b use1.9
cp -a kubebin/etc/ /etc/

