#!/bin/bash

set -e

# 彩色输出
green(){ echo -e "\033[32m$1\033[0m"; }
red(){ echo -e "\033[31m$1\033[0m"; }

main_menu() {
  clear
  green "==== Proxy-Plus 一键代理&加速工具箱 ===="
  echo "1. 安装/管理 Hysteria2"
  echo "2. 安装/管理 Tuic"
  echo "3. 安装/管理 Trojan"
  echo "4. 部署/管理 BBR v3 加速"
  echo "5. VPS 工具箱"
  echo "0. 退出"
  echo
  read -p "请选择功能 [0-5]: " choice
  case $choice in
    1) bash <(curl -Ls https://raw.githubusercontent.com/seagullz4/hysteria2/main/install.sh) ;;
    2) bash <(curl -Ls https://your-tuic-script-url) ;;
    3) bash <(curl -Ls https://your-trojan-script-url) ;;
    4) bash <(curl -Ls https://raw.githubusercontent.com/byJoey/Actions-bbr-v3/refs/heads/main/install.sh) ;;
    5) bash <(curl -Ls https://your-toolbox-script-url) ;;
    0) exit 0 ;;
    *) red "无效选择，请重新输入"; sleep 1; main_menu ;;
  esac
}

# 环境检测（可扩展）
check_env() {
  if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
    red "请先安装 curl 或 wget"
    exit 1
  fi
}

check_env
while true; do main_menu; done
