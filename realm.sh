#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
clear

sh_ver="1.0.7"
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"
realm_conf_path="/etc/realm/config.toml"
raw_conf_path="/etc/realm/rawconf"
#检测是否安装RealM
check_status(){
    if test -a /etc/realm/realm -a /etc/systemd/system/realm.service -a /etc/realm/config.toml;then
        echo "------------------------------"
        echo -e "--------${Green_font_prefix} RealM已安装~ ${Font_color_suffix}--------"
        echo "------------------------------"
    else
        echo "------------------------------"
        echo -e "--------${Red_font_prefix}RealM未安装！${Font_color_suffix}---------"
        echo "------------------------------"
    fi
}

#安装RealM
Install_RealM(){
  if test -a /etc/realm/realm -a /etc/systemd/system/realm.service -a /etc/realm/config.toml;then
  echo "≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡"
  echo -e "≡≡≡≡≡≡ ${Green_font_prefix}RealM已安装~ ${Font_color_suffix}≡≡≡≡≡≡"
  echo "≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡"
  sleep 2s
  start_menu
  fi
  mkdir /etc/realm

  bit=$(uname -m)
  if [[ ${bit} == "x86_64" ]]; then
    wget -N --no-check-certificate https://github.com/zhboner/realm/releases/download/v2.4.4/realm-x86_64-unknown-linux-gnu.tar.gz
    tar -zxvf realm-x86_64-unknown-linux-gnu.tar.gz
    chmod +x realm
    mv realm /etc/realm/realm
  elif [[ ${bit} == "aarch64" ]]; then
    wget -N --no-check-certificate https://github.com/zhboner/realm/releases/download/v2.4.4/realm-aarch64-unknown-linux-gnu.tar.gz
    tar -zxvf realm-aarch64-unknown-linux-gnu.tar.gz
    chmod +x realm
    mv realm /etc/realm/realm
  else
    echo -e "${Error} 不支持x86_64及arm64/aarch64以外的系统 !" && exit 1
  fi


echo '
[log]
level = "warn"
output = "/var/log/realm.log"

[network]
no_tcp = false
use_udp = true

[[endpoints]]
listen = ":::10000"
remote = "example.com:20000"
' > /etc/realm/config.toml
chmod +x /etc/realm/config.toml

echo '
[Unit]
Description=realm
After=network-online.target
Wants=network-online.target systemd-networkd-wait-online.service

[Service]
Type=simple
User=root
Restart=on-failure
RestartSec=5s
DynamicUser=true
ExecStart=/etc/realm/realm -c /etc/realm/config.toml

[Install]
WantedBy=multi-user.target' > /etc/systemd/system/realm.service
systemctl enable --now realm
    echo "------------------------------"
    if test -a /etc/realm/realm -a /etc/systemd/system/realm.service -a /etc/realm/config.toml;then
        echo -e "-------${Green_font_prefix} RealM安装成功! ${Font_color_suffix}-------"
        echo "------------------------------"
    else
        echo -e "-------${Red_font_prefix}RealM没有安装成功，请检查你的网络环境！${Font_color_suffix}-------"
        echo "------------------------------"
        `rm -rf "$(pwd)"/realm`
        `rm -rf "$(pwd)"/realm.service`
        `rm -rf "$(pwd)"/config.toml`
    fi
sleep 3s
start_menu
}

#卸载RealM
Uninstall_RealM(){
    if test -o /etc/realm/realm -o /etc/systemd/system/realm.service -o /etc/realm/config.toml;then
    sleep 2s
    `rm -rf /etc/realm`
    `rm -rf /etc/systemd/system/realm.service`
    echo "------------------------------"
    echo -e "-------${Green_font_prefix} RealM卸载成功! ${Font_color_suffix}-------"
    echo "------------------------------"
    sleep 3s
    start_menu
    else
    echo -e "-------${Red_font_prefix}RealM没有安装,卸载个锤子！${Font_color_suffix}-------"
    sleep 3s
    start_menu
    fi
}
#启动RealM
Start_RealM(){
    if test -a /etc/realm/realm -a /etc/systemd/system/realm.service -a /etc/realm/config.toml;then
    `systemctl start realm`
    echo "------------------------------"
    echo -e "-------${Green_font_prefix} RealM启动成功! ${Font_color_suffix}-------"
    echo "------------------------------"
    sleep 3s
    start_menu
    else
    echo -e "-------${Red_font_prefix}RealM没有安装,启动个锤子！${Font_color_suffix}-------"    
    sleep 3s
    start_menu
    fi
}

#停止RealM
Stop_RealM(){
    if test -a /etc/realm/realm -a /etc/systemd/system/realm.service -a /etc/realm/config.toml;then
    `systemctl stop realm`
    echo "------------------------------"
    echo -e "-------${Green_font_prefix} RealM停止成功! ${Font_color_suffix}-------"
    echo "------------------------------"
    sleep 3s
    start_menu
    else
    echo -e "-------${Red_font_prefix}RealM没有安装,停止个锤子！${Font_color_suffix}-------"    
    sleep 3s
    start_menu
    fi
}

#重启RealM
Restart_RealM(){
    if test -a /etc/realm/realm -a /etc/systemd/system/realm.service -a /etc/realm/config.toml;then
    `systemctl restart realm`
    echo "------------------------------"
    echo -e "-------${Green_font_prefix} RealM重启成功! ${Font_color_suffix}-------"
    echo "------------------------------"
    sleep 3s
    start_menu
    else
    echo -e "-------${Red_font_prefix}RealM没有安装,重启个锤子！${Font_color_suffix}-------"    
    sleep 3s
    start_menu
    fi
}


#查看RealM状态
Status_RealM(){
  systemctl status realm
  read -p "输入任意键按回车返回主菜单"
  start_menu
}

#删除RealM配置
Rewrite_RealM(){
  rm -rf /etc/realm/config.toml
  read -p "删除成功,请在输入任意键按回车返回主菜单"
  start_menu
}

#创建RealM配置
Create_RealM(){
rm -rf /etc/realm/config.toml
echo '
[log]
level = "warn"
output = "/var/log/realm.log"

[network]
no_tcp = false
use_udp = true

[[endpoints]]
listen = ":::10000"
remote = "example.com:20000"
' > /etc/realm/config.toml
chmod +x /etc/realm/config.toml
  read -p "创建成功,请在输入任意键按回车返回主菜单"
  start_menu
}



#定时重启任务
Time_Task(){
  clear
  echo -e "#############################################################"
  echo -e "#                       RealM定时重启任务                   #"
  echo -e "#############################################################" 
  echo -e    
  echo -e "${Green_font_prefix}1.配置RealM定时重启任务${Font_color_suffix}"
  echo -e "${Red_font_prefix}2.删除RealM定时重启任务${Font_color_suffix}"
  read -p "请选择: " numtype
  if [ "$numtype" == "1" ]; then  
  echo -e "请选择定时重启任务类型:"
  echo -e "1.分钟 2.小时 3.天" 
  read -p "请输入类型:
  " type_num
  case "$type_num" in
	1)
  echo -e "请设置每多少分钟重启Realm任务"	
  read -p "请设置分钟数:
  " type_m
  echo "*/$type_m * * * *  /usr/bin/systemctl restart realm" >> /var/spool/cron/crontabs/root
  sync /var/spool/cron/crontabs/root
  systemctl restart cron 
	;;
	2)
  echo -e "请设置每多少小时重启Realm任务"	
  read -p "请设置小时数:
  " type_h
  echo "0 0 */$type_h * * ? * /usr/bin/systemctl restart realm" >> /var/spool/cron/crontabs/root
  sync /var/spool/cron/crontabs/root
  systemctl restart cron
	;;
	3)
  echo -e "请设置每多少天重启Realm任务"	
  read -p "请设置天数:
  " type_d
  echo "0 0 /$type_d * * /usr/bin/systemctl restart realm" >> /var/spool/cron/crontabs/root
  sync /var/spool/cron/crontabs/root
  systemctl restart cron
	;;
	*)
	clear
	echo -e "${Error}:请输入正确数字 [1-3] 按回车键"
	sleep 2s
	Time_Task
	;;
  esac
  echo -e "${Green_font_prefix}设置成功!任务已重启完成~${Font_color_suffix}"	
  echo -e "${Red_font_prefix}注意：该重启任务测试环境为debian9,其他系统暂不清楚情况,请根据具体情况自行进行重启任务配置.不会请去百度~${Font_color_suffix}"	
  read -p "输入任意键按回车返回主菜单"
  start_menu   
  elif [ "$numtype" == "2" ]; then
  sed -i "/realm/d" /var/spool/cron/crontabs/root
  systemctl restart cron
  echo -e "${Green_font_prefix}定时重启任务删除完成！${Font_color_suffix}"
  read -p "输入任意键按回车返回主菜单"
  start_menu    
  else
  echo "输入错误，请重新输入！"
  sleep 2s
  Time_Task
  fi  
}

#主菜单
start_menu(){
clear
echo
echo "#############################################################"
echo "#                        RealM 半自动配置脚本                 #"
echo "#############################################################"
echo -e "
 当前版本 ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix}
 ${Green_font_prefix}1.${Font_color_suffix} 安装 RealM (手动修改/etc/realm/config.toml内容进行配置)
 ${Green_font_prefix}2.${Font_color_suffix} 卸载 RealM
——————————————
 ${Green_font_prefix}3.${Font_color_suffix} 启动 RealM        ${Green_font_prefix}x.${Font_color_suffix} 查看 RealM 状态 
 ${Green_font_prefix}4.${Font_color_suffix} 停止 RealM        ${Green_font_prefix}y.${Font_color_suffix} 删除 RealM 配置
 ${Green_font_prefix}5.${Font_color_suffix} 重启 RealM        ${Green_font_prefix}z.${Font_color_suffix} 创建 RealM 配置
——————————————
 ${Green_font_prefix}6.${Font_color_suffix} 添加定时重启任务
 ${Green_font_prefix}7.${Font_color_suffix} 退出脚本

 check_status

read -p " 请输入数字后[0-11] 按回车键:
" num
case "$num" in
	1)
	Install_RealM
	;;
	2)
	Uninstall_RealM
	;;
	3)
	Start_RealM
	;;
	x)
	Status_RealM
	;;
	4)
	Stop_RealM
	;;
	y)
	Rewrite_RealM
	;;	
	5)
	Restart_RealM
	;;
	z)
    Create_RealM
    ;;
	6)
	Time_Task
	;;
	7)
	exit 1
	;;
	*)	
	clear
	echo -e "${Error}:请输入正确数字 [0-11] 按回车键"
	sleep 2s
	start_menu
	;;
esac
}
start_menu