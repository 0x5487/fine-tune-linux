#!/bin/bash

#update package
yum install -y epel-release
yum update -y
yum install -y telnet nfs-utils lrzsz nano chrony yum-utils curl

# sync time now
timedatectl set-timezone Asia/Taipei
systemctl enable chronyd
systemctl start chronyd
sudo chronyc -a makestep

# install docker
# 安裝 docker，目前固定版號：18.06.1
wget -P /etc/yum.repos.d/ https://download.docker.com/linux/centos/docker-ce.repo
# 設定 yum 排除 docker 相關 package
sed /etc/yum.repos.d/docker-ce.repo -e '/^gpgkey/a exclude=docker-ce* containerd.io* docker-ce-cli*' -i
# 要安裝 docker 要額外取消排除設定
yum install docker-ce-18.06.1.ce-3.el7.x86_64 -y --disableexclude=docker-ce-stable


# change docker storage driver to overlay2
mkdir -p /etc/docker/
>/etc/docker/daemon.json cat << EOF 
{
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

# install docker-compose
sudo curl -L https://github.com/docker/compose/releases/download/1.23.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

#docker.service增加額外設定 & 18.09.0後增加的containerd.io套件
echo -e "[Service]\nExecStart=\nExecStart=/usr/bin/dockerd\nLimitNOFILE=1000000\nLimitMEMLOCK=infinity" | SYSTEMD_EDITOR=tee systemctl edit docker.service
echo -e "[Service]\nLimitNOFILE=1000000\nLimitMEMLOCK=infinity" | SYSTEMD_EDITOR=tee systemctl edit containerd.service
systemctl daemon-reload
systemctl enable containerd
systemctl enable docker
systemctl restart docker


# user level
if grep -Fxq "DefaultLimitCORE=infinity" /etc/systemd/user.conf
then
  echo "check User DefaultLimitCORE ok"
else
  echo "DefaultLimitCORE=infinity" >> /etc/systemd/user.conf
fi

if grep -Fxq "DefaultLimitNOFILE=1000000" /etc/systemd/user.conf
then
  echo "check User DefaultLimitNOFILE ok"
else
  echo "DefaultLimitNOFILE=1000000" >> /etc/systemd/user.conf
fi

if grep -Fxq "DefaultLimitNPROC=1000000" /etc/systemd/user.conf
then
  echo "check User DefaultLimitNPROC ok"
else
  echo "DefaultLimitNPROC=1000000" >> /etc/systemd/user.conf
fi


# system level
if grep -Fxq "DefaultLimitCORE=infinity" /etc/systemd/system.conf
then
  echo "check System DefaultLimitCORE ok"
else
  echo "DefaultLimitCORE=infinity" >> /etc/systemd/system.conf
fi

if grep -Fxq "DefaultLimitNOFILE=1000000" /etc/systemd/system.conf
then
  echo "check System DefaultLimitNOFILE ok"
else
  echo "DefaultLimitNOFILE=1000000" >> /etc/systemd/system.conf
fi

if grep -Fxq "DefaultLimitNPROC=1000000" /etc/systemd/system.conf
then
  echo "check System DefaultLimitNPROC ok"
else
  echo "DefaultLimitNPROC=1000000" >> /etc/systemd/system.conf
fi


>/etc/sysctl.conf cat << EOF 
vm.swappiness = 1
vm.overcommit_memory = 1
vm.max_map_count=262144
net.ipv4.ip_local_port_range = 1024 65535 
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_max_syn_backlog = 65536
net.core.somaxconn = 65535
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_forward= 1
net.ipv4.tcp_mem = 94500000   915000000   927000000
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_max_orphans = 3276800
net.core.netdev_max_backlog = 500000
net.core.rmem_default = 8388608
net.core.wmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.optmem_max = 819200
net.netfilter.nf_conntrack_max = 1048576
net.nf_conntrack_max = 1048576
net.bridge.bridge-nf-call-ip6tables = 1  
net.bridge.bridge-nf-call-iptables = 1  
net.bridge.bridge-nf-call-arptables = 1
fs.aio-max-nr=1048576
fs.file-max = 1048575
kernel.panic = 1
EOF

sudo sysctl -p











