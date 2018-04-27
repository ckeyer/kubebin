# kubebin

## All Resources

* **version** `https://dl.k8s.io/release/stable.txt`
* **kubeadm,kubelet,kubectl** `https://storage.googleapis.com/kubernetes-release/release/v1.9.6/bin/linux/amd64/{kubeadm,kubelet,kubectl}`
* **kubelet.service** `https://raw.githubusercontent.com/kubernetes/kubernetes/v1.9.6/build/debs/kubelet.service`
* **10-kubeadm.conf** `https://raw.githubusercontent.com/kubernetes/kubernetes/v1.9.6/build/debs/10-kubeadm.conf`
* **cni-plugins** `https://github.com/containernetworking/plugins/releases/download/v0.6.0/cni-plugins-amd64-v0.6.0.tgz`
* **calico** `https://github.com/projectcalico/cni-plugin/releases/download/v2.0.3/{calico,calico-ipam}`


## Install Docker

[Install Docker CE for CentOS](https://docs.docker.com/install/linux/docker-ce/centos/)

### Uninstall old versions
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

### Before
```
yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2
yum-config-manager \
  --add-repo \
  https://download.docker.com/linux/centos/docker-ce.repo
yum-config-manager --enable docker-ce-edge

#yum-config-manager --disable docker-ce-edge
```

### Install
```
yum install -y docker-ce
```

### Config Docker
`/etc/docker/daemon.json`
```
mkdir -p /etc/docker
cat <<EOF > /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
systemctl start docker
```

## Install Kubernetes
### Config Kernel
```
cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
```

### Download Kube-bins

### Start kubelet

### Config kubeadm
`/etc/kubernetes/kubeadm.yaml`

### Pull Images
```
docker pull registry.cn-beijing.aliyuncs.com/wa/k8s-dns-kube-dns-amd64:1.14.8
docker tag registry.cn-beijing.aliyuncs.com/wa/k8s-dns-kube-dns-amd64:1.14.8 gcr.io/google_containers/k8s-dns-kube-dns-amd64:1.14.8
docker pull registry.cn-beijing.aliyuncs.com/wa/k8s-dns-dnsmasq-nanny-amd64:1.14.8
docker tag registry.cn-beijing.aliyuncs.com/wa/k8s-dns-dnsmasq-nanny-amd64:1.14.8 gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.8
docker pull registry.cn-beijing.aliyuncs.com/wa/k8s-dns-sidecar-amd64:1.14.8
docker tag registry.cn-beijing.aliyuncs.com/wa/k8s-dns-sidecar-amd64:1.14.8 gcr.io/google_containers/k8s-dns-sidecar-amd64:1.14.8

# docker pull registry.cn-beijing.aliyuncs.com/wa/k8s-dns-kube-dns-amd64:1.14.9
# docker tag registry.cn-beijing.aliyuncs.com/wa/k8s-dns-kube-dns-amd64:1.14.9 k8s.gcr.io/k8s-dns-kube-dns-amd64:1.14.9
# docker pull registry.cn-beijing.aliyuncs.com/wa/k8s-dns-dnsmasq-nanny-amd64:1.14.9
# docker tag registry.cn-beijing.aliyuncs.com/wa/k8s-dns-dnsmasq-nanny-amd64:1.14.9 k8s.gcr.io/k8s-dns-dnsmasq-nanny-amd64:1.14.9
# docker pull registry.cn-beijing.aliyuncs.com/wa/k8s-dns-sidecar-amd64:1.14.9
# docker tag registry.cn-beijing.aliyuncs.com/wa/k8s-dns-sidecar-amd64:1.14.9 k8s.gcr.io/k8s-dns-sidecar-amd64:1.14.9


```


### Init Cluster
`kubeadm init --config /etc/kubernetes/kubeadm.yaml`

### After
```
mkdir -p $HOME/.kube/
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
```

### Init Networks
#### Calico (v2.6)
[Quickstart](https://docs.projectcalico.org/v2.6/getting-started/kubernetes/)

```
kubectl apply -f \
  https://docs.projectcalico.org/v2.6/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml
```

#### Calico (v3.1)
[Quickstart](https://docs.projectcalico.org/v3.1/getting-started/kubernetes/)

```
  https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/rbac.yaml
  https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/calico.yaml
```
配置etcd, 启动


