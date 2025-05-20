     if command -v ufw &>/dev/null; then
                        sudo ufw allow 0:65535/tcp
                        sudo ufw allow 0:65535/udp
                        sudo ufw reload
                        echo "已通过 ufw 放行全部端口。"
                    elif command -v firewall-cmd &>/dev/null; then
                        sudo firewall-cmd --permanent --add-port=0-65535/tcp
                        sudo firewall-cmd --permanent --add-port=0-65535/udp
                        sudo firewall-cmd --reload
                        echo "已通过 firewalld 放行全部端口。"
                    else
                        echo "未检测到常见防火墙（ufw/firewalld），请手动放行端口。"
                    fi
                else
                    echo "操作已取消。"
                fi
                read -n 1 -s -r -p "按任意键返回工具箱..."
                ;;
            3)
                echo -e "${CYAN}${BOLD}\n========= 本机信息 =========${NC}"
                # 主机名、系统
                echo -e "${YELLOW}主机名:${NC}      $(hostname)"
                echo -e "${YELLOW}系统:${NC}        $(uname -o)"
                echo -e "${YELLOW}Linux版本:${NC}   $(uname -r)"
                echo -e "${YELLOW}发行版:${NC}      $(. /etc/os-release 2>/dev/null; echo $PRETTY_NAME)"
                # CPU
                echo -e "${YELLOW}CPU架构:${NC}     $(uname -m)"
                echo -e "${YELLOW}CPU型号:${NC}     $(awk -F: '/model name/ {print $2; exit}' /proc/cpuinfo | xargs)"
                echo -e "${YELLOW}CPU核心数:${NC}   $(nproc)"
                echo -e "${YELLOW}CPU占用:${NC}     $(top -bn1 | awk '/Cpu/ {print $2"%"; exit}')"
                # 内存
                mem_total=$(free -h | awk '/Mem:/ {print $2}')
                mem_used=$(free -h | awk '/Mem:/ {print $3}')
                swap_total=$(free -h | awk '/Swap:/ {print $2}')
                swap_used=$(free -h | awk '/Swap:/ {print $3}')
                echo -e "${YELLOW}物理内存:${NC}    $mem_used / $mem_total"
                echo -e "${YELLOW}虚拟内存:${NC}    $swap_used / $swap_total"
                # 硬盘
                disk_total=$(df -h --total | awk '/total/ {print $2}')
                disk_used=$(df -h --total | awk '/total/ {print $3}')
                echo -e "${YELLOW}硬盘占用:${NC}    $disk_used / $disk_total"
                # 流量
                rx=$(cat /proc/net/dev | awk '/:/ {sum+=$2} END {print sum/1024/1024 " MB"}')
                tx=$(cat /proc/net/dev | awk '/:/ {sum+=$10} END {print sum/1024/1024 " MB"}')
                echo -e "${YELLOW}总接收流量:${NC}  $rx"
                echo -e "${YELLOW}总发送流量:${NC}  $tx"
                # 拥堵算法
                cc_alg=$(sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null)
                echo -e "${YELLOW}网络拥堵算法:${NC} $cc_alg"
                # 公网IP
                ipv4=$(curl -s --max-time 3 https://api.ipify.org)
                ipv6=$(curl -s --max-time 3 https://api6.ipify.org)
                echo -e "${YELLOW}公网IPv4:${NC}    $ipv4"
                echo -e "${YELLOW}公网IPv6:${NC}    $ipv6"
                # 运营商与地理位置
                ipinfo=$(curl -s --max-time 5 ipinfo.io/json)
                isp=$(echo "$ipinfo" | grep 'org' | awk -F: '{print $2}' | tr -d ' ",')
                loc=$(echo "$ipinfo" | grep 'city' | awk -F: '{print $2}' | tr -d ' ",')
                country=$(echo "$ipinfo" | grep 'country' | awk -F: '{print $2}' | tr -d ' ",')
                echo -e "${YELLOW}运营商:${NC}      $isp"
                echo -e "${YELLOW}地理位置:${NC}    $loc, $country"
                # 系统时间与运行时长
                echo -e "${YELLOW}系统时间:${NC}    $(date '+%Y-%m-%d %H:%M:%S')"
                echo -e "${YELLOW}运行时长:${NC}    $(uptime -p)"
                echo -e "${CYAN}${BOLD}==============================${NC}\n"
                read -n 1 -s -r -p "按任意键返回工具箱..."
                ;;
            4)
                # DNS优化
                echo -e "${CYAN}请选择DNS优化方案："
                echo "  1. 国外DNS (1.1.1.1, 8.8.8.8)"
                echo "  2. 国内DNS (223.5.5.5, 180.76.76.76, 114.114.114.114)"
                echo "  0. 取消"
                read -p "请输入选项 [0-2]: " dns_opt
                case "$dns_opt" in
                    1)
                        echo -e "nameserver 1.1.1.1\nnameserver 8.8.8.8" | sudo tee /etc/resolv.conf
                        echo "已切换为国外DNS。"
                        ;;
                    2)
                        echo -e "nameserver 223.5.5.5\nnameserver 180.76.76.76\nnameserver 114.114.114.114" | sudo tee /etc/resolv.conf
                        echo "已切换为国内DNS。"
                        ;;
                    *)
                        echo "操作已取消。"
                        ;;
                esac
                read -n 1 -s -r -p "按任意键返回工具箱..."
                ;;
            5)
                # BBR管理
                echo -e "${CYAN}BBR管理："
                bbr_status=$(sysctl net.ipv4.tcp_congestion_control 2>/dev/null | grep -q bbr && echo 已开启 || echo 未开启)
                echo -e "当前BBR状态：${GREEN}$bbr_status${NC}"
                echo "  1. 开启BBR"
                echo "  2. 关闭BBR"
                echo "  0. 返回"
                read -p "请输入选项 [0-2]: " bbr_opt
                case "$bbr_opt" in
                    1)
                        sudo modprobe tcp_bbr
                        echo 'net.core.default_qdisc=fq' | sudo tee -a /etc/sysctl.conf
                        echo 'net.ipv4.tcp_congestion_control=bbr' | sudo tee -a /etc/sysctl.conf
                        sudo sysctl -p
                        echo "BBR已开启。"
                        ;;
                    2)
                        sudo sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
                        sudo sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
                        sudo sysctl -p
                        echo "BBR已关闭。"
                        ;;
                    *)
                        echo "操作已取消。"
                        ;;
                esac
                read -n 1 -s -r -p "按任意键返回工具箱..."
                ;;
            6)
                # 组件管理
                while true; do
                    clear
                    echo -e "${CYAN}组件管理："
                    echo "  1. 安装curl"
                    echo "  2. 安装wget"
                    echo "  3. 安装sudo"
                    echo "  4. 安装unzip"
                    echo "  0. 返回"
                    read -p "请输入选项 [0-4]: " comp_opt
                    case "$comp_opt" in
                        1)
                            if command -v curl &>/dev/null; then echo "curl已安装。"; else sudo apt-get install -y curl || sudo yum install -y curl; fi
                            ;;
                        2)
                            if command -v wget &>/dev/null; then echo "wget已安装。"; else sudo apt-get install -y wget || sudo yum install -y wget; fi
                            ;;
                        3)
                            if command -v sudo &>/dev/null; then echo "sudo已安装。"; else apt-get install -y sudo || yum install -y sudo; fi
                            ;;
                        4)
                            if command -v unzip &>/dev/null; then echo "unzip已安装。"; else sudo apt-get install -y unzip || sudo yum install -y unzip; fi
                            ;;
                        0)
                            break
                            ;;
                        *)
                            echo "无效选项。"; sleep 1
                            ;;
                    esac
                    read -n 1 -s -r -p "按任意键返回组件管理..."
                done
                ;;
            7)
                # 一键开启BBR3
                echo -e "${CYAN}一键开启BBR3："
                if uname -r | grep -qE '5\.|6\.'; then
                    sudo modprobe tcp_bbr
                    echo 'net.core.default_qdisc=fq' | sudo tee -a /etc/sysctl.conf
                    echo 'net.ipv4.tcp_congestion_control=bbr' | sudo tee -a /etc/sysctl.conf
                    sudo sysctl -p
                    echo "BBR3已尝试开启（如内核支持）。"
                else
                    echo "当前内核版本不支持BBR3。"
                fi
                read -n 1 -s -r -p "按任意键返回工具箱..."
                ;;
            8)
                # 系统时区调整
                echo -e "${CYAN}请选择时区："
                echo "  1. Asia/Shanghai (中国)"
                echo "  2. UTC (世界标准)"
                echo "  0. 取消"
                read -p "请输入选项 [0-2]: " tz_opt
                case "$tz_opt" in
                    1)
                        sudo timedatectl set-timezone Asia/Shanghai
                        echo "已切换为Asia/Shanghai。"
                        ;;
                    2)
                        sudo timedatectl set-timezone UTC
                        echo "已切换为UTC。"
                        ;;
                    *)
                        echo "操作已取消。"
                        ;;
                esac
                read -n 1 -s -r -p "按任意键返回工具箱..."
                ;;
            9)
                # 切换优先IPv4/IPv6
                echo -e "${CYAN}请选择优先协议："
                echo "  1. 优先IPv4"
                echo "  2. 优先IPv6"
                echo "  0. 取消"
                read -p "请输入选项 [0-2]: " ipver_opt
                case "$ipver_opt" in
                    1)
                        sudo sed -i '/^precedence ::ffff:0:0\/96  100$/d' /etc/gai.conf
                        echo 'precedence ::ffff:0:0/96  100' | sudo tee -a /etc/gai.conf
                        echo "已设置为优先IPv4。"
                        ;;
                    2)
                        sudo sed -i '/^precedence ::ffff:0:0\/96  100$/d' /etc/gai.conf
                        echo "已设置为优先IPv6。"
                        ;;
                    *)
                        echo "操作已取消。"
                        ;;
                esac
                read -n 1 -s -r -p "按任意键返回工具箱..."
                ;;
            10)
                # 修改Root密码
                echo -e "${CYAN}请输入新Root密码："
                sudo passwd root
                read -n 1 -s -r -p "按任意键返回工具箱..."
                ;;
            11)
                # 开启Root密码登录
                sudo sed -i 's/^#*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
                sudo sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
                sudo systemctl restart sshd || sudo systemctl restart ssh
                echo "已开启Root密码登录（请确保已设置Root密码）。"
                read -n 1 -s -r -p "按任意键返回工具箱..."
                ;;
            12)
                # 重启服务器
                echo -e "${YELLOW}警告：即将重启服务器，是否继续？${NC}"
                read -p "输入y确认重启，其他键取消: " reboot_confirm
                if [[ "$reboot_confirm" =~ ^[Yy]$ ]]; then
                    sudo reboot
                else
                    echo "操作已取消。"
                fi
                read -n 1 -s -r -p "按任意键返回工具箱..."
                ;;
            0)
                break
                ;;
            *)
                echo "无效选项，请输入 0-12。"
                sleep 1
                ;;
        esac
    done
}

# --- Main Menu ---
show_menu() {
    clear
    print_author_info
    echo -e "${MAGENTA}${BOLD}=================【安装相关】==================${NC}"
    echo "  1. 安装 Hysteria2 + Reality (共存)"
    echo "  2. 单独安装 Hysteria2"
    echo "  3. 单独安装 Reality (VLESS)"
    echo -e "${MAGENTA}${BOLD}=================【管理相关】==================${NC}"
    echo "  4. 启动 Sing-box 服务"
    echo "  5. 停止 Sing-box 服务"
    echo "  6. 重启 Sing-box 服务"
    echo "  7. 查看 Sing-box 服务状态"
    echo "  8. 查看 Sing-box 实时日志"
    echo "  9. 查看当前配置文件"
    echo " 10. 编辑当前配置文件 (nano/vim)"
    echo " 11. 显示"节点"的导入信息 (含二维码)"
    echo -e "${MAGENTA}${BOLD}=================【工具箱】====================${NC}"
    echo " 12. 工具箱"
    echo -e "${MAGENTA}${BOLD}=================【其他】======================${NC}"
    echo " 13. 卸载 Sing-box"
    echo " 14. 更改快捷指令"
    echo " 15. 在线更新脚本"
    echo "  0. 退出脚本"
    echo -e "${MAGENTA}${BOLD}===============================================${NC}"
    read -p "请输入选项 [0-15]: " choice

    case "$choice" in
        1) install_hysteria2_reality ;;
        2) install_hysteria2_only ;;
        3) install_reality_only ;;
        4) manage_singbox "start" ;;
        5) manage_singbox "stop" ;;
        6) manage_singbox "restart" ;;
        7) manage_singbox "status" ;;
        8) manage_singbox "log" ;;
        9) manage_singbox "view_config" ;;
        10) manage_singbox "edit_config" ;;
        11) show_current_import_info ;;
        12) toolbox_menu ;;
        13) uninstall_singbox ;;
        14) change_quick_cmd ;;
        15) update_script_online ;;
        0) exit 0 ;;
        *) error "无效选项，请输入 0 到 15 之间的数字。" ;;
    esac
    echo "" 
}

# --- Script Entry Point ---
check_root
check_dependencies # 已移除 jq 依赖检查
find_and_set_singbox_cmd
load_persistent_info

# Main loop
while true; do
    show_menu
    # 只在需要时 pause，show_menu 内部不再 pause
    # read -n 1 -s -r -p "按任意键返回主菜单 (或按 Ctrl+C 退出)..."
done

# --- 脚本末尾自动化一键设置快捷命令功能 ---
if [ "$(basename $0)" != "$QUICK_CMD_NAME" ] && [ ! -f "/usr/local/bin/$QUICK_CMD_NAME" ]; then
    echo "\n检测到你还没有设置快捷命令，是否添加？"
    read -p "输入 y 添加快捷命令 $QUICK_CMD_NAME，输入 n 跳过 [y/n]: " quick_choice
    if [[ "$quick_choice" =~ ^[Yy]$ ]]; then
        sudo cp "$0" "/usr/local/bin/$QUICK_CMD_NAME"
        sudo chmod +x "/usr/local/bin/$QUICK_CMD_NAME"
        echo "\n现在你可以直接输入 $QUICK_CMD_NAME 快速管理 Sing-Box 节点了！"
    fi
fi
