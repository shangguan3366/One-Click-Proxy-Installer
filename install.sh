#!/bin/bash

# One-Click Proxy Installer
# Maintainer: Zhong Yuan <qq1257343366@gmail.com>

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# 检查 root 权限
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}请以 root 权限运行${NC}"
   exit 1
fi

echo "欢迎使用一键代理安装工具！"
echo "请选择操作："
echo "1) 安装 BBR"
echo "2) 安装 V2Ray"
echo "3) 退出"
read -p "输入选项 [1-3]: " choice

case $choice in
    1)
        echo "正在安装 BBR..."
        echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.conf
        sudo sysctl -p
        ;;
    2)
        echo "正在安装 V2Ray..."
        bash <(curl -sL https://github.com/v2fly/v2ray-core/releases/latest/download/install-release.sh)
        ;;
    3)
        echo "退出..."
        exit 0
        ;;
    *)
        echo -e "${RED}无效选项${NC}"
        exit 1
        ;;
esac

echo -e "${GREEN}安装完成！${NC}"
