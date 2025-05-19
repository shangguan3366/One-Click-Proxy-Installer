#!/bin/bash

# ==========================================================
# 项目名称: One-Click-Proxy-Installer
# 功能: 一键部署与管理 Sing-Box Hysteria2 & Reality 节点
# 作者: Zhong Yuan
# 版本: 1.0
# 更新时间: 2025-05-20
# ==========================================================

# ----------- 运行方式检测 -----------
if [[ "$0" =~ ^/dev/fd/ || "$0" =~ ^/proc/self/fd/ ]]; then
    echo -e "\033[0;31m[ERROR]\033[0m 请不要用 'bash <(curl ...)' 或 'bash /dev/fd/...' 方式运行本脚本！"
    echo "请先用 wget 或 curl 下载脚本到本地，再用 bash 或 ./ 运行。"
    echo "例如："
    echo "  wget -O lvhy.sh https://github.com/shangguan3366/One-Click-Proxy-Installer/raw/main/lvhy.sh"
    echo "  chmod +x lvhy.sh"
    echo "  ./lvhy.sh"
    exit 1
fi

# ----------- 统计信息 -----------
STATS_FILE="$HOME/.oneclick_stats"
update_run_stats() {
    local today_str=$(date +%Y-%m-%d)
    if [ -f "$STATS_FILE" ]; then
        source "$STATS_FILE"
    else
        RUN_TOTAL=0
        RUN_TODAY=0
        RUN_TODAY_DATE="$today_str"
    fi
    if [ "$RUN_TODAY_DATE" = "$today_str" ]; then
        RUN_TODAY=$((RUN_TODAY+1))
    else
        RUN_TODAY=1
        RUN_TODAY_DATE="$today_str"
    fi
    RUN_TOTAL=$((RUN_TOTAL+1))
    cat > "$STATS_FILE" <<EOF
RUN_TOTAL=$RUN_TOTAL
RUN_TODAY=$RUN_TODAY
RUN_TODAY_DATE="$RUN_TODAY_DATE"
EOF
}
update_run_stats
if [ -f "$STATS_FILE" ]; then
    source "$STATS_FILE"
fi

# ----------- 颜色与全局变量 -----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'
AUTHOR_NAME="Zhong Yuan"
QUICK_CMD_NAME="k"

# ----------- 信息输出函数 -----------
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

# ----------- 作者信息栏 -----------
print_author_info() {
    echo -e "${MAGENTA}${BOLD}================================================${NC}"
    echo -e "${BOLD}${YELLOW} 项目名称: One-Click-Proxy-Installer ${NC}"
    echo -e "${MAGENTA}${BOLD}================================================${NC}"
    echo -e "${CYAN}${BOLD} Sing-Box Hysteria2 & Reality 管理脚本 ${NC}"
    echo -e "${MAGENTA}${BOLD}================================================${NC}"
    echo -e " ${YELLOW}作者:${NC}      ${GREEN}${AUTHOR_NAME}${NC}"
    echo -e " ${YELLOW}快捷启动指令:${NC} ${GREEN}${QUICK_CMD_NAME}${NC} (全局输入即可快速启动本脚本)"
    echo -e " ${YELLOW}今日运行次数:${NC} ${GREEN}${RUN_TODAY}${NC}   ${YELLOW}总运行次数:${NC} ${GREEN}${RUN_TOTAL}${NC}"
    echo -e "${MAGENTA}${BOLD}================================================${NC}"
}

# ----------- 依赖检测 -----------
check_dependencies() {
    info "检查核心依赖..."
    local core_deps=("curl" "openssl" "qrencode")
    local all_deps_met=true
    for dep in "${core_deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            warn "缺少依赖：$dep，正在尝试安装..."
            if command -v apt-get &>/dev/null; then
                sudo apt-get update -y && sudo apt-get install -y "$dep"
            elif command -v yum &>/dev/null; then
                sudo yum install -y "$dep"
            elif command -v dnf &>/dev/null; then
                sudo dnf install -y "$dep"
            else
                error "未找到已知的包管理器，请手动安装 $dep。"
                all_deps_met=false
            fi
        fi
    done
    if ! $all_deps_met; then
        error "部分依赖未能安装，脚本可能无法正常运行。"
        exit 1
    fi
    success "依赖检查通过。"
}

# ----------- 其余所有功能函数（请将你现有的 get_server_ip、install_singbox_core、create_config_json、display_and_store_config_info、toolbox_menu、show_menu、change_quick_cmd、update_script_online、show_current_import_info、主循环等全部补全到这里，结构与前述模板一致，所有健壮性和体验优化全部保留） -----------

# ...（此处省略，直接粘贴你现有的所有功能函数实现，确保所有函数都在主逻辑前面）...

# ----------- show_current_import_info 优化 -----------
show_current_import_info() {
    # 强制加载上次保存的配置信息
    if [ -f "$PERSISTENT_INFO_FILE" ]; then
        source "$PERSISTENT_INFO_FILE"
    fi
    if [ -z "$LAST_INSTALL_MODE" ]; then
        warn "尚未通过此脚本安装任何配置，或上次安装信息未保留。"
        info "请先执行安装操作 (选项 1, 2, 或 3)，或者确保 ${PERSISTENT_INFO_FILE} 文件存在且包含信息。"
        return
    fi
    info "显示上次保存的配置信息 (${LAST_INSTALL_MODE}模式):"
    display_and_store_config_info "$LAST_INSTALL_MODE"
}

# ----------- 主循环入口 -----------
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        error "此脚本需要以 root 权限运行。请使用 'sudo bash $0'"
        exit 1
    fi
}

check_root
check_dependencies
find_and_set_singbox_cmd
load_persistent_info

while true; do
    show_menu
done
