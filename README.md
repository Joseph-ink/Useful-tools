一些工具的整理，方便个人对于vps的管理


### 更换内核和开启BBR脚本 
```
wget -N --no-check-certificate "https://raw.githubusercontent.com/Joseph-ink/Useful-tools/main/tcp_test.sh" && chmod +x tcp_test.sh && ./tcp_test.sh
```
### 更新CPU微码
Debian 11增加源 *vi /etc/apt/sources.list*
```
deb http://deb.debian.org/debian bullseye main contrib non-free
deb http://security.debian.org/debian-security bullseye-security main contrib non-free
deb http://deb.debian.org/debian bullseye-updates main contrib non-free
```
```
#查看CPU信息
cat  /proc/cpuinfo
#intel
apt install intel-microcode iucode-tool
#amd
apt install amd64-microcode
```

### 启用tuned系统调优工具(ARM机型不建议启用)
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

### 网络和系统优化脚本
MOD 支持各种队列算法，需使用对应内核
```
bash <(curl -Ls https://raw.githubusercontent.com/Joseph-ink/Useful-tools/main/tools_vv.sh)
```

### 修改NIC缓冲
```
# 查看网卡支持范围（设置参数必须小于Pre-set maximums）
ethtool -g eth0
# 调整缓冲大小（举例）
ethtool -G eth0 rx 4096 tx 4096 rx-jumbo 4096
```

### 更新Ubuntu 22.04 LTS
替换 focal 为 jammy
```
sed -i 's/focal/jammy/g' /etc/apt/sources.list
sed -i 's/focal/jammy/g' /etc/apt/sources.list.d/*.list
```

### Debian 10 升级 11
```
vi /etc/apt/sources.list
```

```
deb http://deb.debian.org/debian bullseye main contrib non-free
deb http://deb.debian.org/debian bullseye-updates main contrib non-free
deb http://security.debian.org/debian-security bullseye-security main
deb http://ftp.debian.org/debian bullseye-backports main contrib non-free
```

### 最新编译gost以及转发配置脚本
Linux AMD64
```
wget --no-check-certificate -O gost.sh https://raw.githubusercontent.com/Joseph-ink/Useful-tools/main/gost/gost.sh && chmod +x gost.sh && ./gost.sh
```

### CoalRelay隧道
```
# AMD64
wget https://raw.githubusercontent.com/Joseph-ink/Useful-tools/main/coal-amd64.sh && bash coal-amd64.sh
# ARM64
wget https://raw.githubusercontent.com/Joseph-ink/Useful-tools/main/coal-arm64.sh && bash coal-arm64.sh
# 使用方法
源节点+端口----目标节点+端口----监听节点+端口
若目标节点即为最终落地节点，则配置监听节点ip:127.0.0.1，监听端口为架设服务的端口
配置文件:/etc/CoalRelay/config.json
重启命令:systemctl restart coal
查看状态:systemctl status coal
```

## 使用ACME.sh脚本进行TLS证书申请
```
# 安装 ACME.sh脚本
curl https://get.acme.sh | sh
# 国内环境可尝试
wget -O -  https://get.acme.sh | sh -s email=my@example.com
```


```
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

### Speedtest-Cli 测速
```
#下载
wget https://raw.github.com/sivel/speedtest-cli/master/speedtest.py
#添加权限
chmod a+rx speedtest.py
#执行
python3 speedtest.py
```

## 卸载腾讯云服务器自带监控
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

### 一键DD脚本（默认Debian 11）
```
bash <(wget --no-check-certificate -qO- 'https://raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh') -d 11 -v 64 -p "自定义root密码" -port "自定义ssh端口"
```

### 切换VPS登录账号至root

请注意修改以下“password”为你需要设置的密码，请勿直接使用，防止简单密码爆破；
请切换至root账号或者使用sudo运行代码。

```
echo root:password |sudo chpasswd root
sed -i 's/^.*PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config;
sed -i 's/^.*PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config;
reboot
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

### CDN优选
#### 包含Cloudflare、Cloudfront ip段，数据来自BGP工具
```
# 如果是第一次使用，则建议创建新文件夹（后续更新请跳过该步骤）
mkdir CloudflareST

# 进入文件夹（后续更新，只需要从这里重复下面的下载、解压命令即可）
cd CloudflareST

# 下载 CloudflareST 压缩包
# x86_64
wget -N https://github.com/XIU2/CloudflareSpeedTest/releases/download/v2.2.0/CloudflareST_linux_amd64.tar.gz
# arm64
wget -N https://github.com/XIU2/CloudflareSpeedTest/releases/download/v2.2.0/CloudflareST_linux_arm64.tar.gz

# 解压
tar -zxf CloudflareST_linux_amd64.tar.gz

# 赋予执行权限
chmod +x CloudflareST

# IPv6优选：
# (可选)第一步：更换默认ipv6地址集，扫描Cloudflare全部ipv6 /48地址块（或者本地上传txt）
rm -rf ipv6.txt
wget -N --no-check-certificate https://raw.githubusercontent.com/Joseph-ink/Useful-tools/main/cf_ipv6_all.txt && chmod +x cf_ipv6_all.txt

#（可选）首次运行IPv6延迟测试，不含下载测速
# ./CloudflareST -f cf_ipv6.txt -p 200 -tll 15 -tl 150 -dd
# 结果保存在result.csv，SSH也会显示

#（必选）将筛选后的低延迟HK IPv6进行速度测试
./CloudflareST -f cf_ipv6_hk.txt -p 200 -tll 15 -tl 150

# IPv4优选：
rm -rf ip.txt
wget -N --no-check-certificate https://raw.githubusercontent.com/Joseph-ink/Useful-tools/main/cf_ipv4_all.txt && chmod +x cf_ipv4_all.txt
./CloudflareST -f cf_ipv4_all.txt -p 200 -tll 15 -tl 150

# 其他CDN IPv4优选（使用自定义测速链接和80端口HTTP下载）：
./CloudflareST -f cf_ipv4_all.txt -p 200 -tll 15 -tl 150 -tp 80 -url http://xxx/xxx

确认中港直连cloudflare地址段 详见cf_ipv6_hk.txt
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

### Adguard Home管理命令
```
sudo /Applications/AdGuardHome/AdGuardHome -s start|stop|restart|status|install|uninstall
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


### Linux 安装GOLANG教程
```
https://go.dev/doc/install
```

### 编译安装nali
```
go install github.com/zu1k/nali@latest
生成二进制文件位置
/root/go/bin/nali
移动至/usr/local/bin并赋权
```

### 使用Find命令查找文件，例如 httpd.conf
```
find / -name httpd.conf
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

### Linux安装GCC编译器
```
apt install build-essential -y
```
### 查看版本号验证GCC安装成功
```
gcc --version
```

### target-cpu
指示 rustc 为特定处理器生成代码

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

### 查看qdisc队列算法支持情况
```
grep '^CONFIG_NET_SCH_' /boot/config-$(uname -r)
```

### 使用curl 命令来了解某个网站是否有HTTP/2协议支持，并过滤输出信息
```
curl -vso /dev/null --http2 https://www.https://www.aws.training/ 2>&1| grep "offering h2"
```

### wget下载civitai模型办法，替换模型文件id即可
```
wget https://civitai.com/api/download/models/{modelVersionId} --content-disposition
```
