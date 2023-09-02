**一些工具的整理，方便个人对于vps的管理**

## 更换Linux内核
### 更换内核和开启BBR脚本 
```
wget -N --no-check-certificate "https://raw.githubusercontent.com/Joseph-ink/Useful-tools/main/tcp_test.sh" && chmod +x tcp_test.sh && ./tcp_test.sh
```

使用最新的xanmod内核（仅支持Debian和Ubuntu AMD64架构）
```
wget -N --no-check-certificate "https://raw.githubusercontent.com/Joseph-ink/Useful-tools/main/xanmod.sh" && chmod +x xanmod.sh && ./xanmod.sh
```

### 网络和系统优化脚本
支持各种队列算法，需使用对应内核
```
bash <(curl -Ls https://raw.githubusercontent.com/Joseph-ink/Useful-tools/main/tools_vv.sh)
```
### 解除系统文件限制
```
wget -N --no-check-certificate "https://raw.githubusercontent.com/Joseph-ink/Useful-tools/main/unlimit.sh" && chmod +x unlimit.sh && ./unlimit.sh
```

## 网卡
### 修改NIC缓冲
```
# 查看网卡支持范围（设置参数必须小于Pre-set maximums）
ethtool -g eth0
# 调整缓冲大小（举例）
ethtool -G eth0 rx 4096 tx 4096 rx-jumbo 4096
```
### 启用网卡硬件特征
```
# 查看网卡支持的所有特性和当前的设置
ethtool -k eth0
# 开启具体特性
ethtool -K eth0 rx-gro-list on rx-udp-gro-forwarding on
```

## TuneD调优工具
```
#安装
apt install tuned tuned-gtk tuned-utils tuned-utils-systemtap
#查看所有可选配置
tuned-adm list
#启用配置 network-throughput
（对于限定性能基线机型建议采用balanced）
tuned-adm profile network-throughput
#查看当前状态
tuned-adm active
#关闭
tuned-adm off
```

## 系统更新
### 更新Ubuntu 22.04 LTS
替换 focal 为 jammy
```
sed -i 's/focal/jammy/g' /etc/apt/sources.list
sed -i 's/focal/jammy/g' /etc/apt/sources.list.d/*.list
```

### Debian 11 升级 12
```
sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list
sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list.d/*.list
```
```
sed -i 's/non-free/non-free non-free-firmware/g' /etc/apt/sources.list
```
### Debian软件源使用testing分支
```
deb http://deb.debian.org/debian testing main contrib non-free non-free-firmware
deb http://deb.debian.org/debian testing-updates main contrib non-free non-free-firmware
deb http://deb.debian.org/debian-security testing-security main contrib non-free non-free-firmware
```

### 一键DD脚本（默认Debian 11）
```
bash <(wget --no-check-certificate -qO- 'https://raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh') -d 11 -v 64 -p "自定义root密码" -port "自定义ssh端口"
```

### Geekbench6 linux性能测试
```
x86-64
https://cdn.geekbench.com/Geekbench-6.1.0-Linux.tar.gz
aarch64
https://cdn.geekbench.com/Geekbench-6.1.0-LinuxARMPreview.tar.gz
```

## 网络相关

### 查看qdisc队列算法支持情况
```
grep '^CONFIG_NET_SCH_' /boot/config-$(uname -r)
```

### 使用ACME.sh脚本进行TLS证书申请
```
# 安装 ACME.sh脚本
curl https://get.acme.sh | sh
# 国内环境可尝试
wget -O -  https://get.acme.sh | sh -s email=my@example.com

# 设置 Cloudflare API 令牌（依照自己账号的信息）
export CF_Key="4f9794c701b6e27884f0da0bab6454de07552"
export CF_Email="bozai@v2rayssr.com"

# 按ZeroSSL要求注册至自己的邮箱
~/.acme.sh/acme.sh --register-account -m my@example.com

# 验证DNS并申请证书
~/.acme.sh/acme.sh --issue --dns dns_cf -d bozai3.xyz
mkdir /root/cert
~/.acme.sh/acme.sh --installcert -d bozai3.xyz --key-file /root/cert/private.key --fullchain-file /root/cert/cert.crt
~/.acme.sh/acme.sh --upgrade --auto-upgrade
chmod -R 755 /root/cert
```

### 推荐使用nexttrace 追踪路由
```
# Linux 一键安装脚本
bash <(curl -Ls https://raw.githubusercontent.com/xgadget-lab/nexttrace/main/nt_install.sh)
# macOS brew 安装命令
brew tap xgadget-lab/nexttrace && brew install nexttrace
#执行
nexttrace ip
```

### 设置WARP Socks5代理
```
wget -N --no-check-certificate "https://raw.githubusercontent.com/Joseph-ink/Useful-tools/main/warp.sh" && chmod +x warp.sh && ./warp.sh
```
### Warp官方客户端激活PLUS账号
```
warp-cli set-license <your-warp-plus-license-key>
```

### Speedtest-Cli 测速
```
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
apt-get install speedtest
speedtest
```

### Ubuntu挂载IPv6地址
一、临时方法
注意替换网卡名称，以及替换[ipv6]为你的可用ipv6地址
```
ifconfig eth0 inet6 add [ipv6]/64 up
```
二、持久方法
在 /etc/netplan/ 目录下找到yaml配置文件，其中增加以下内容，同样替换[ipv6]为你的可用ipv6地址
```
dhcp6: no
addresses:
  - ipv6/64
```
使用管理员权限使其生效
```
sudo netplan apply
```

### 源码安装iproute2支持bbrv3新特性(相关依赖参考repo)
```
git clone git://git.kernel.org/pub/scm/network/iproute2/iproute2.git
cd iproute2
在iproute2根目录下创建patches文件夹
mkdir -p patches
cd patches
将bbrv3的三个补丁放入其中
wget https://raw.githubusercontent.com/google/bbr/v3/0001-ss-output-TCP-BBRv3-diag-information.patch
wget https://raw.githubusercontent.com/google/bbr/v3/0002-ip-introduce-the-ecn_low-per-route-feature.patch
wget https://raw.githubusercontent.com/google/bbr/v3/0003-ss-display-ecn_low-if-tcp_info-tcpi_options-TCPI_OPT.patch
cd ..
patch -p1 < patches/0001-ss-output-TCP-BBRv3-diag-information.patch
patch -p1 < patches/0002-ip-introduce-the-ecn_low-per-route-feature.patch
patch -p1 < patches/0003-ss-display-ecn_low-if-tcp_info-tcpi_options-TCPI_OPT.patch
make
sudo make install
ip -V
```

### 修改IPv6网关
```
# 使用 route 命令临时增加（重启后失效）
route add -A inet6 default gw <ipv6address>
# 编辑固化 /etc/network/interfaces.d/*
iface eth0 inet6 static
    address <ipv6address> # 主机IPv6地址
    netmask 64
    gateway <ipv6address> # IPv6网关地址
```

### CDN优选
#### 包含Cloudflare、Cloudfront ip段，数据来自BGP工具
```
# 如果是第一次使用，则建议创建新文件夹（后续更新请跳过该步骤）
mkdir CloudflareST

# 进入文件夹（后续更新，只需要从这里重复下面的下载、解压命令即可）
cd CloudflareST

# 下载 CloudflareST 压缩包
# x86_64
wget -N https://github.com/XIU2/CloudflareSpeedTest/releases/download/v2.2.4/CloudflareST_linux_amd64.tar.gz

# arm64
wget -N https://github.com/XIU2/CloudflareSpeedTest/releases/download/v2.2.4/CloudflareST_linux_arm64.tar.gz

# 解压
tar -zxf CloudflareST_linux_amd64.tar.gz

# 赋予执行权限
chmod +x CloudflareST

# IPv6优选：
# (可选)第一步：更换默认ipv6地址集，扫描Cloudflare全部ipv6 /48地址块（或者本地上传txt）
rm -rf ipv6.txt
wget -N --no-check-certificate https://raw.githubusercontent.com/Joseph-ink/Useful-tools/main/cf_ipv6_all.txt && chmod +x cf_ipv6_all.txt

#（可选）首次运行IPv6延迟测试，不含下载测速
# ./CloudflareST -f cf_ipv6.txt -p 200 -tll 15 -tl 150 -tlr 0.1 -dd
# 结果保存在result.csv，SSH也会显示

#（必选）将筛选后的低延迟HK IPv6进行速度测试
./CloudflareST -f cf_ipv6_hk.txt -p 200 -tll 15 -tl 150 -tlr 0.1

# IPv4优选：
rm -rf ip.txt
wget -N --no-check-certificate https://raw.githubusercontent.com/Joseph-ink/Useful-tools/main/cf_ipv4_all.txt && chmod +x cf_ipv4_all.txt
./CloudflareST -f cf_ipv4_all.txt -p 200 -tll 15 -tl 150

# 其他CDN IPv4优选（使用自定义测速链接和80端口HTTP下载）：
./CloudflareST -f cf_ipv4_all.txt -p 200 -tll 15 -tl 150 -tp 80 -url http://xxx/xxx

确认中港直连cloudflare地址段 详见cf_ipv6_hk.txt
```


## 管理和监控

### 切换VPS登录账号至root
请注意修改以下“password”为你需要设置的密码，请勿直接使用，防止简单密码爆破；
请切换至root账号或者使用sudo运行代码。
```
echo root:password |sudo chpasswd root
sed -i 's/^.*PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config;
sed -i 's/^.*PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config;
reboot
```

### Oracle Cloud VPS在ubuntu系统下会存在额外的防火墙，以下为删掉防火墙与端口限制命令
```
#开放所有端口
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -F
#Oracle自带的Ubuntu镜像默认设置了Iptable规则，关闭它
apt purge netfilter-persistent -y
#强制删除
rm -rf /etc/iptables && reboot
```

### 卸载腾讯云服务器自带监控
```
#卸载脚本
/usr/local/qcloud/stargate/admin/uninstall.sh
/usr/local/qcloud/YunJing/uninst.sh
/usr/local/qcloud/monitor/barad/admin/uninstall.sh
#停用服务
systemctl stop tat_agentsystemctl disable tat_agentrm -f /etc/systemd/system/tat_agent.service
#删除Cron中残留的定时任务
crontab -e
```
或者运行一键脚本
```
wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/Joseph-ink/Useful-tools/main/uninstall.sh" && chmod 700 /root/uninstall.sh && /root/uninstall.sh
```

## 编译相关

### Linux安装GCC编译器
```
apt install build-essential -y
```
查看版本号验证GCC安装成功
```
gcc --version
```

### Linux安装最新LLVM/Clang
```
bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"
export PATH=/usr/lib/llvm-17/bin:$PATH
```

### crates.io对应版本包下载地址规则
```
https://crates.io/api/v1/crates/{crate名}/{版本号}/download
```

```
举例：
ff-zeroize = { version = "0.6.3", features = [“derive”]}
下载路径为：
https://crates.io/api/v1/crates/ff-zeroize/0.6.3/download

下载后解压.crate文件得到源码文件夹；即可在Cargo.toml中指定 [dependencies] 依赖项的本地路径。
```

### target-cpu 指示 rustc 为特定处理器生成代码

可以查看当前平台指定cpu 参数传递的有效选项
```
rustc --print target-cpus
```
通过对比输出文本确定CPU特性是否被完全发现
```
rustc --print cfg
```
```
rustc --print cfg -C target-cpu=native
```
可以指定CPU进行核对,举例 skylake-avx512
```
rustc --print cfg -C target-cpu=skylake-avx512
```

### 处理Rust未引用依赖
```
rm Cargo.lock
cargo fix --allow-dirty
```

### 持久golang编译环境

编辑~/.bashrc文件
```
vi ~/.bashrc
```
文件的末尾添加
```
export PATH=$PATH:/usr/local/go/bin
```
保存并关闭文件，运行以下命令使改变立即生效
```
source ~/.bashrc
```

### 使用curl 命令来了解某个网站是否有HTTP/2协议支持，并过滤输出信息
```
curl -vso /dev/null --http2 https://www.https://www.aws.training/ 2>&1| grep "offering h2"
```

### 查看软件源各分支软件包版本
```
apt install devscripts
```
安装后可使用 rmadison 命令查询，例如
```
rmadison vim
```


## 日常tips

### Clash for Windows arm64版本，在m1 mac上安装时报错安装包损坏的解决方法：
使用Terminal执行以下命令
```
sudo xattr -r -d com.apple.quarantine /Applications/Clash\ for\ Windows.app
```
推荐使用ClashX Pro,简单轻量

### Mac应用程序被锁定无法进行卸载，文件、文件夹被锁定无法移入废纸篓处理方法
```
sudo rm -rf 被锁定的文件、文件夹路径
```
不知道路径的可以直接把文件或文件夹拖进终端


### 使用Find命令查找文件，例如 httpd.conf
```
find / -name httpd.conf
```

### Adguard Home管理命令
```
sudo /Applications/AdGuardHome/AdGuardHome -s start|stop|restart|status|install|uninstall
```

### macOS下使用homebrew更新应用
*需安装homebrew-cask-upgrade*
```
brew cu -ay --no-quarantine
brew upgrade --no-quarantine
# mas upgrade
brew cleanup --prune=all
```

### macOS下解决"pip command not found"的办法
```
# 首先查看py3.10的包文件夹路径
# 打开终端
$ python3
>>> import sys
>>> print(sys.path)
# 复制最后一个路径，我的是
/Library/Frameworks/Python.framework/Versions/3.10/lib/python3.10/site-packages
# 直接终端执行
python3 -m pip install 包名
# 即可安装完成

# 更新pip
python3 -m pip install --upgrade pip
# 查看需要更新的包
pip list --outdated
# 更新单个包（此处以更新pip为例）
pip install --upgrade pip
# 这个命令或许也有用
/Library/Frameworks/Python.framework/Versions/3.10/bin/python3 -m pip install --upgrade pip

# 批量更新并更新
pip install pip-review
pip-review --local --interactive
pip-review --auto
# 命令先全部下载所有待更新包后再安装，所以如果中间出错将全部安装失败
# 查看出错的包名，先单独安装
pip install --upgrade itchat
# 然后重新运行
pip-review --auto
```

### 显示macOS隐藏文件
```
defaults write com.apple.Finder AppleShowAllFiles true
killall Finder
```

重新隐藏
```
defaults write com.apple.Finder AppleShowAllFiles false
killall Finder
```

### wget下载civitai模型办法，替换模型文件id即可
```
wget https://civitai.com/api/download/models/{modelVersionId} --content-disposition
```

### 设置Windows IPv4优先并屏蔽IPv6 DNS
```
设置是IPv6 DNS为"::"
Win+R 在“运行”对话框中，输入regedit打开注册表编辑器。
在以下路径：
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters\
查找或新增名为DisabledComponents的DWORD (32位)值。
双击DisabledComponents，将值数据设置为十六进制20，然后点击确定。
```

### PDF识别
meta开源工具nougat（适合英文论文等格式复杂文本）
```
pip install nougat-ocr
nougat -o path/to/save_file.pdf path/to/original_file.pdf
```
OCRmyPDF（适合多语言简单文本格式）
```
apt install ocrmypdf
apt-cache search tesseract-ocr
apt-get install tesseract-ocr-chi-sim tesseract-ocr-eng
ocrmypdf -l chi_sim+eng input.pdf output.pdf
```
