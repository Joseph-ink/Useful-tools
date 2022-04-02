#!/usr/bin/env bash
Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"
copyright(){
    clear
echo "\
############################################################

Linux网络优化脚本 MOD

Forked from Neko Neko Cloud

############################################################
"
}


tcp_optimize(){ # 优化TCP窗口
sed -i '/net.ipv4.tcp_no_metrics_save/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_frto/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_mtu_probing/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_rfc1337/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_adv_win_scale/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_moderate_rcvbuf/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_rmem/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_wmem/d' /etc/sysctl.conf
sed -i '/net.core.rmem_max/d' /etc/sysctl.conf
sed -i '/net.core.wmem_max/d' /etc/sysctl.conf
sed -i '/net.ipv4.udp_rmem_min/d' /etc/sysctl.conf
sed -i '/net.ipv4.udp_wmem_min/d' /etc/sysctl.conf
sed -i '/net.core.rmem_default/d' /etc/sysctl.conf
sed -i '/net.core.wmem_default/d' /etc/sysctl.conf
sed -i '/net.core.netdev_max_backlog/d' /etc/sysctl.conf
sed -i '/net.core.somaxconn/d' /etc/sysctl.conf
sed -i 'net.core.optmem_max' /etc/sysctl.conf
sed -i 'net.ipv4.tcp_mem' /etc/sysctl.conf
sed -i 'net.ipv4.tcp_keepalive_time' /etc/sysctl.conf
sed -i 'net.ipv4.tcp_keepalive_intvl' /etc/sysctl.conf
sed -i 'net.ipv4.tcp_keepalive_probes' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_sack/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_fack/d' /etc/sysctl.conf
sed -i 'net.ipv4.tcp_timestamps' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_window_scaling/d' /etc/sysctl.conf
sed -i 'net.ipv4.tcp_syncookies' /etc/sysctl.conf
sed -i 'net.ipv4.tcp_tw_reuse' /etc/sysctl.conf
sed -i 'net.ipv4.tcp_fin_timeout' /etc/sysctl.conf
sed -i 'net.ipv4.tcp_max_syn_backlog' /etc/sysctl.conf
sed -i 'net.ipv4.tcp_low_latency' /etc/sysctl.conf
sed -i 'net.ipv4.ip_local_port_range' /etc/sysctl.conf
cat >> /etc/sysctl.conf << EOF
net.ipv4.tcp_no_metrics_save=1
net.ipv4.tcp_frto=0
net.ipv4.tcp_mtu_probing=0
net.ipv4.tcp_rfc1337=1
net.ipv4.tcp_adv_win_scale=2
net.ipv4.tcp_moderate_rcvbuf=1
net.ipv4.tcp_rmem=4096 65536 37331520
net.ipv4.tcp_wmem=4096 65536 37331520
net.core.rmem_max=37331520
net.core.wmem_max=37331520
net.ipv4.udp_rmem_min=8192
net.ipv4.udp_wmem_min=8192
net.core.rmem_default=212992
net.core.wmem_default=212992
net.core.netdev_max_backlog=10000
net.core.somaxconn=2048
net.core.optmem_max=81920
net.ipv4.tcp_mem=5814 7754 11628
net.ipv4.tcp_keepalive_time=1800
net.ipv4.tcp_keepalive_intvl=30
net.ipv4.tcp_keepalive_probes=3
net.ipv4.tcp_sack=1
net.ipv4.tcp_fack=1
net.ipv4.tcp_timestamps=1
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_syncookies=1
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_fin_timeout=30
net.ipv4.tcp_max_syn_backlog=128
net.ipv4.tcp_low_latency=0
net.ipv4.ip_local_port_range=1024 65000
EOF
sysctl -p && sysctl --system
}

bbr_fq(){ # 启用BBR更换队列算法
sed -i '/net.ipv4.tcp_ecn/d' /etc/sysctl.conf
sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
cat >> /etc/sysctl.conf << EOF
net.ipv4.tcp_ecn=0
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF
sysctl -p && sysctl --system
}

bbr_fq_pie(){ # 启用BBR更换队列算法
sed -i '/net.ipv4.tcp_ecn/d' /etc/sysctl.conf
sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
cat >> /etc/sysctl.conf << EOF
net.ipv4.tcp_ecn=0
net.core.default_qdisc=fq_pie
net.ipv4.tcp_congestion_control=bbr
EOF
sysctl -p && sysctl --system
}

bbr_cake(){ # 启用BBR更换队列算法
sed -i '/net.ipv4.tcp_ecn/d' /etc/sysctl.conf
sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
cat >> /etc/sysctl.conf << EOF
net.ipv4.tcp_ecn=0
net.core.default_qdisc=cake
net.ipv4.tcp_congestion_control=bbr
EOF
sysctl -p && sysctl --system
}

bbr2_fq(){ # 启用BBR2更换队列算法
sed -i '/net.ipv4.tcp_ecn/d' /etc/sysctl.conf
sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
cat >> /etc/sysctl.conf << EOF
net.ipv4.tcp_ecn=0
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr2
EOF
sysctl -p && sysctl --system
}

bbr2_fq_pie(){ # 启用BBR2更换队列算法
sed -i '/net.ipv4.tcp_ecn/d' /etc/sysctl.conf
sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
cat >> /etc/sysctl.conf << EOF
net.ipv4.tcp_ecn=0
net.core.default_qdisc=fq_pie
net.ipv4.tcp_congestion_control=bbr2
EOF
sysctl -p && sysctl --system
}

bbr2_cake(){ # 启用BBR2更换队列算法
sed -i '/net.ipv4.tcp_ecn/d' /etc/sysctl.conf
sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
cat >> /etc/sysctl.conf << EOF
net.ipv4.tcp_ecn=0
net.core.default_qdisc=cake
net.ipv4.tcp_congestion_control=bbr2
EOF
sysctl -p && sysctl --system
}

bbr2_fq_ecn(){ # 启用BBR2更换队列算法开启显示加速
sed -i '/net.ipv4.tcp_ecn/d' /etc/sysctl.conf
sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
cat >> /etc/sysctl.conf << EOF
net.ipv4.tcp_ecn=1
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr2
EOF
sysctl -p && sysctl --system
}

bbr2_fq_pie_ecn(){ # 启用BBR2更换队列算法开启显示加速
sed -i '/net.ipv4.tcp_ecn/d' /etc/sysctl.conf
sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
cat >> /etc/sysctl.conf << EOF
net.ipv4.tcp_ecn=1
net.core.default_qdisc=fq_pie
net.ipv4.tcp_congestion_control=bbr2
EOF
sysctl -p && sysctl --system
}

bbr2_cake_ecn(){ # 启用BBR2更换队列算法开启显示加速
sed -i '/net.ipv4.tcp_ecn/d' /etc/sysctl.conf
sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
cat >> /etc/sysctl.conf << EOF
net.ipv4.tcp_ecn=1
net.core.default_qdisc=cake
net.ipv4.tcp_congestion_control=bbr2
EOF
sysctl -p && sysctl --system
}

arp_buffer(){ #扩大ARP缓冲
sed -i '/net.ipv4.neigh.default.gc_thresh1/d' /etc/sysctl.conf
sed -i '/net.ipv4.neigh.default.gc_thresh2/d' /etc/sysctl.conf
sed -i '/net.ipv4.neigh.default.gc_thresh3/d' /etc/sysctl.conf
cat >> '/etc/sysctl.conf' << EOF
net.ipv4.neigh.default.gc_thresh1=1024
net.ipv4.neigh.default.gc_thresh2=4096
net.ipv4.neigh.default.gc_thresh3=8192
EOF
sysctl -p && sysctl --system
}

enable_forwarding(){ #开启内核转发
sed -i '/net.ipv4.conf.all.route_localnet/d' /etc/sysctl.conf
sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf
sed -i '/net.ipv4.conf.all.forwarding/d' /etc/sysctl.conf
sed -i '/net.ipv6.conf.all.forwarding/d' /etc/sysctl.conf
sed -i '/net.ipv4.conf.default.forwarding/d' /etc/sysctl.conf
cat >> '/etc/sysctl.conf' << EOF
net.ipv4.conf.all.route_localnet=1
net.ipv4.ip_forward=1
net.ipv4.conf.all.forwarding=1
net.ipv6.conf.all.forwarding=1
net.ipv4.conf.default.forwarding=1
EOF
sysctl -p && sysctl --system
}

ulimit_tune(){

echo "1000000" > /proc/sys/fs/file-max
ulimit -SHn 1000000 && ulimit -c unlimited
echo "root     soft   nofile    1000000
root     hard   nofile    1000000
root     soft   nproc     1000000
root     hard   nproc     1000000
root     soft   core      1000000
root     hard   core      1000000
root     hard   memlock   unlimited
root     soft   memlock   unlimited

*     soft   nofile    1000000
*     hard   nofile    1000000
*     soft   nproc     1000000
*     hard   nproc     1000000
*     soft   core      1000000
*     hard   core      1000000
*     hard   memlock   unlimited
*     soft   memlock   unlimited
">/etc/security/limits.conf
if grep -q "ulimit" /etc/profile; then
  :
else
  sed -i '/ulimit -SHn/d' /etc/profile
  echo "ulimit -SHn 1000000" >>/etc/profile
fi
if grep -q "pam_limits.so" /etc/pam.d/common-session; then
  :
else
  sed -i '/required pam_limits.so/d' /etc/pam.d/common-session
  echo "session required pam_limits.so" >>/etc/pam.d/common-session
fi

sed -i '/DefaultTimeoutStartSec/d' /etc/systemd/system.conf
sed -i '/DefaultTimeoutStopSec/d' /etc/systemd/system.conf
sed -i '/DefaultRestartSec/d' /etc/systemd/system.conf
sed -i '/DefaultLimitCORE/d' /etc/systemd/system.conf
sed -i '/DefaultLimitNOFILE/d' /etc/systemd/system.conf
sed -i '/DefaultLimitNPROC/d' /etc/systemd/system.conf

cat >>'/etc/systemd/system.conf' <<EOF
[Manager]
#DefaultTimeoutStartSec=90s
DefaultTimeoutStopSec=10s
#DefaultRestartSec=100ms
DefaultLimitCORE=infinity
DefaultLimitNOFILE=65535
DefaultLimitNPROC=65535
EOF

systemctl daemon-reload

}


get_opsy() {
  [ -f /etc/redhat-release ] && awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release && return
  [ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
  [ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
}
virt_check() {
  # if hash ifconfig 2>/dev/null; then
  # eth=$(ifconfig)
  # fi

  virtualx=$(dmesg) 2>/dev/null

  if [[ $(which dmidecode) ]]; then
    sys_manu=$(dmidecode -s system-manufacturer) 2>/dev/null
    sys_product=$(dmidecode -s system-product-name) 2>/dev/null
    sys_ver=$(dmidecode -s system-version) 2>/dev/null
  else
    sys_manu=""
    sys_product=""
    sys_ver=""
  fi

  if grep docker /proc/1/cgroup -qa; then
    virtual="Docker"
  elif grep lxc /proc/1/cgroup -qa; then
    virtual="Lxc"
  elif grep -qa container=lxc /proc/1/environ; then
    virtual="Lxc"
  elif [[ -f /proc/user_beancounters ]]; then
    virtual="OpenVZ"
  elif [[ "$virtualx" == *kvm-clock* ]]; then
    virtual="KVM"
  elif [[ "$cname" == *KVM* ]]; then
    virtual="KVM"
  elif [[ "$cname" == *QEMU* ]]; then
    virtual="KVM"
  elif [[ "$virtualx" == *"VMware Virtual Platform"* ]]; then
    virtual="VMware"
  elif [[ "$virtualx" == *"Parallels Software International"* ]]; then
    virtual="Parallels"
  elif [[ "$virtualx" == *VirtualBox* ]]; then
    virtual="VirtualBox"
  elif [[ -e /proc/xen ]]; then
    virtual="Xen"
  elif [[ "$sys_manu" == *"Microsoft Corporation"* ]]; then
    if [[ "$sys_product" == *"Virtual Machine"* ]]; then
      if [[ "$sys_ver" == *"7.0"* || "$sys_ver" == *"Hyper-V" ]]; then
        virtual="Hyper-V"
      else
        virtual="Microsoft Virtual Machine"
      fi
    fi
  else
    virtual="Dedicated母鸡"
  fi
}
get_system_info() {
  cname=$(awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//')
  #cores=$(awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo)
  #freq=$(awk -F: '/cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//')
  #corescache=$(awk -F: '/cache size/ {cache=$2} END {print cache}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//')
  #tram=$(free -m | awk '/Mem/ {print $2}')
  #uram=$(free -m | awk '/Mem/ {print $3}')
  #bram=$(free -m | awk '/Mem/ {print $6}')
  #swap=$(free -m | awk '/Swap/ {print $2}')
  #uswap=$(free -m | awk '/Swap/ {print $3}')
  #up=$(awk '{a=$1/86400;b=($1%86400)/3600;c=($1%3600)/60} {printf("%d days %d hour %d min\n",a,b,c)}' /proc/uptime)
  #load=$(w | head -1 | awk -F'load average:' '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//')
  opsy=$(get_opsy)
  arch=$(uname -m)
  #lbit=$(getconf LONG_BIT)
  kern=$(uname -r)
  # disk_size1=$( LANG=C df -hPl | grep -wvE '\-|none|tmpfs|overlay|shm|udev|devtmpfs|by-uuid|chroot|Filesystem' | awk '{print $2}' )
  # disk_size2=$( LANG=C df -hPl | grep -wvE '\-|none|tmpfs|overlay|shm|udev|devtmpfs|by-uuid|chroot|Filesystem' | awk '{print $3}' )
  # disk_total_size=$( calc_disk ${disk_size1[@]} )
  # disk_used_size=$( calc_disk ${disk_size2[@]} )
  #tcpctrl=$(sysctl net.ipv4.tcp_congestion_control | awk -F ' ' '{print $3}')
  virt_check
}

menu() {
  echo -e "\
${Green_font_prefix}1.${Font_color_suffix} 优化TCP窗口
${Green_font_prefix}2.${Font_color_suffix} 启用bbr+fq
${Green_font_prefix}3.${Font_color_suffix} 启用bbr+fq_pie
${Green_font_prefix}4.${Font_color_suffix} 启用bbr+cake
${Green_font_prefix}5.${Font_color_suffix} 启用bbr2+fq
${Green_font_prefix}6.${Font_color_suffix} 启用bbr2+fq_pie
${Green_font_prefix}7.${Font_color_suffix} 启用bbr2+cake
${Green_font_prefix}8.${Font_color_suffix} 启用bbr2+fq_ecn
${Green_font_prefix}9.${Font_color_suffix} 启用bbr2+fq_pie+ecn
${Green_font_prefix}10.${Font_color_suffix} 启用bbr2+cake+ecn
${Green_font_prefix}11.${Font_color_suffix} 扩大ARP缓冲
${Green_font_prefix}12.${Font_color_suffix} 开启内核转发
${Green_font_prefix}13.${Font_color_suffix} 系统资源限制调优
"
get_system_info
echo -e "当前系统信息: ${Font_color_suffix}$opsy ${Green_font_prefix}$virtual${Font_color_suffix} $arch ${Green_font_prefix}$kern${Font_color_suffix}
"

  read -p "请输入数字 :" num
  case "$num" in
  1)
    tcp_optimize
    ;;
  2)
    bbr_fq
    ;;
  3)
    bbr_fq_pie
    ;;
  4)
    bbr_cake
    ;;
  5)
    bbr2_fq
    ;;
  6)
    bbr2_fq_pie
    ;;
  7)
    bbr2_cake
    ;;
  8)
    bbr2_fq_ecn
    ;;
  9)
    bbr2_fq_pie_ecn
    ;;
  10)
    bbr2_cake_ecn
    ;;
  11)
    arp_buffer
    ;;
  12)
    enable_forwarding
    ;;
  13)
    ulimit_tune
    ;;
  *)
  clear
    echo -e "${Error}:请输入正确数字 [0-99]"
    sleep 5s
    start_menu
    ;;
  esac
}

copyright

menu