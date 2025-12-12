#!/bin/bash
#
# 交互式 Qdisc 配置脚本
# 支持多队列网卡、fq/fq_pie 选择、持久化配置
#

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 打印函数
info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# 检查 root 权限
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "此脚本需要 root 权限运行"
        exit 1
    fi
}

# 检查依赖
check_deps() {
    if ! command -v tc &>/dev/null; then
        error "未找到 tc 命令，请安装 iproute2"
        exit 1
    fi
}

# 获取可用网卡列表（排除 lo 和虚拟接口）
get_interfaces() {
    local ifaces=()
    for iface in $(ls /sys/class/net); do
        # 排除 lo、docker、veth、br- 等虚拟接口
        if [[ "$iface" != "lo" ]] && \
           [[ ! "$iface" =~ ^docker ]] && \
           [[ ! "$iface" =~ ^veth ]] && \
           [[ ! "$iface" =~ ^br- ]] && \
           [[ ! "$iface" =~ ^virbr ]]; then
            # 确认接口存在且是物理/虚拟网卡
            if [[ -d "/sys/class/net/$iface" ]]; then
                ifaces+=("$iface")
            fi
        fi
    done
    echo "${ifaces[@]}"
}

# 检查是否为多队列网卡
is_multiqueue() {
    local iface=$1
    tc qdisc show dev "$iface" 2>/dev/null | grep -q "^qdisc mq"
}

# 获取队列数量
get_queue_count() {
    local iface=$1
    ls -d /sys/class/net/"$iface"/queues/tx-* 2>/dev/null | wc -l
}

# 获取当前 qdisc 信息
get_current_qdisc() {
    local iface=$1
    tc qdisc show dev "$iface" 2>/dev/null
}

# 显示网卡详细信息
show_interface_info() {
    local iface=$1
    echo ""
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}网卡: ${NC}${YELLOW}$iface${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
    
    # IP 地址
    local ipv4=$(ip -4 addr show dev "$iface" 2>/dev/null | grep -oP 'inet \K[\d.]+' | head -1)
    local ipv6=$(ip -6 addr show dev "$iface" 2>/dev/null | grep -oP 'inet6 \K[^/]+' | grep -v '^fe80' | head -1)
    echo -e "  IPv4: ${ipv4:-无}"
    echo -e "  IPv6: ${ipv6:-无}"
    
    # 驱动信息
    local driver=$(ethtool -i "$iface" 2>/dev/null | grep "^driver:" | awk '{print $2}')
    echo -e "  驱动: ${driver:-未知}"
    
    # 队列信息
    local queue_count=$(get_queue_count "$iface")
    if is_multiqueue "$iface"; then
        echo -e "  类型: ${GREEN}多队列 (mq)${NC} - $queue_count 个队列"
    else
        echo -e "  类型: 单队列"
    fi
    
    # 当前 qdisc
    echo -e "  当前 Qdisc:"
    get_current_qdisc "$iface" | while read line; do
        echo "    $line"
    done
}

# 应用 qdisc 设置
apply_qdisc() {
    local iface=$1
    local algo=$2
    local errors=0
    
    info "正在为 $iface 设置 $algo ..."
    
    if is_multiqueue "$iface"; then
        # 多队列网卡：需要为每个子队列设置
        local queue_count=$(get_queue_count "$iface")
        
        for i in $(seq 1 $queue_count); do
            if tc qdisc replace dev "$iface" parent :$i $algo 2>/dev/null; then
                success "  队列 $i: $algo 设置成功"
            else
                error "  队列 $i: $algo 设置失败"
                ((errors++))
            fi
        done
    else
        # 单队列网卡
        if tc qdisc replace dev "$iface" root $algo 2>/dev/null; then
            success "  $algo 设置成功"
        else
            error "  $algo 设置失败"
            ((errors++))
        fi
    fi
    
    return $errors
}

# 验证 qdisc 设置
verify_qdisc() {
    local iface=$1
    local algo=$2
    local current=$(get_current_qdisc "$iface")
    
    echo ""
    info "验证 $iface 的 qdisc 设置..."
    echo -e "${CYAN}────────────────────────────────────────${NC}"
    
    if echo "$current" | grep -q "qdisc $algo"; then
        success "验证通过: 检测到 $algo"
        echo "$current" | grep "$algo" | while read line; do
            echo -e "  ${GREEN}✓${NC} $line"
        done
        return 0
    else
        error "验证失败: 未检测到 $algo"
        echo "当前配置:"
        echo "$current" | while read line; do
            echo -e "  ${RED}✗${NC} $line"
        done
        return 1
    fi
}

# 创建持久化脚本
create_persistent_script() {
    local algo=$1
    shift
    local ifaces=("$@")
    
    local script_path="/usr/local/bin/setup-qdisc-persistent.sh"
    
    cat > "$script_path" << 'SCRIPT_HEADER'
#!/bin/bash
# 自动生成的 Qdisc 配置脚本
# 生成时间: TIMESTAMP
# 算法: ALGORITHM

SCRIPT_HEADER

    # 替换占位符
    sed -i "s/TIMESTAMP/$(date '+%Y-%m-%d %H:%M:%S')/" "$script_path"
    sed -i "s/ALGORITHM/$algo/" "$script_path"
    
    cat >> "$script_path" << SCRIPT_BODY

ALGO="$algo"
INTERFACES="${ifaces[*]}"

apply_to_interface() {
    local iface=\$1
    
    # 检查接口是否存在
    if [[ ! -d "/sys/class/net/\$iface" ]]; then
        return 1
    fi
    
    # 检查是否多队列
    if tc qdisc show dev "\$iface" 2>/dev/null | grep -q "^qdisc mq"; then
        local n=\$(ls -d /sys/class/net/"\$iface"/queues/tx-* 2>/dev/null | wc -l)
        for i in \$(seq 1 \$n); do
            tc qdisc replace dev "\$iface" parent :\$i \$ALGO 2>/dev/null
        done
    else
        tc qdisc replace dev "\$iface" root \$ALGO 2>/dev/null
    fi
}

for iface in \$INTERFACES; do
    apply_to_interface "\$iface"
done
SCRIPT_BODY

    chmod +x "$script_path"
    success "持久化脚本已创建: $script_path"
}

# 创建 systemd 服务
create_systemd_service() {
    local service_path="/etc/systemd/system/qdisc-setup.service"
    
    cat > "$service_path" << 'EOF'
[Unit]
Description=Configure network qdisc for optimal performance
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/bin/setup-qdisc-persistent.sh

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable qdisc-setup.service 2>/dev/null
    
    success "Systemd 服务已创建并启用: qdisc-setup.service"
}

# 更新 sysctl 配置
update_sysctl() {
    local algo=$1
    local sysctl_file="/etc/sysctl.d/99-qdisc.conf"
    
    cat > "$sysctl_file" << EOF
# Qdisc 默认算法配置
# 注意: 此设置仅对新创建的单队列接口生效
# 多队列接口需要通过 tc 命令显式设置
net.core.default_qdisc = $algo
EOF

    sysctl -p "$sysctl_file" &>/dev/null
    success "Sysctl 配置已更新: $sysctl_file"
}

# 显示菜单
show_menu() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║          Qdisc 配置工具 - 网络队列调度优化                 ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "请选择 Qdisc 算法:"
    echo ""
    echo -e "  ${GREEN}1)${NC} fq       - Fair Queue (推荐配合 BBR)"
    echo "              特点: 专为 pacing 设计，延迟最低"
    echo "              适用: BBR 拥塞控制，低延迟场景"
    echo ""
    echo -e "  ${GREEN}2)${NC} fq_pie   - Flow Queue + PIE AQM"
    echo "              特点: 结合流队列和 PIE 主动队列管理"
    echo "              适用: 需要额外缓冲区管理的场景"
    echo ""
    echo -e "  ${GREEN}3)${NC} fq_codel - Flow Queue + CoDel AQM"
    echo "              特点: 对抗 bufferbloat"
    echo "              适用: 高延迟变化网络"
    echo ""
    echo -e "  ${YELLOW}0)${NC} 退出"
    echo ""
}

# 选择网卡
select_interfaces() {
    local available=($(get_interfaces))
    
    if [[ ${#available[@]} -eq 0 ]]; then
        error "未找到可用网卡"
        exit 1
    fi
    
    echo ""
    echo "检测到以下网卡:"
    echo ""
    
    local idx=1
    for iface in "${available[@]}"; do
        show_interface_info "$iface"
        ((idx++))
    done
    
    echo ""
    echo -e "${CYAN}────────────────────────────────────────${NC}"
    echo ""
    echo "请选择要配置的网卡:"
    echo ""
    
    idx=1
    for iface in "${available[@]}"; do
        echo -e "  ${GREEN}$idx)${NC} $iface"
        ((idx++))
    done
    echo -e "  ${GREEN}a)${NC} 全部网卡"
    echo -e "  ${YELLOW}0)${NC} 返回"
    echo ""
    
    while true; do
        read -p "请输入选择 [1-${#available[@]}/a/0]: " choice
        
        if [[ "$choice" == "0" ]]; then
            return 1
        elif [[ "$choice" == "a" || "$choice" == "A" ]]; then
            SELECTED_INTERFACES=("${available[@]}")
            return 0
        elif [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -ge 1 ]] && [[ $choice -le ${#available[@]} ]]; then
            SELECTED_INTERFACES=("${available[$((choice-1))]}")
            return 0
        else
            warn "无效选择，请重新输入"
        fi
    done
}

# 主流程
main() {
    check_root
    check_deps
    
    while true; do
        show_menu
        read -p "请选择 [0-3]: " algo_choice
        
        case $algo_choice in
            1) ALGO="fq" ;;
            2) ALGO="fq_pie" ;;
            3) ALGO="fq_codel" ;;
            0) 
                info "退出"
                exit 0
                ;;
            *)
                warn "无效选择"
                continue
                ;;
        esac
        
        info "已选择算法: $ALGO"
        
        # 选择网卡
        if ! select_interfaces; then
            continue
        fi
        
        echo ""
        echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
        echo -e "${CYAN}                    开始配置                                ${NC}"
        echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
        
        local total_errors=0
        local configured_ifaces=()
        
        # 应用设置
        for iface in "${SELECTED_INTERFACES[@]}"; do
            echo ""
            if apply_qdisc "$iface" "$ALGO"; then
                configured_ifaces+=("$iface")
            else
                ((total_errors++))
            fi
        done
        
        # 验证设置
        echo ""
        echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
        echo -e "${CYAN}                    验证结果                                ${NC}"
        echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
        
        local verify_errors=0
        for iface in "${SELECTED_INTERFACES[@]}"; do
            if ! verify_qdisc "$iface" "$ALGO"; then
                ((verify_errors++))
            fi
        done
        
        # 持久化询问
        echo ""
        echo -e "${CYAN}────────────────────────────────────────${NC}"
        
        if [[ ${#configured_ifaces[@]} -gt 0 ]]; then
            echo ""
            read -p "是否持久化配置（重启后自动生效）? [Y/n]: " persist
            
            if [[ ! "$persist" =~ ^[Nn]$ ]]; then
                echo ""
                create_persistent_script "$ALGO" "${configured_ifaces[@]}"
                create_systemd_service
                update_sysctl "$ALGO"
                
                echo ""
                success "持久化配置完成！"
                echo ""
                echo "已创建以下文件:"
                echo "  • /usr/local/bin/setup-qdisc-persistent.sh"
                echo "  • /etc/systemd/system/qdisc-setup.service"
                echo "  • /etc/sysctl.d/99-qdisc.conf"
                echo ""
                echo "管理命令:"
                echo "  • systemctl status qdisc-setup.service  # 查看状态"
                echo "  • systemctl restart qdisc-setup.service # 重新应用"
                echo "  • systemctl disable qdisc-setup.service # 禁用自动配置"
            fi
        fi
        
        # 最终总结
        echo ""
        echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
        echo -e "${CYAN}                    配置总结                                ${NC}"
        echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
        echo ""
        
        if [[ $verify_errors -eq 0 ]]; then
            success "所有网卡配置成功！"
        else
            warn "部分网卡配置失败，请检查上方错误信息"
        fi
        
        echo ""
        echo "当前拥塞控制算法: $(sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null || echo '未知')"
        echo "当前默认 qdisc: $(sysctl -n net.core.default_qdisc 2>/dev/null || echo '未知')"
        echo ""
        
        read -p "按 Enter 继续配置其他网卡，或输入 q 退出: " cont
        if [[ "$cont" == "q" || "$cont" == "Q" ]]; then
            break
        fi
    done
    
    info "配置完成，感谢使用！"
}

# 运行主程序
main "$@"
