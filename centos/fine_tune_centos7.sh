#!/bin/bash

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
fs.aio-max-nr=1048576
fs.file-max = 1048575
kernel.panic = 1
EOF

/sbin/sysctl -p /etc/sysctl.conf



# install default package
[ -z "$(rpm -qa|grep ntp)" ] && yum install ntp -y

[ -z "$(rpm -qa|grep nano)" ] && yum install nano -y

\cp -rf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime &>>install.log

systemctl stop ntpd

/usr/sbin/ntpdate asia.pool.ntp.org

systemctl enable ntpd

systemctl start ntpd