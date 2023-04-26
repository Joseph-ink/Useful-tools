#!/bin/bash

show_menu() {
  PS3="请选择一个操作："
  options=("安装realm转发程序" "新增转发规则" "查询已有转发规则" "删除转发规则" "重启服务" "卸载程序" "退出")
  
  while true; do
    for i in "${!options[@]}"; do
      echo "$((${i}+1))) ${options[$i]}"
    done

    read -p "请选择一个操作：" choice

    case $choice in
      1)
        install_realm
        ;;
      2)
        add_forwarding_rule
        ;;
      3)
        query_forwarding_rules
        ;;
      4)
        delete_forwarding_rule
        ;;
      5)
        restart_service
        ;;
      6)
        uninstall_realm
        echo "卸载成功！"
        exit
        ;;
      7)
        break
        ;;
      *)
        echo "无效选项，请重新选择。"
        ;;
    esac
  done
}


install_realm() {
  arch=$(uname -m)
  if [[ "$arch" != "x86_64" ]] && [[ "$arch" != "aarch64" ]]; then
    echo "不支持的架构。"
    return
  fi

  rm -rf /etc/realm
  mkdir -p /etc/realm
  cd /etc/realm

  latest_version=$(curl -s https://api.github.com/repos/zhboner/realm/releases/latest | grep 'tag_name' | cut -d '"' -f 4)
  if [[ "$arch" == "x86_64" ]]; then
    wget "https://github.com/zhboner/realm/releases/download/${latest_version}/realm-x86_64-unknown-linux-gnu.tar.gz"
  else
    wget "https://github.com/zhboner/realm/releases/download/${latest_version}/realm-aarch64-unknown-linux-gnu.tar.gz"
  fi

  tar -xzf *.tar.gz
  rm *.tar.gz
  chmod +x realm

  cat > /etc/realm/config.toml <<EOF
[log]
level = "warn"
output = "/var/log/realm.log"

[network]
no_tcp = false
use_udp = true
EOF

  cat > /etc/systemd/system/realm.service <<EOF
[Unit]
After=network.service

[Service]
ExecStart=/etc/realm/realm -c /etc/realm/config.toml

[Install]
WantedBy=default.target
EOF

  chmod 664 /etc/systemd/system/realm.service
  systemctl daemon-reload
  systemctl enable realm

  echo "安装完成！"
}

add_forwarding_rule() {
  echo "请输入本地端口号："
  read local_port
  echo "请输入目标地址："
  read target_addr
  echo "请输入目标端口："
  read target_port

  cat >> /etc/realm/config.toml <<EOF

[[endpoints]]
listen = ":::${local_port}"
remote = "${target_addr}:${target_port}"
EOF

  if ! systemctl is-active --quiet realm; then
    systemctl start realm
  else
    systemctl restart realm
  fi
  echo "新增成功！"
  query_forwarding_rules
}

query_forwarding_rules() {
  echo "已有的转发规则："
  awk '/\[\[endpoints\]\]/ {count++} count && /listen/ {print count":", $0}' /etc/realm/config.toml
  awk '/remote/ {print "  " $0}' /etc/realm/config.toml
}

delete_forwarding_rule() {
  endpoint_count=$(grep -c '\[\[endpoints\]\]' /etc/realm/config.toml)
  if [ "$endpoint_count" -eq 0 ]; then
    echo "没有可删除的转发规则。"
    return
  fi

  query_forwarding_rules

  echo "请输入要删除的转发规则序号："
  read rule_num
  awk -v rule_num="$rule_num" 'BEGIN{ RS="\n\n"; ORS="\n\n" } NR!=rule_num+1' /etc/realm/config.toml > /etc/realm/config_temp.toml
  mv /etc/realm/config_temp.toml /etc/realm/config.toml
  systemctl restart realm

  echo "删除成功！"
}

restart_service() {
  systemctl restart realm
}

uninstall_realm() {
  systemctl disable realm
  systemctl stop realm
  rm -rf /etc/realm
  rm /etc/systemd/system/realm.service
  systemctl daemon-reload
}

show_menu
