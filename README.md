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
### 更新Ubuntu 20.04 至 22.04 LTS
替换 focal 为 jammy
```
sed -i 's/focal/jammy/g' /etc/apt/sources.list
sed -i 's/focal/jammy/g' /etc/apt/sources.list.d/*.list
```

### 更新Ubuntu 22.04 至 24.04 LTS
使用 do-release-upgrade 命令升级
```
apt install ubuntu-release-upgrader-core
```

修改 /etc/update-manager/release-upgrades 文件，确保 Prompt 值为 lts：
```
Prompt=lts
```

查看确认
```
cat /etc/update-manager/release-upgrades | grep lts
```

执行命令升级系统
```
do-release-upgrade -d
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

使用新的 deb822 格式 修改配置文件 `/etc/apt/sources.list.d/debian.sources`
```
Types: deb deb-src
URIs: http://deb.debian.org/debian/
Suites: trixie
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb deb-src
URIs: http://security.debian.org/debian-security/
Suites: trixie-security
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb deb-src
URIs: http://deb.debian.org/debian/
Suites: trixie-updates
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
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
### 查看Warp启用情况，透过代理访问：
```
https://www.cloudflare.com/cdn-cgi/trace
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

### VPS挂载多个IPv6地址
部分VPS提供商会分配整个/64 IPv6网段给单个VPS，可挂载多个IPv6更充分利用其特性。

一、使用命令 `ip link show` 或 `ifconfig -a` 来查看VPS的网络接口名称

二、从你的/64网段中选择你想要绑定的多个IPv6地址。
例如，如果你的网段是 2001:db8:1234:5678::/64，你可以选择 2001:db8:1234:5678::1, 2001:db8:1234:5678::2 等等。

三、配置网络接口
编辑 /etc/network/interfaces 配置文件，例如 /etc/network/interfaces.d/50-cloud-init
**强烈建议修改前备份原始配置，此处仅着重体现inet6部分配置**
```
auto eth0
iface eth0 inet dhcp

iface eth0 inet6 static
    address 2001:db8:1234:5678::1
    netmask 64

iface eth0 inet6 static
    address 2001:db8:1234:5678::2
    netmask 64
```
保存并退出后，使用以下命令生效
```
sudo systemctl restart networking.service
```
四、验证配置生效
```
curl --interface 2001:db8:1234:5678::1 ip.sb
curl --interface 2001:db8:1234:5678::2 ip.sb
```
输出显示ip为制定接口ip即为生效
注意厂商可以采用自动配置方案，请确定重启后配置持久生效。

### VPS附加多个/64子网IPv6地址
部分VPS提供商会分配多个/64 IPv6网段给用户使用，可附加多个网卡挂载多个/64子网下的不同IPv6更充分利用其特性。

一、使用命令 `ip link show` 查看并记录VPS的不同网络接口的mac地址**此处仅着重体现mac地址部分配置**
例如：
```
eth0 link/ether aa:aa:aa:aa:aa:00
eth1 link/ether bb:bb:bb:bb:bb:00
```

二、修改多网卡配置：
**强烈建议修改前备份原始Netplan 配置文件 /etc/netplan/*.yaml**
```
network:
  version: 2
  ethernets:
    eth0:
      match:
        macaddress: "aa:aa:aa:aa:aa:00"
      dhcp4: true
      accept-ra: true  # 显式启用IPv6路由通告处理
      set-name: "eth0"
    eth1:
      match:
        macaddress: "bb:bb:bb:bb:bb:00"
      dhcp4: true
      accept-ra: true  # 启用IPv6路由通告处理，以期自动配置地址
      set-name: "eth1"
```
三、应用 Netplan 配置：
首先尝试应用 `netplan try `，Netplan 会在120秒内测试配置，如果失败会自动回滚。

如果提示配置正常并且您可以通过 SSH 重新连接（如果断开），或者没有错误提示，则永久应用:
```
netplan apply
```
四、检查路由表：
```
ip -6 route show
```
五、通过接口名测试连接：
```
ping -6 -I eth0 google.com
ping -6 -I eth1 google.com
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

### 查询软件包在所有Debian发行版下的版本号

rmadison 是 devscripts 软件包的一部分,非常适合快速查看全部分支的版本。
```
apt update
apt install devscripts
```
举例openssh-server
```
rmadison openssh-server
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

### 使用密码验证登录VPS root账号
请注意修改以下“password”为你需要设置的密码，请勿直接使用，防止简单密码爆破；
请切换至root账号或者使用sudo运行代码。
```
echo root:password |sudo chpasswd root
sed -i 's/^.*PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config;
sed -i 's/^.*PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config;
reboot
```

### 使用公私钥验证登录VPS root账号

1. 生成新的 SSH 密钥对

切换到`root`用户，生成新的SSH密钥对

```
ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa
```

这将生成一个4096位的RSA密钥对:
```
私钥（Private Key）: ~/.ssh/id_rsa
公钥（Public Key）: ~/.ssh/id_rsa.pub
```
注：生成的id_rsa文件是SSH私钥，它没有文件扩展名。

2. 将公钥添加到 `authorized_keys`

将公钥（`id_rsa.pub`）内容添加到`/root/.ssh/authorized_keys`文件中，以便使用新的密钥对进行SSH登录。

```
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
```

确保`authorized_keys`文件的权限是正确的：

```
chmod 600 /root/.ssh/authorized_keys
```

3. 配置 SSH 服务允许 `root` 登录

你还需要确认SSH服务配置允许`root`用户登录。编辑`/etc/ssh/sshd_config`文件，确保以下行被正确配置：

```bash
PermitRootLogin yes
```

如果是`no`或者`prohibit-password`，修改为`yes`。

4. 重启 SSH 服务

配置修改完成后，重启SSH服务以应用新的配置：

```
systemctl restart ssh
```

5. 使用新证书登录

可以使用新的SSH私钥通过`root`用户登录你的VPS

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

### Mac配置 VS Code环境变量
```
打开 vscode
按 ⌘ command + ⇧ shift + P

在输入框看到
>

继续输入
path

找到选项
Shell Command: Install 'code' command in PATH

鼠标点击它 或者 键盘选择中后按回车

VS code申请权限并同意

终端输入命令
code .
如果打开了 vscode并打开位于本级目录文件夹，即配置完成。
```


### iOS解锁 Chatgpt app 测试
```
curl https://ios.chat.openai.com/public-api/mobile/server_status/v1
```

### wget下载网页源代码
当使用 wget 下载网页时遇到 403 Forbidden 错误，可以通过模拟浏览器的请求来绕过这个限制。
```
wget --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.121 Safari/537.36" https://example.com -O page.html
```
