一些工具的整理，方便个人对于vps的管理


## BBR开启和选择模式脚本 

更换Xanmod real-time高响应内核
```
wget -N --no-check-certificate "https://raw.githubusercontent.com/Joseph-ink/Useful-tools/main/tcp.sh" && chmod +x tcp.sh && ./tcp.sh 
```

更换Xanmod real-time高响应内核（最新开发版）
```
wget -N --no-check-certificate "https://raw.githubusercontent.com/Joseph-ink/Useful-tools/main/tcp_edge.sh" && chmod +x tcp_edge.sh && ./tcp_edge.sh
```

查看匹配内核
```
ls /boot/vmlinuz-*
```

更新CPU微码
```
#查看CPU信息
cat  /proc/cpuinfo
#intel
apt install intel-microcode iucode-tool
#amd
apt install amd64-microcode
```

## BBR优化脚本
原版，采用bbr+fq优化加速
```
bash <(curl -Ls https://github.com/lanziii/bbr-/releases/download/123/tools.sh)
```
MOD 采用bbr+fq_pie优化加速
```
bash <(curl -Ls https://raw.githubusercontent.com/Joseph-ink/Useful-tools/main/tools_pie.sh)
```

## CoalRelay隧道

AMD64
```
wget https://raw.githubusercontent.com/Joseph-ink/Useful-tools/main/coal-amd64.sh && bash coal-amd64.sh
```
ARM64
```
wget https://raw.githubusercontent.com/Joseph-ink/Useful-tools/main/coal-arm64.sh && bash coal-arm64.sh
```
### 使用方法
```
源节点+端口----目标节点+端口----监听节点+端口
若目标节点即为最终落地节点，则配置监听节点ip:127.0.0.1，监听端口为架设服务的端口
```
```
配置文件:/etc/CoalRelay/config.json
重启命令:systemctl restart coal
查看状态:systemctl status coal
```

## 使用ACME.sh脚本进行TLS证书申请

安装 ACME.sh脚本
```
curl https://get.acme.sh | sh
```

或者试试这个，特别是国内环境
```
wget -O -  https://get.acme.sh | sh -s email=my@example.com
```

设置 Cloudflare API 令牌（依照自己账号的信息）
```
export CF_Key="4f9794c701b6e27884f0da0bab6454de07552"
export CF_Email="bozai@v2rayssr.com"
```

按ZeroSSL要求注册至自己的邮箱
```
~/.acme.sh/acme.sh --register-account -m my@example.com
```

验证DNS并申请证书
```
~/.acme.sh/acme.sh --issue --dns dns_cf -d bozai3.xyz
mkdir /root/cert
~/.acme.sh/acme.sh --installcert -d bozai3.xyz --key-file /root/cert/private.key --fullchain-file /root/cert/cert.crt
~/.acme.sh/acme.sh --upgrade --auto-upgrade
chmod -R 755 /root/cert
```

## 关闭oracle防火墙
```
wget -N --no-check-certificate https://raw.githubusercontent.com/Joseph-ink/Useful-tools/main/multi.sh && chmod +x multi.sh && ./multi.sh
```

## 使用worsttrace 追踪路由
linux x86
```
wget https://wtrace.app/packages/linux/worsttrace -O /usr/local/bin/worsttrace
chmod a+x /usr/local/bin/worsttrace
worsttrace ip
```

## Speedtest-Cli

特点
测试网络上传/下载速率的一款工具

Speedtest-Cli
```
#下载
wget https://raw.github.com/sivel/speedtest-cli/master/speedtest.py
#添加权限
chmod a+rx speedtest.py
#执行
python3 speedtest.py
```

## 卸载腾讯云服务器自带监控

执行以下命令
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
## 一键DD脚本（默认Debian 11）
```
bash <(wget --no-check-certificate -qO- 'https://raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh') -d 11 -v 64 -p "自定义root密码" -port "自定义ssh端口"
```

## 切换AWS VPS登录账号至root

请注意修改以下“password”为你需要设置的密码，请勿直接使用，防止简单密码爆破；
请切换至root账号或者使用sudo运行代码。

```
echo root:password |sudo chpasswd root
sed -i 's/^.*PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config;
sed -i 's/^.*PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config;
reboot
```
## macOS下解决"pip command not found"的办法

首先查看py3.10的包文件夹路径
打开终端
```
$ python3
>>> import sys
>>> print(sys.path)
```
复制最后一个路径，我的是
```
/Library/Frameworks/Python.framework/Versions/3.10/lib/python3.10/site-packages
```
直接终端执行
```
python3 -m pip install 包名
```
即可安装完成

更新pip
```
python3 -m pip install --upgrade pip
```
查看需要更新的包
```
pip list --outdated
```
更新单个包（此处以更新pip为例）
```
pip install --upgrade pip
```
这个命令或许也有用
```
/Library/Frameworks/Python.framework/Versions/3.10/bin/python3 -m pip install --upgrade pip
```

## How do I fix the syntax error in pip?
The pip install invalid syntax error is raised when you try to install a Python package from the interpreter. To fix this error, exit your interpreter and run the pip install command from a command line shell.

## PIP更新管理
```
列出可升级的包：
pip list --outdated

更新某一个模块,如'itchat'：　　　　　
pip install --upgrade itchat

升级pip自身
pip install --upgrade pip 
```

## 批量更新
```
批量下载并更新：
pip install pip-review
pip-review --local --interactive
pip-review --auto

命令先全部下载所有待更新包后再安装，所以如果中间出错将全部安装失败
查看出错的包名，先单独安装
pip install --upgrade itchat
然后重新运行
pip-review --auto
```

## Cloudflare IPv6优选脚本
```
# 如果是第一次使用，则建议创建新文件夹（后续更新请跳过该步骤）
mkdir CloudflareST

# 进入文件夹（后续更新，只需要从这里重复下面的下载、解压命令即可）
cd CloudflareST

# 下载 CloudflareST 压缩包
wget -N https://github.com/XIU2/CloudflareSpeedTest/releases/download/v2.0.3/CloudflareST_linux_amd64.tar.gz

# 解压
tar -zxf CloudflareST_linux_amd64.tar.gz

# 赋予执行权限
chmod +x CloudflareST

# 运行IPv6测试
./CloudflareST -f ipv6.txt -ipv6
```

## Oracle Cloud VPS在选择ubuntu系统下会存在额外的防火墙，以下为删掉防火墙与端口的限制命令
```
#开放所有端口
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -F
#Oracle自带的Ubuntu镜像默认设置了Iptable规则，关闭它
apt-get purge netfilter-persistent
#强制删除
rm -rf /etc/iptables && reboot
```
