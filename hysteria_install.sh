#!/bin/bash

# 移除之前的安装
systemctl stop hysteria
rm /etc/systemd/system/hysteria.service
rm -rf /etc/hysteria

# 创建目录
mkdir -p /etc/hysteria

# 自动匹配系统架构并下载二进制程序
if [[ "$(uname -m)" == "x86_64" ]]; then
  ARCH="amd64-avx"
else
  ARCH="arm64"
fi
curl -Lo /etc/hysteria/hysteria https://github.com/apernet/hysteria/releases/download/app%2Fv2.0.1/hysteria-linux-${ARCH}
chmod +x /etc/hysteria/hysteria

# 创建并修改配置文件
CONFIG_FILE="/etc/hysteria/config.yaml"

# 设置端口
read -p "请输入代理程序监听端口号 (默认: 443): " PORT
PORT=${PORT:-443}
echo "listen: :$PORT" > $CONFIG_FILE

# 设置证书路径
echo "请选择证书路径:"
echo "1. 使用v2ray-agent证书路径 (/etc/v2ray-agent/tls/)"
echo "2. 使用默认配置路径 (/root/cert/)"
echo "3. 自定义证书路径"
read -p "选择 (1/2/3): " CERT_CHOICE

case $CERT_CHOICE in
1)
  CERT=$(ls /etc/v2ray-agent/tls/*.crt | head -n 1)
  KEY=$(ls /etc/v2ray-agent/tls/*.key | head -n 1)
  ;;
2)
  CERT="/root/cert/cert.crt"
  KEY="/root/cert/private.key"
  ;;
3)
  read -p "请输入full-chain证书路径: " CERT
  read -p "请输入证书密钥路径: " KEY
  ;;
*)
  echo "无效选择，默认使用 /root/cert/ 路径"
  CERT="/root/cert/cert.crt"
  KEY="/root/cert/private.key"
  ;;
esac

echo "
tls:
  cert: $CERT
  key: $KEY" >> $CONFIG_FILE

# 设置密码
read -p "请输入UUID (回车随机生成): " UUID
UUID=${UUID:-$(uuidgen)}
echo "
auth:
  type: password
  password: $UUID" >> $CONFIG_FILE

# 添加其他固定配置
cat >> $CONFIG_FILE <<EOF
quic:
  initStreamReceiveWindow: 8388608 
  maxStreamReceiveWindow: 8388608 
  initConnReceiveWindow: 20971520 
  maxConnReceiveWindow: 20971520 
  maxIdleTimeout: 30s 
  maxIncomingStreams: 1024 
  disablePathMTUDiscovery: false 

bandwidth:
  up: 1024 mbps

disableUDP: false
udpIdleTimeout: 60s

masquerade: 
  type: proxy
  proxy:
    url: https://www.askdoctors.jp/
    rewriteHost: true
EOF

# 创建systemd服务
cat > /etc/systemd/system/hysteria.service <<EOF
[Unit]
Description=Hysteria2 Server Service
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
WorkingDirectory=/etc/hysteria
ExecStart=/etc/hysteria/hysteria server --config /etc/hysteria/config.yaml
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
NoNewPrivileges=true
Restart=on-failure
RestartSec=10
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
EOF

# 启动服务
systemctl daemon-reload
systemctl enable --now hysteria

sleep 0.2

# 检查程序是否启动成功
if systemctl is-active --quiet hysteria; then
  echo "hysteria服务端程序安装成功!"
  echo "密码: $UUID"
  echo "端口: $PORT"
else
  systemctl status hysteria
fi
