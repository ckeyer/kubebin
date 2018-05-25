# kubebin

## All Resources

* **version** `https://dl.k8s.io/release/stable.txt`
* **kubeadm,kubelet,kubectl** `https://storage.googleapis.com/kubernetes-release/release/v1.9.6/bin/linux/amd64/{kubeadm,kubelet,kubectl}`
* **kubelet.service** `https://raw.githubusercontent.com/kubernetes/kubernetes/v1.9.6/build/debs/kubelet.service`
* **10-kubeadm.conf** `https://raw.githubusercontent.com/kubernetes/kubernetes/v1.9.6/build/debs/10-kubeadm.conf`
* **cni-plugins** `https://github.com/containernetworking/plugins/releases/download/v0.6.0/cni-plugins-amd64-v0.6.0.tgz`
* **calico** `https://github.com/projectcalico/cni-plugin/releases/download/v2.0.5/{calico,calico-ipam}`
* **calico-ipam** `https://github.com/projectcalico/cni-plugin/releases/download/v2.0.5/calico-ipam`

## At Qiniu

* http://p98hfhay7.bkt.clouddn.com/cni-0.7.1.tar.gz
* http://p98hfhay7.bkt.clouddn.com/kubebin1.10.2.tar.gz
* http://p98hfhay7.bkt.clouddn.com/kubebin1.10.3.tar.gz

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

### Install Docker
```
yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2

yum-config-manager \
  --add-repo \
  https://download.docker.com/linux/centos/docker-ce.repo

yum-config-manager --enable docker-ce-edge
# yum-config-manager --disable docker-ce-edge

yum install -y docker-ce
```

### Config Docker
```
mkdir -p /etc/docker/
cat <<EOF > /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF

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
```
cd /tmp ;
wget http://p98hfhay7.bkt.clouddn.com/cni-0.7.1.tar.gz ;
wget http://p98hfhay7.bkt.clouddn.com/kubebin1.10.3.tar.gz ;


mkdir -p /opt/cni/bin ;
cd /opt/cni/bin ;
tar zxvf /tmp/cni-0.7.1.tar.gz ;
cp -a /opt/cni/bin/ /usr/bin/cni/

cd /usr/bin ;
tar zxvf /tmp/kubebin1.10.3.tar.gz ;
```


### Start kubelet

### Config kubeadm

* https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/#config-file

```
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
Environment="KUBELET_CGROUP_ARGS=--cgroup-driver=systemd"
Environment="KUBELET_CADVISOR_ARGS=--cadvisor-port=10257"
Environment="KUBELET_CERTIFICATE_ARGS=--rotate-certificates=true"
#Environment="KUBELET_NODE_IP=--node-ip 10.1.64.212"
ExecStart=
ExecStart=/usr/bin/kubelet \
 $KUBELET_KUBECONFIG_ARGS \
 $KUBELET_SYSTEM_PODS_ARGS \
 $KUBELET_NETWORK_ARGS \
 $KUBELET_DNS_ARGS \
 $KUBELET_AUTHZ_ARGS \
 $KUBELET_CGROUP_ARGS \
 $KUBELET_CADVISOR_ARGS \
 $KUBELET_CERTIFICATE_ARGS \
 $KUBELET_EXTRA_ARGS \
 $KUBELET_NODE_IP
EOF

```

```
mkdir -p /etc/kubernetes/;
cat <<EOF > /etc/kubernetes/kubeadm.yaml
kubernetesVersion: v1.10.3
api:
  advertiseAddress: 10.1.64.212
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
EOF

```

### Init Cluster
```
kubeadm init --config /etc/kubernetes/kubeadm.yaml
```

### After
```
mkdir -p $HOME/.kube/
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
```

### Init Networks
#### Calico (v2.6)
[Quickstart](https://docs.projectcalico.org/v2.6/getting-started/kubernetes/)

```
kubectl delete -f \
  https://docs.projectcalico.org/v2.6/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml
```

#### Calico (v3.1)
```
kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml

```
