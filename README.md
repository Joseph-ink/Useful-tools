一些工具的整理，方便个人对于vps的管理

## Besttrace4Linux

特点
Linux(X86/ARM)/Mac/BSD 系统环境下发起 traceroute 请求
附带链路可视化
兼容性强
支持 JSON 格式

Besttrace4Linux
```
#下载
wget http://cdn.ipip.net/17mon/besttrace4linux.zip
#解压
unzip besttrace4linux.zip
```

Linux(X86)
```
#授权
chmod +x besttrace
#使用
./besttrace -q 1 这里是目标IP
```

Linux(ARM)
```
#授权
chmod +x besttracearm
#使用
./besttracearm -q 1 这里是目标IP
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

```
cd /usr/local/bin/
wget https://github.com/shadowsocks/shadowsocks-rust/releases/download/v1.11.2/shadowsocks-v1.11.2.aarch64-unknown-linux-gnu.tar.xz
xz -d shadowsocks-v1.11.2.aarch64-unknown-linux-gnu.tar.xz
tar xvf shadowsocks-v1.11.2.aarch64-unknown-linux-gnu.tar
```

## 卸载腾讯云服务器自带监控

执行以下命令
```
#卸载脚本
/usr/local/qcloud/stargate/admin/uninstall.sh
/usr/local/qcloud/YunJing/uninst.sh
/usr/local/qcloud/monitor/barad/admin/uninstall.sh
```

```
#停用服务
systemctl stop tat_agentsystemctl disable tat_agentrm -f /etc/systemd/system/tat_agent.service
```

```
#删除Cron中残留的定时任务
crontab -e
```


或者运行一键脚本
```
wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/Joseph-ink/Useful-tools/main/uninstall.sh" && chmod 700 /root/uninstall.sh && /root/uninstall.sh
```

## echo转发一键脚本

X86架构
```
wget --no-check-certificate -O ehco.sh https://raw.githubusercontent.com/Joseph-ink/Useful-tools/main/ehco_amd64.sh
chmod +x ehco.sh
./ehco.sh
```


arm64架构
```
wget --no-check-certificate -O ehco.sh https://raw.githubusercontent.com/Joseph-ink/Useful-tools/main/ehco_arm64.sh
chmod +x ehco.sh
./ehco.sh
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


## BBR优化脚本
```
bash <(curl -Ls https://github.com/lanziii/bbr-/releases/download/123/tools.sh)
```
