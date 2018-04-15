# kubebin

* version `https://dl.k8s.io/release/stable.txt`
* kubebin `https://storage.googleapis.com/kubernetes-release/release/v1.10.0/bin/linux/amd64/{kubeadm,kubelet,kubectl}`
* **kubelet.service** `https://raw.githubusercontent.com/kubernetes/kubernetes/v1.10.0/build/debs/kubelet.service`
* **10-kubeadm.conf** `https://raw.githubusercontent.com/kubernetes/kubernetes/v1.10.0/build/debs/10-kubeadm.conf`
* **cni-plugins** `https://github.com/containernetworking/plugins/releases/download/v0.6.0/cni-plugins-amd64-v0.6.0.tgz`
* **calico** `https://github.com/projectcalico/cni-plugin/releases/download/v2.0.3/calico`
* **calico-ipam** `https://github.com/projectcalico/cni-plugin/releases/download/v2.0.3/calico-ipam`

### Install Docker

[Install Docker CE for CentOS](https://docs.docker.com/install/linux/docker-ce/centos/)

#### Uninstall old versions
```
yum remove docker \
  docker-client \
  docker-client-latest \
  docker-common \
  docker-latest \
  docker-latest-logrotate \
  docker-logrotate \
  docker-selinux \
  docker-engine-selinux \
  docker-engine-selinuxcker-engine
```

#### Before
```
yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2
```
```
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
```
```
yum-config-manager --enable docker-ce-edge
#yum-config-manager --disable docker-ce-edge
```

#### Install
```
yum install -y docker-ce
```

#### Config Docker
`/etc/docker/daemon.json`
```
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
```

