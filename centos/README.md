#### 前置
1. yum install lrzsz
1. visudo


### Tcp 優化

```
vm.swappiness = 1
net.ipv4.ip_local_port_range = 1024 65535 
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_max_syn_backlog = 65536
net.core.somaxconn = 65536
net.ipv4.tcp_timestamps = 0


# 開啟SYN洪水攻擊保護
net.ipv4.tcp_syncookies = 1

######################## cat /proc/sys/net/ipv4/tcp_tw_recycle
# 默認值：0
# 作用：針對TIME-WAIT，不要開啟。不少文章提到同時開啟tcp_tw_recycle和tcp_tw_reuse，會帶來C/S在NAT方面的異常
# 個人接受的做法是，開啟tcp_tw_reuse，增加ip_local_port_range的範圍，減小tcp_max_tw_buckets和tcp_fin_timeout的值
# 參考：http://ju.outofmemory.cn/entry/91121, http://www.cnblogs.com/lulu/p/4149312.html
net.ipv4.tcp_tw_recycle = 0
 
######################## cat /proc/sys/net/ipv4/tcp_tw_reuse
# 默認值：0
# 作用：針對TIME-WAIT，做為客戶端可以啟用（例如，作為nginx-proxy前端代理，要訪問後端的服務）
net.ipv4.tcp_tw_reuse = 1

######################## cat /proc/sys/net/ipv4/tcp_mem
# 默認值：94389   125854  188778
# 作用：內存使用的下限  警戒值  上限
net.ipv4.tcp_mem = 94500000   915000000   927000000

######################## cat /proc/sys/net/ipv4/tcp_keepalive_time 
# 默認值：7200
# 作用：間隔多久發送1次keepalive探測包
net.ipv4.tcp_keepalive_time = 1200

######################## cat /proc/sys/net/ipv4/tcp_max_orphans 
# 默認值：16384
# 作用：orphans的最大值
net.ipv4.tcp_max_orphans = 3276800

######################## cat /proc/sys/net/core/netdev_max_backlog
# 默認值：1000
# 作用：網卡設備將請求放入隊列的長度
net.core.netdev_max_backlog = 500000

######################## cat /proc/sys/net/core/rmem_default
# 默認值：212992
# 作用：默認的TCP數據接收窗口大小（字節）
net.core.rmem_default = 8388608
 
######################## cat /proc/sys/net/core/wmem_default
# 默認值：212992
# 作用：默認的TCP數據發送窗口大小（字節）
net.core.wmem_default = 8388608
 
######################## cat /proc/sys/net/core/rmem_max
# 默認值：212992
# 作用：最大的TCP數據接收窗口大小（字節）
net.core.rmem_max = 16777216
 
######################## cat /proc/sys/net/core/wmem_max
# 默認值：212992
# 作用：最大的TCP數據發送窗口大小（字節）
net.core.wmem_max = 16777216


######################## cat /proc/sys/fs/aio-max-nr
# 默認值：65536
# 作用：aio最大值
fs.aio-max-nr=1048576
 
######################## cat /proc/sys/fs/file-max
# 默認值：98529
# 作用：文件描述符的最大值
fs.file-max = 1048575

######################## cat /proc/sys/kernel/panic
# 默認值：0
# 作用：內核panic時，1秒後自動重啟
kernel.panic = 1
```


參考:
http://nosmoking.blog.51cto.com/3263888/1684114
https://www.jianshu.com/p/f05294c0a456