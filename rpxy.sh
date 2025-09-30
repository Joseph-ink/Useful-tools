#!/bin/bash

# rpxy 交互式安装脚本
# 支持自动检测架构、下载二进制、创建配置文件

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置变量
INSTALL_DIR="/etc/rpxy"
CONFIG_DIR="/etc/rpxy"
CONFIG_FILE="${CONFIG_DIR}/config.toml"
SERVICE_FILE="/etc/systemd/system/rpxy.service"
LOG_DIR="/var/log/rpxy"

# GitHub 仓库信息
REPO="junkurihara/rust-rpxy-l4"
BINARY_NAME="rpxy"
ORIGINAL_BINARY_NAME="rpxy-l4"

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否为 root 用户
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "请使用 root 权限运行此脚本"
        exit 1
    fi
}

# 检测系统架构
detect_arch() {
    local arch=$(uname -m)
    case $arch in
        x86_64)
            ARCH="x86_64"
            ;;
        aarch64|arm64)
            ARCH="aarch64"
            ;;
        *)
            print_error "不支持的架构: $arch"
            print_error "仅支持 x86_64 和 aarch64 架构"
            exit 1
            ;;
    esac
    print_info "检测到系统架构: $ARCH"
}

# 获取最新版本
get_latest_version() {
    print_info "获取最新版本信息..."
    LATEST_VERSION=$(curl -s "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    
    if [ -z "$LATEST_VERSION" ]; then
        print_warning "无法获取最新版本"
        LATEST_VERSION="develop"
    else
        print_info "最新版本: $LATEST_VERSION"
    fi
}

# 检查并安装依赖
check_dependencies() {
    print_info "检查系统依赖..."
    
    local missing_deps=()
    
    # 检查必需的工具
    if ! command -v curl &> /dev/null; then
        missing_deps+=("curl")
    fi
    
    if ! command -v git &> /dev/null; then
        missing_deps+=("git")
    fi
    
    if ! command -v tar &> /dev/null; then
        missing_deps+=("tar")
    fi
    
    # 如果有缺失的依赖，尝试安装
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_warning "缺少依赖: ${missing_deps[*]}"
        print_info "尝试自动安装依赖..."
        
        if command -v apt-get &> /dev/null; then
            apt-get update
            apt-get install -y "${missing_deps[@]}"
        elif command -v yum &> /dev/null; then
            yum install -y "${missing_deps[@]}"
        elif command -v dnf &> /dev/null; then
            dnf install -y "${missing_deps[@]}"
        else
            print_error "无法自动安装依赖，请手动安装: ${missing_deps[*]}"
            exit 1
        fi
    fi
    
    print_success "依赖检查完成"
}

# 下载二进制文件
download_binary() {
    print_info "尝试下载预编译二进制文件..."
    
    local download_url="https://github.com/${REPO}/releases/download/${LATEST_VERSION}/rpxy-l4-${ARCH}-unknown-linux-musl.tar.gz"
    local temp_file="/tmp/rpxy-l4.tar.gz"
    
    print_info "下载地址: $download_url"
    
    # 使用 -L 跟随重定向，-f 失败时返回错误，-s 静默模式，-S 显示错误
    if curl -L -f -s -S -o "$temp_file" "$download_url" 2>&1; then
        # 检查文件大小，如果太小（<1KB）可能不是有效文件
        local file_size=$(stat -f%z "$temp_file" 2>/dev/null || stat -c%s "$temp_file" 2>/dev/null)
        
        if [ "$file_size" -lt 1024 ]; then
            print_warning "下载的文件过小 (${file_size} bytes)，可能不是有效的二进制文件"
            rm -f "$temp_file"
            build_from_source
            return
        fi
        
        # 检查文件是否为有效的 gzip 文件
        if file "$temp_file" 2>/dev/null | grep -q "gzip compressed"; then
            print_success "下载完成 (${file_size} bytes)"
            
            print_info "解压文件..."
            if tar -xzf "$temp_file" -C /tmp/ 2>/dev/null; then
                if [ -f "/tmp/${ORIGINAL_BINARY_NAME}" ]; then
                    mv "/tmp/${ORIGINAL_BINARY_NAME}" "${INSTALL_DIR}/${BINARY_NAME}"
                    chmod +x "${INSTALL_DIR}/${BINARY_NAME}"
                    print_success "二进制文件安装到 ${INSTALL_DIR}/${BINARY_NAME}"
                    rm -f "$temp_file"
                    return
                else
                    print_warning "解压后未找到二进制文件 ${ORIGINAL_BINARY_NAME}"
                fi
            else
                print_warning "解压失败"
            fi
        else
            print_warning "下载的文件不是有效的 gzip 压缩包"
        fi
        rm -f "$temp_file"
    else
        print_warning "预编译二进制文件不可用"
    fi
    
    # 下载失败或解压失败，从源码编译
    print_info "将从源码编译..."
    build_from_source
}

# 从源码编译
build_from_source() {
    print_info "开始从源码编译 rpxy..."
    
    # 检查是否安装了 Rust
    if ! command -v cargo &> /dev/null; then
        print_info "安装 Rust 工具链..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        
        # 加载 Rust 环境
        if [ -f "$HOME/.cargo/env" ]; then
            source "$HOME/.cargo/env"
        else
            export PATH="$HOME/.cargo/bin:$PATH"
        fi
        
        # 验证安装
        if ! command -v cargo &> /dev/null; then
            print_error "Rust 安装失败"
            exit 1
        fi
        
        print_success "Rust 安装完成"
    fi
    
    # 安装编译所需的系统依赖
    print_info "安装编译依赖..."
    if command -v apt-get &> /dev/null; then
        apt-get install -y build-essential pkg-config libssl-dev
    elif command -v yum &> /dev/null; then
        yum install -y gcc gcc-c++ make pkgconfig openssl-devel
    elif command -v dnf &> /dev/null; then
        dnf install -y gcc gcc-c++ make pkgconfig openssl-devel
    fi
    
    # 克隆仓库
    local temp_dir="/tmp/rpxy-build"
    print_info "克隆源代码到 ${temp_dir}..."
    rm -rf "$temp_dir"
    
    if ! git clone "https://github.com/${REPO}.git" "$temp_dir"; then
        print_error "克隆仓库失败"
        exit 1
    fi
    
    cd "$temp_dir"
    
    # 如果不是 develop 版本，切换到对应的标签
    if [ "$LATEST_VERSION" != "develop" ]; then
        print_info "切换到版本 ${LATEST_VERSION}..."
        git checkout "$LATEST_VERSION"
    fi
    
    print_info "开始编译 (这可能需要几分钟时间)..."
    if cargo build --release; then
        print_success "编译成功"
        
        if [ -f "target/release/${ORIGINAL_BINARY_NAME}" ]; then
            cp "target/release/${ORIGINAL_BINARY_NAME}" "${INSTALL_DIR}/${BINARY_NAME}"
            chmod +x "${INSTALL_DIR}/${BINARY_NAME}"
            print_success "二进制文件已安装到 ${INSTALL_DIR}/${BINARY_NAME}"
        else
            print_error "编译产物不存在: target/release/${ORIGINAL_BINARY_NAME}"
            cd -
            rm -rf "$temp_dir"
            exit 1
        fi
    else
        print_error "编译失败"
        cd -
        rm -rf "$temp_dir"
        exit 1
    fi
    
    cd -
    rm -rf "$temp_dir"
    
    print_success "源码编译完成"
}

# 创建必要的目录
create_directories() {
    print_info "创建配置目录..."
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$LOG_DIR"
    print_success "目录创建完成"
}

# 交互式配置生成器
interactive_config() {
    echo ""
    echo "========================================"
    echo "      rpxy 配置文件生成器"
    echo "========================================"
    echo ""
    
    # 基础配置
    read -p "请输入监听端口 [默认: 8448]: " LISTEN_PORT
    LISTEN_PORT=${LISTEN_PORT:-8448}
    
    # TCP 默认目标
    echo ""
    read -p "是否配置 TCP 默认转发目标? (y/n) [默认: n]: " config_tcp
    config_tcp=${config_tcp:-n}
    
    TCP_TARGET=""
    TCP_LOAD_BALANCE="none"
    if [[ "$config_tcp" == "y" ]]; then
        read -p "请输入 TCP 转发目标 (格式: ip:port，多个用逗号分隔): " tcp_input
        if [ -n "$tcp_input" ]; then
            IFS=',' read -ra TARGETS <<< "$tcp_input"
            TCP_TARGET="["
            for target in "${TARGETS[@]}"; do
                TCP_TARGET+="\"${target}\", "
            done
            TCP_TARGET="${TCP_TARGET%, }]"
            
            if [ ${#TARGETS[@]} -gt 1 ]; then
                echo "选择负载均衡算法:"
                echo "  1) none (不使用)"
                echo "  2) source_ip (基于源IP)"
                echo "  3) source_socket (基于源IP和端口)"
                echo "  4) random (随机)"
                read -p "请选择 [1-4, 默认: 1]: " lb_choice
                case ${lb_choice:-1} in
                    2) TCP_LOAD_BALANCE="source_ip" ;;
                    3) TCP_LOAD_BALANCE="source_socket" ;;
                    4) TCP_LOAD_BALANCE="random" ;;
                    *) TCP_LOAD_BALANCE="none" ;;
                esac
            fi
        fi
    fi
    
    # UDP 默认目标
    echo ""
    read -p "是否配置 UDP 默认转发目标? (y/n) [默认: n]: " config_udp
    config_udp=${config_udp:-n}
    
    UDP_TARGET=""
    UDP_LOAD_BALANCE="none"
    UDP_IDLE_LIFETIME=30
    if [[ "$config_udp" == "y" ]]; then
        read -p "请输入 UDP 转发目标 (格式: ip:port，多个用逗号分隔): " udp_input
        if [ -n "$udp_input" ]; then
            IFS=',' read -ra TARGETS <<< "$udp_input"
            UDP_TARGET="["
            for target in "${TARGETS[@]}"; do
                UDP_TARGET+="\"${target}\", "
            done
            UDP_TARGET="${UDP_TARGET%, }]"
            
            if [ ${#TARGETS[@]} -gt 1 ]; then
                echo "选择负载均衡算法:"
                echo "  1) none (不使用)"
                echo "  2) source_ip (基于源IP)"
                echo "  3) source_socket (基于源IP和端口)"
                echo "  4) random (随机)"
                read -p "请选择 [1-4, 默认: 1]: " lb_choice
                case ${lb_choice:-1} in
                    2) UDP_LOAD_BALANCE="source_ip" ;;
                    3) UDP_LOAD_BALANCE="source_socket" ;;
                    4) UDP_LOAD_BALANCE="random" ;;
                    *) UDP_LOAD_BALANCE="none" ;;
                esac
            fi
            
            read -p "UDP 连接空闲超时时间(秒) [默认: 30]: " udp_idle
            UDP_IDLE_LIFETIME=${udp_idle:-30}
        fi
    fi
    
    # 协议多路复用配置
    declare -a PROTOCOLS
    echo ""
    read -p "是否配置协议多路复用? (y/n) [默认: n]: " config_protocol
    config_protocol=${config_protocol:-n}
    
    if [[ "$config_protocol" == "y" ]]; then
        while true; do
            echo ""
            echo "========== 添加协议配置 (已添加 ${#PROTOCOLS[@]} 个) =========="
            echo "支持的协议: tls, quic, ssh, http, wireguard"
            echo ""
            
            read -p "请输入服务名称 (例如: tls_service): " service_name
            
            # 如果用户直接回车或输入空值，询问是否完成配置
            if [[ -z "$service_name" ]]; then
                if [ ${#PROTOCOLS[@]} -gt 0 ]; then
                    read -p "未输入服务名称，是否完成协议配置? (y/n) [默认: y]: " finish_config
                    finish_config=${finish_config:-y}
                    if [[ "$finish_config" == "y" ]]; then
                        break
                    else
                        continue
                    fi
                else
                    print_warning "至少需要配置一个协议，请输入服务名称"
                    continue
                fi
            fi
            
            echo "选择协议类型:"
            echo "  1) tls"
            echo "  2) quic"
            echo "  3) ssh"
            echo "  4) http"
            echo "  5) wireguard"
            read -p "请选择 [1-5]: " proto_choice
            
            case $proto_choice in
                1) protocol="tls" ;;
                2) protocol="quic" ;;
                3) protocol="ssh" ;;
                4) protocol="http" ;;
                5) protocol="wireguard" ;;
                *) 
                    print_warning "无效选择，跳过此配置"
                    continue
                    ;;
            esac
            
            read -p "请输入转发目标 (格式: ip:port，多个用逗号分隔): " proto_target
            if [ -z "$proto_target" ]; then
                print_warning "目标不能为空，跳过此配置"
                continue
            fi
            
            IFS=',' read -ra TARGETS <<< "$proto_target"
            target_array="["
            for target in "${TARGETS[@]}"; do
                target_array+="\"${target}\", "
            done
            target_array="${target_array%, }]"
            
            # 负载均衡
            load_balance="none"
            if [ ${#TARGETS[@]} -gt 1 ]; then
                echo "选择负载均衡算法:"
                echo "  1) none"
                echo "  2) source_ip"
                echo "  3) source_socket"
                echo "  4) random"
                read -p "请选择 [1-4, 默认: 1]: " lb_choice
                case ${lb_choice:-1} in
                    2) load_balance="source_ip" ;;
                    3) load_balance="source_socket" ;;
                    4) load_balance="random" ;;
                esac
            fi
            
            # TLS/QUIC 特定配置
            server_names=""
            alpns=""
            if [[ "$protocol" == "tls" || "$protocol" == "quic" ]]; then
                read -p "是否配置 SNI 过滤? (y/n) [默认: n]: " config_sni
                if [[ "$config_sni" == "y" ]]; then
                    read -p "请输入 SNI (多个用逗号分隔，例如: example.com,example.org): " sni_input
                    if [ -n "$sni_input" ]; then
                        IFS=',' read -ra SNI_LIST <<< "$sni_input"
                        server_names="["
                        for sni in "${SNI_LIST[@]}"; do
                            server_names+="\"${sni}\", "
                        done
                        server_names="${server_names%, }]"
                    fi
                fi
                
                read -p "是否配置 ALPN 过滤? (y/n) [默认: n]: " config_alpn
                if [[ "$config_alpn" == "y" ]]; then
                    read -p "请输入 ALPN (多个用逗号分隔，例如: h2,http/1.1): " alpn_input
                    if [ -n "$alpn_input" ]; then
                        IFS=',' read -ra ALPN_LIST <<< "$alpn_input"
                        alpns="["
                        for alpn in "${ALPN_LIST[@]}"; do
                            alpns+="\"${alpn}\", "
                        done
                        alpns="${alpns%, }]"
                    fi
                fi
            fi
            
            # UDP 协议的空闲超时
            idle_lifetime=""
            if [[ "$protocol" == "quic" || "$protocol" == "wireguard" ]]; then
                read -p "空闲超时时间(秒) [默认: 30]: " idle_input
                idle_lifetime=${idle_input:-30}
            fi
            
            # 保存协议配置
            PROTOCOLS+=("$service_name|$protocol|$target_array|$load_balance|$server_names|$alpns|$idle_lifetime")
            
            print_success "协议 '$service_name' ($protocol) 配置已添加"
            
            # 询问是否继续添加
            echo ""
            read -p "是否继续添加其他协议配置? (y/n) [默认: y]: " continue_add
            continue_add=${continue_add:-y}
            if [[ "$continue_add" != "y" ]]; then
                break
            fi
        done
    fi
    
    # 生成配置文件
    generate_config_file
}

# 生成配置文件
generate_config_file() {
    print_info "生成配置文件 $CONFIG_FILE ..."
    
    cat > "$CONFIG_FILE" <<EOF
# rpxy 配置文件
# 自动生成时间: $(date)

# 监听端口
listen_port = $LISTEN_PORT

EOF

    # TCP 配置
    if [ -n "$TCP_TARGET" ]; then
        cat >> "$CONFIG_FILE" <<EOF
# TCP 默认转发目标
tcp_target = $TCP_TARGET

EOF
        if [ "$TCP_LOAD_BALANCE" != "none" ]; then
            cat >> "$CONFIG_FILE" <<EOF
# TCP 负载均衡算法
tcp_load_balance = "$TCP_LOAD_BALANCE"

EOF
        fi
    fi
    
    # UDP 配置
    if [ -n "$UDP_TARGET" ]; then
        cat >> "$CONFIG_FILE" <<EOF
# UDP 默认转发目标
udp_target = $UDP_TARGET

EOF
        if [ "$UDP_LOAD_BALANCE" != "none" ]; then
            cat >> "$CONFIG_FILE" <<EOF
# UDP 负载均衡算法
udp_load_balance = "$UDP_LOAD_BALANCE"

EOF
        fi
        cat >> "$CONFIG_FILE" <<EOF
# UDP 连接空闲超时时间(秒)
udp_idle_lifetime = $UDP_IDLE_LIFETIME

EOF
    fi
    
    # 协议多路复用配置
    if [ ${#PROTOCOLS[@]} -gt 0 ]; then
        cat >> "$CONFIG_FILE" <<EOF
# ========================================
# 协议多路复用配置
# ========================================

EOF
        for proto_config in "${PROTOCOLS[@]}"; do
            IFS='|' read -ra PROTO_PARTS <<< "$proto_config"
            service_name="${PROTO_PARTS[0]}"
            protocol="${PROTO_PARTS[1]}"
            target="${PROTO_PARTS[2]}"
            load_balance="${PROTO_PARTS[3]}"
            server_names="${PROTO_PARTS[4]}"
            alpns="${PROTO_PARTS[5]}"
            idle_lifetime="${PROTO_PARTS[6]}"
            
            cat >> "$CONFIG_FILE" <<EOF
[protocol."$service_name"]
# 协议类型
protocol = "$protocol"

# 转发目标
target = $target

EOF
            if [ "$load_balance" != "none" ]; then
                cat >> "$CONFIG_FILE" <<EOF
# 负载均衡算法
load_balance = "$load_balance"

EOF
            fi
            
            if [ -n "$server_names" ]; then
                cat >> "$CONFIG_FILE" <<EOF
# SNI 过滤
server_names = $server_names

EOF
            fi
            
            if [ -n "$alpns" ]; then
                cat >> "$CONFIG_FILE" <<EOF
# ALPN 过滤
alpns = $alpns

EOF
            fi
            
            if [ -n "$idle_lifetime" ]; then
                cat >> "$CONFIG_FILE" <<EOF
# 空闲超时时间(秒)
idle_lifetime = $idle_lifetime

EOF
            fi
        done
    fi
    
    print_success "配置文件已生成: $CONFIG_FILE"
}

# 创建 systemd 服务
create_systemd_service() {
    print_info "创建 systemd 服务..."
    
    cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=rpxy L4 Reverse Proxy
After=network.target

[Service]
Type=simple
User=root
ExecStart=${INSTALL_DIR}/${BINARY_NAME} --config ${CONFIG_FILE} --log-dir ${LOG_DIR}
Restart=on-failure
RestartSec=5s

# 安全设置
NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    print_success "systemd 服务已创建"
}

# 显示配置摘要
show_summary() {
    echo ""
    echo "========================================"
    echo "         安装完成!"
    echo "========================================"
    echo ""
    echo "配置信息:"
    echo "  - 二进制文件: ${INSTALL_DIR}/${BINARY_NAME}"
    echo "  - 配置文件: ${CONFIG_FILE}"
    echo "  - 日志目录: ${LOG_DIR}"
    echo "  - 服务文件: ${SERVICE_FILE}"
    echo ""
    echo "常用命令:"
    echo "  启动服务: systemctl start rpxy"
    echo "  停止服务: systemctl stop rpxy"
    echo "  查看状态: systemctl status rpxy"
    echo "  开机自启: systemctl enable rpxy"
    echo "  查看日志: tail -f ${LOG_DIR}/rpxy-l4.log"
    echo "  查看访问日志: tail -f ${LOG_DIR}/access.log"
    echo "  编辑配置: vi ${CONFIG_FILE}"
    echo "  测试配置: ${INSTALL_DIR}/${BINARY_NAME} --config ${CONFIG_FILE}"
    echo ""
    echo "注意: 配置文件修改后会自动重载，无需重启服务"
    echo ""
    
    read -p "是否现在启动服务? (y/n) [默认: y]: " start_service
    start_service=${start_service:-y}
    
    if [[ "$start_service" == "y" ]]; then
        systemctl start rpxy
        systemctl enable rpxy
        echo ""
        print_success "服务已启动并设置为开机自启"
        echo ""
        systemctl status rpxy --no-pager
    fi
}

# 主函数
main() {
    echo ""
    echo "========================================"
    echo "   rpxy 自动安装脚本"
    echo "========================================"
    echo ""
    
    check_root
    check_dependencies
    detect_arch
    get_latest_version
    create_directories
    download_binary
    interactive_config
    create_systemd_service
    show_summary
}

# 执行主函数
main
