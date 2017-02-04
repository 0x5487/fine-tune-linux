#!/bin/bash

echo '*  -  nofile  65535' >> /etc/security/limits.conf

cat >/etc/rc.local<<EOF
#open files
ulimit -HSn 65535
#stack size
ulimit -s 65535
EOF
