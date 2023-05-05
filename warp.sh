#!/bin/bash

# 定义一个函数来安装并设置Cloudflare Warp
setup_warp() {
    # 一、设置存储库
    curl https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list
    apt update

    # 二、安装WARP官方客户端
    apt -y install cloudflare-warp

    # 三、注册账号
    warp-cli --accept-tos register

    # 四、开启连接
    warp-cli connect

    # 五、设置SOCKS5代理模式
    warp-cli set-mode proxy

    # 自定义代理端口
    read -p "是否自定义代理端口？(y/n) " custom_port
    if [ "$custom_port" == "y" ]; then
        read -p "请输入自定义端口号： " port_number
        warp-cli set-proxy-port $port_number
    else
        port_number=40000
    fi

    # 启用warp+
    read -p "是否启用WARP+？(y/n) " enable_warp_plus
    if [ "$enable_warp_plus" == "y" ]; then
        read -p "请输入WARP+账号： " warp_plus_license_key
        warp-cli set-license $warp_plus_license_key
    fi

    # 六、检查代理联通性
    warp_status=$(curl -s -x socks5://127.0.0.1:$port_number www.cloudflare.com/cdn-cgi/trace/ | grep warp=)
    if [[ $warp_status == *"warp=on"* ]]; then
        echo "已开启WARP Socks5代理，运行在端口 $port_number"
    elif [[ $warp_status == *"warp=plus"* ]]; then
        echo "已开启WARP+ Socks5代理，运行在端口 $port_number"
    else
        echo "未开启WARP Socks5代理"
    fi
}

# 检测系统类型
if grep -q "Ubuntu" /etc/os-release; then
    echo "检测到Ubuntu系统"
    setup_warp
elif grep -q "Debian" /etc/os-release; then
    echo "检测到Debian系统"
    setup_warp
else
    echo "错误：仅支持Debian和Ubuntu系统"
    exit 1
fi

