#!/bin/bash

#update package
yum install -y epel-release
yum update -y
yum install -y net-tools telnet nfs-utils lrzsz nano chrony yum-utils curl

# sync time now
timedatectl set-timezone Asia/Taipei
systemctl enable chronyd
systemctl start chronyd
sudo chronyc -a makestep

# install docker
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce

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

# change max open file for docker
mkdir -p /etc/systemd/system/docker.service.d/
>/etc/systemd/system/docker.service.d/override.conf << EOF 
[Service]
LimitNOFILE=1000000  
LimitMEMLOCK=infinity
EOF
systemctl daemon-reload  

systemctl enable docker
systemctl restart docker

# install docker-compose
sudo curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose


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
vm.max_map_count=262144
net.ipv4.ip_local_port_range = 1024 65535 
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_max_syn_backlog = 65536
net.core.somaxconn = 65536
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000   915000000   927000000
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_max_orphans = 3276800
net.core.netdev_max_backlog = 500000
net.core.rmem_default = 8388608
net.core.wmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.bridge.bridge-nf-call-ip6tables = 1  
net.bridge.bridge-nf-call-iptables = 1  
net.bridge.bridge-nf-call-arptables = 1
fs.aio-max-nr=1048576
fs.file-max = 1048575
kernel.panic = 1
EOF

/sbin/sysctl -p /etc/sysctl.conf











