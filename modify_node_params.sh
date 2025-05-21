#!/bin/bash

# 必要变量
SINGBOX_CONFIG_FILE="/usr/local/etc/sing-box/config.json"
PERSISTENT_INFO_FILE="/usr/local/etc/sing-box/.last_singbox_script_info"

success() { echo -e "\033[0;32m[SUCCESS]\033[0m $1"; }
error() { echo -e "\033[0;31m[ERROR]\033[0m $1"; }

save_persistent_info() {
    cat > "$PERSISTENT_INFO_FILE" <<EOF
LAST_HY2_PORT="$LAST_HY2_PORT"
LAST_HY2_MASQUERADE_CN="$LAST_HY2_MASQUERADE_CN"
LAST_REALITY_PORT="$LAST_REALITY_PORT"
LAST_REALITY_UUID="$LAST_REALITY_UUID"
LAST_REALITY_SNI="$LAST_REALITY_SNI"
LAST_INSTALL_MODE="$LAST_INSTALL_MODE"
EOF
}

# 读取上次参数
if [ -f "$PERSISTENT_INFO_FILE" ]; then
    source "$PERSISTENT_INFO_FILE"
fi

if [ ! -f "$SINGBOX_CONFIG_FILE" ]; then
    error "未检测到配置文件，无法修改参数。"
    read -n 1 -s -r -p "按任意键返回主菜单..."
    exit 1
fi

while true; do
    clear
    echo -e "当前节点参数:"
    echo "  1. Hysteria2 端口: $LAST_HY2_PORT"
    echo "  2. Hysteria2 伪装域名: $LAST_HY2_MASQUERADE_CN"
    echo "  3. Reality 端口: $LAST_REALITY_PORT"
    echo "  4. Reality UUID: $LAST_REALITY_UUID"
    echo "  5. Reality SNI: $LAST_REALITY_SNI"
    echo "  6. 删除当前节点（清空配置）"
    echo "  0. 返回主菜单"
    read -p "请选择要操作的项目 [0-6]: " param_choice
    case "$param_choice" in
        1)
            read -p "请输入新的 Hysteria2 端口: " new_port
            if [[ -n "$new_port" ]]; then
                sed -i "s/\"listen_port\": $LAST_HY2_PORT/\"listen_port\": $new_port/" "$SINGBOX_CONFIG_FILE"
                LAST_HY2_PORT="$new_port"
                save_persistent_info
                systemctl restart sing-box
                success "Hysteria2 端口已修改并重启服务。"
            fi
            ;;
        2)
            read -p "请输入新的 Hysteria2 伪装域名: " new_cn
            if [[ -n "$new_cn" ]]; then
                sed -i "s/\"server_name\": \"$LAST_HY2_MASQUERADE_CN\"/\"server_name\": \"$new_cn\"/" "$SINGBOX_CONFIG_FILE"
                LAST_HY2_MASQUERADE_CN="$new_cn"
                save_persistent_info
                systemctl restart sing-box
                success "Hysteria2 伪装域名已修改并重启服务。"
            fi
            ;;
        3)
            read -p "请输入新的 Reality 端口: " new_port
            if [[ -n "$new_port" ]]; then
                sed -i "s/\"listen_port\": $LAST_REALITY_PORT/\"listen_port\": $new_port/" "$SINGBOX_CONFIG_FILE"
                LAST_REALITY_PORT="$new_port"
                save_persistent_info
                systemctl restart sing-box
                success "Reality 端口已修改并重启服务。"
            fi
            ;;
        4)
            read -p "请输入新的 Reality UUID: " new_uuid
            if [[ -n "$new_uuid" ]]; then
                sed -i "s/\"uuid\": \"$LAST_REALITY_UUID\"/\"uuid\": \"$new_uuid\"/" "$SINGBOX_CONFIG_FILE"
                LAST_REALITY_UUID="$new_uuid"
                save_persistent_info
                systemctl restart sing-box
                success "Reality UUID已修改并重启服务。"
            fi
            ;;
        5)
            read -p "请输入新的 Reality SNI: " new_sni
            if [[ -n "$new_sni" ]]; then
                sed -i "s/\"server_name\": \"$LAST_REALITY_SNI\"/\"server_name\": \"$new_sni\"/" "$SINGBOX_CONFIG_FILE"
                LAST_REALITY_SNI="$new_sni"
                save_persistent_info
                systemctl restart sing-box
                success "Reality SNI已修改并重启服务。"
            fi
            ;;
        6)
            read -p "确定要删除当前节点配置吗？此操作不可恢复！(y/N): " del_confirm
            if [[ "$del_confirm" =~ ^[Yy]$ ]]; then
                rm -f "$SINGBOX_CONFIG_FILE"
                rm -f "$PERSISTENT_INFO_FILE"
                systemctl stop sing-box
                LAST_HY2_PORT=""
                LAST_HY2_MASQUERADE_CN=""
                LAST_REALITY_PORT=""
                LAST_REALITY_UUID=""
                LAST_REALITY_SNI=""
                LAST_INSTALL_MODE=""
                success "节点配置已删除，Sing-box 服务已停止。"
                read -n 1 -s -r -p "按任意键返回主菜单..."
                break
            else
                echo "操作已取消。"
                read -n 1 -s -r -p "按任意键返回主菜单..."
            fi
            ;;
        0)
            read -n 1 -s -r -p "按任意键返回主菜单..."
            break
            ;;
        *)
            echo "无效选项。"
            ;;
    esac
    read -n 1 -s -r -p "按任意键返回主菜单..."
done 
