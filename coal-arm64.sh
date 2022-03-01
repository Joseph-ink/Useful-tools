#!/usr/bin/bash
wget https://github.com/Joseph-ink/Useful-tools/raw/main/coal-relay-arm64  -O /usr/bin/coal-relay
chmod 777 /usr/bin/coal-relay
read -p "请输入监听端口:" port
    [ -z "${port}" ]
read -p "请输入转发ip/域名:" dip
    [ -z "${dip}" ]
read -p "请输入转发端口:" dport
    [ -z "${dport}" ]
cat <<EOF >/etc/systemd/system/coal.service
[Unit]
Description=CoalRelay Server
After=network.target

[Service]
Type=simple
LimitAS=infinity
LimitRSS=infinity
LimitCORE=infinity
LimitNOFILE=655360
ExecStart=/usr/bin/coal-relay
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
mkdir /etc/CoalRelay
cat <<EOF >/etc/CoalRelay/config.json
{
    "1":{
            "Port":$port,
            "Remote":"$dip",
            "Rport":$dport
    }
}
EOF

systemctl daemon-reload
systemctl enable coal
systemctl restart coal

echo "安装完成"
echo "配置文件:/etc/CoalRelay/config.json"
echo "重启命令:systemctl restart coal"
echo "查看状态:systemctl status coal"