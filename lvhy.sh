#!/usr/bin/env bash
# sing-box 多协议一键管理脚本
# 适配主流 Linux/MacOS，支持 IPv6，结构清晰，便于扩展
# 作者：AI助手

set -e

# 检查 root 权限
if [ "$EUID" -ne 0 ]; then
  echo "请以 root 权限运行此脚本！"
  exit 1
fi

# 颜色定义
RED="\033[31m"; GREEN="\033[32m"; YELLOW="\033[33m"; BLUE="\033[36m"; NC="\033[0m"

# 节点信息存储路径
NODE_FILE="/etc/sing-box/nodes.json"
CONFIG_FILE="/etc/sing-box/config.json"

# 初始化节点存储文件
init_node_file() {
  mkdir -p /etc/sing-box
  [ -f "$NODE_FILE" ] || echo '[]' > "$NODE_FILE"
}

# 读取所有节点
read_nodes() {
  cat "$NODE_FILE"
}

# 保存所有节点
save_nodes() {
  echo "$1" > "$NODE_FILE"
}

# 主菜单
main_menu() {
  clear
  echo -e "${BLUE}================== sing-box 多协议管理工具箱 ==================${NC}"
  echo -e "${GREEN}1.${NC} 节点管理（添加/删除/导入/导出/二维码/多协议）"
  echo -e "${GREEN}2.${NC} 工具箱（常用网络/系统工具，后续可扩展）"
  echo -e "${GREEN}3.${NC} 系统维护（备份/恢复/日志/证书/IPv6）"
  echo -e "${GREEN}4.${NC} 脚本管理（安装/更新/卸载/关于）"
  echo -e "${GREEN}0.${NC} 退出"
  echo -e "${BLUE}==============================================================${NC}"
  read -rp "请输入选项 [0-4]: " menu_num
  case $menu_num in
    1) node_menu ;;
    2) toolbox_menu ;;
    3) sys_menu ;;
    4) script_menu ;;
    0) exit 0 ;;
    *) echo -e "${RED}无效输入，请重新选择！${NC}"; sleep 1; main_menu ;;
  esac
}

# 节点管理菜单（预留功能接口）
node_menu() {
  clear
  echo -e "${YELLOW}------ 节点管理 ------${NC}"
  echo -e "1. 添加节点"
  echo -e "2. 删除节点"
  echo -e "3. 查看节点"
  echo -e "4. 批量导入节点"
  echo -e "5. 批量导出节点"
  echo -e "6. 显示节点二维码"
  echo -e "7. 返回主菜单"
  read -rp "请选择 [1-7]: " node_num
  case $node_num in
    1) add_node ;;
    2) del_node ;;
    3) list_node ;;
    4) import_node ;;
    5) export_node ;;
    6) show_qr ;;
    7) main_menu ;;
    *) echo -e "${RED}无效输入！${NC}"; sleep 1; node_menu ;;
  esac
}

# 工具箱菜单（预留功能接口）
toolbox_menu() {
  clear
  echo -e "${YELLOW}------ 工具箱 ------${NC}"
  echo -e "1. 安装常用工具（如 btop、htop、speedtest 等）"
  echo -e "2. 返回主菜单"
  read -rp "请选择 [1-2]: " tool_num
  case $tool_num in
    1) install_tools ;;
    2) main_menu ;;
    *) echo -e "${RED}无效输入！${NC}"; sleep 1; toolbox_menu ;;
  esac
}

# 系统维护菜单（预留功能接口）
sys_menu() {
  clear
  echo -e "${YELLOW}------ 系统维护 ------${NC}"
  echo -e "1. 备份配置"
  echo -e "2. 恢复配置"
  echo -e "3. 查看 sing-box 日志"
  echo -e "4. 证书管理"
  echo -e "5. 返回主菜单"
  read -rp "请选择 [1-5]: " sys_num
  case $sys_num in
    1) backup_config ;;
    2) restore_config ;;
    3) view_log ;;
    4) cert_menu ;;
    5) main_menu ;;
    *) echo -e "${RED}无效输入！${NC}"; sleep 1; sys_menu ;;
  esac
}

# 脚本管理菜单（预留功能接口）
script_menu() {
  clear
  echo -e "${YELLOW}------ 脚本管理 ------${NC}"
  echo -e "1. 安装/升级 sing-box"
  echo -e "2. 卸载 sing-box"
  echo -e "3. 检查更新本脚本"
  echo -e "4. 关于/帮助"
  echo -e "5. 返回主菜单"
  read -rp "请选择 [1-5]: " script_num
  case $script_num in
    1) install_singbox ;;
    2) uninstall_singbox ;;
    3) update_script ;;
    4) about_script ;;
    5) main_menu ;;
    *) echo -e "${RED}无效输入！${NC}"; sleep 1; script_menu ;;
  esac
}

# 检测系统类型和架构
get_system_arch() {
  SYS="unknown"; ARCH="unknown"
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
      ubuntu|debian) SYS="debian" ;;
      centos|rhel|almalinux|rocky) SYS="centos" ;;
      alpine) SYS="alpine" ;;
      arch) SYS="arch" ;;
      *) SYS="$ID" ;;
    esac
  elif uname -s | grep -qi darwin; then
    SYS="macos"
  fi
  CPU_ARCH=$(uname -m)
  case "$CPU_ARCH" in
    x86_64|amd64) ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    armv7l) ARCH="armv7" ;;
    mips64) ARCH="mips64" ;;
    *) ARCH="$CPU_ARCH" ;;
  esac
}

# 获取 sing-box 最新版本号
get_latest_version() {
  LATEST=$(curl -s https://api.github.com/repos/SagerNet/sing-box/releases/latest | grep tag_name | cut -d '"' -f4)
  echo "$LATEST"
}

# 安装依赖
install_deps() {
  case "$SYS" in
    debian) apt update && apt install -y curl tar gzip systemd jq ;;
    centos) yum install -y curl tar gzip systemd jq ;;
    alpine) apk add --no-cache curl tar gzip openrc jq ;;
    arch) pacman -Sy --noconfirm curl tar gzip jq ;;
    macos) brew install curl jq ;;
    *) echo "未知系统，请手动安装 curl tar gzip jq" ;;
  esac
}

# 安装/升级 sing-box
install_singbox() {
  clear
  echo -e "${GREEN}正在安装/升级 sing-box...${NC}"
  get_system_arch
  install_deps
  VERSION=$(get_latest_version)
  [ -z "$VERSION" ] && echo -e "${RED}获取 sing-box 版本失败！${NC}" && pause_return_menu script_menu && return
  DL_URL="https://github.com/SagerNet/sing-box/releases/download/${VERSION}/sing-box-${VERSION}-linux-${ARCH}.tar.gz"
  [ "$SYS" = "macos" ] && DL_URL="https://github.com/SagerNet/sing-box/releases/download/${VERSION}/sing-box-${VERSION}-darwin-${ARCH}.tar.gz"
  TMP_DIR=$(mktemp -d)
  cd "$TMP_DIR"
  echo -e "下载: $DL_URL"
  curl -L --retry 3 -o sing-box.tar.gz "$DL_URL" || { echo -e "${RED}下载失败！${NC}"; pause_return_menu script_menu; return; }
  tar -xzf sing-box.tar.gz
  if [ -f sing-box ]; then
    mv sing-box /usr/local/bin/
  elif [ -f sing-box-${VERSION}-linux-${ARCH}/sing-box ]; then
    mv sing-box-${VERSION}-linux-${ARCH}/sing-box /usr/local/bin/
  elif [ -f sing-box-${VERSION}-darwin-${ARCH}/sing-box ]; then
    mv sing-box-${VERSION}-darwin-${ARCH}/sing-box /usr/local/bin/
  else
    echo -e "${RED}解压失败！${NC}"; pause_return_menu script_menu; return
  fi
  chmod +x /usr/local/bin/sing-box
  cd ~ && rm -rf "$TMP_DIR"
  # 创建 systemd 服务
  if [ "$SYS" != "macos" ]; then
    cat >/etc/systemd/system/sing-box.service <<EOF
[Unit]
Description=sing-box Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/sing-box run -c /etc/sing-box/config.json
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
    mkdir -p /etc/sing-box
    touch /etc/sing-box/config.json
    systemctl daemon-reload
    systemctl enable sing-box
    systemctl restart sing-box
    echo -e "${GREEN}sing-box 已安装并启动！${NC}"
  else
    echo -e "${YELLOW}MacOS 下请手动运行 sing-box。${NC}"
  fi
  pause_return_menu script_menu
}

# 卸载 sing-box
uninstall_singbox() {
  clear
  echo -e "${RED}即将卸载 sing-box，是否继续？(y/n)${NC}"
  read -r yn
  case $yn in
    [Yy]*)
      systemctl stop sing-box 2>/dev/null || true
      systemctl disable sing-box 2>/dev/null || true
      rm -f /usr/local/bin/sing-box
      rm -f /etc/systemd/system/sing-box.service
      rm -rf /etc/sing-box
      systemctl daemon-reload 2>/dev/null || true
      echo -e "${GREEN}sing-box 已卸载。${NC}"
      ;;
    *) echo "已取消卸载。" ;;
  esac
  pause_return_menu script_menu
}

# 添加节点
add_node() {
  clear
  echo -e "${GREEN}添加新节点${NC}"
  echo -e "1. Reality/VLESS"
  echo -e "2. Hysteria2"
  echo -e "0. 返回上级菜单"
  read -rp "请选择协议类型 [0-2]: " proto
  case $proto in
    1)
      add_node_reality
      ;;
    2)
      add_node_hysteria2
      ;;
    0)
      node_menu
      ;;
    *)
      echo -e "${RED}无效输入！${NC}"; sleep 1; add_node
      ;;
  esac
}

# Reality/VLESS 节点添加
add_node_reality() {
  echo -e "${YELLOW}请输入 Reality/VLESS 节点信息：${NC}"
  read -rp "节点名称: " name
  read -rp "端口: " port
  read -rp "UUID: " uuid
  read -rp "SNI(如 www.microsoft.com): " sni
  read -rp "公钥: " pubkey
  read -rp "Short ID: " shortid
  read -rp "SpiderX(可选): " spiderx
  # 组装节点对象
  node=$(jq -n --arg name "$name" --arg proto "reality" --arg port "$port" --arg uuid "$uuid" --arg sni "$sni" --arg pubkey "$pubkey" --arg shortid "$shortid" --arg spiderx "$spiderx" '{name:$name,proto:$proto,port:$port,uuid:$uuid,sni:$sni,pubkey:$pubkey,shortid:$shortid,spiderx:$spiderx}')
  nodes=$(read_nodes)
  nodes=$(echo "$nodes" | jq ". + [ $node ]")
  save_nodes "$nodes"
  echo -e "${GREEN}节点已添加！${NC}"
  update_config_and_restart
  pause_return_menu node_menu
}

# Hysteria2 节点添加
add_node_hysteria2() {
  echo -e "${YELLOW}请输入 Hysteria2 节点信息：${NC}"
  read -rp "节点名称: " name
  read -rp "端口: " port
  read -rp "密码: " password
  read -rp "SNI(如 www.microsoft.com): " sni
  read -rp "ALPN(可选，默认h3): " alpn
  # 组装节点对象
  node=$(jq -n --arg name "$name" --arg proto "hysteria2" --arg port "$port" --arg password "$password" --arg sni "$sni" --arg alpn "$alpn" '{name:$name,proto:$proto,port:$port,password:$password,sni:$sni,alpn:$alpn}')
  nodes=$(read_nodes)
  nodes=$(echo "$nodes" | jq ". + [ $node ]")
  save_nodes "$nodes"
  echo -e "${GREEN}节点已添加！${NC}"
  update_config_and_restart
  pause_return_menu node_menu
}

# 删除节点
del_node() {
  clear
  nodes=$(read_nodes)
  count=$(echo "$nodes" | jq 'length')
  if [ "$count" -eq 0 ]; then
    echo -e "${YELLOW}暂无节点。${NC}"
    pause_return_menu node_menu
    return
  fi
  echo -e "${GREEN}现有节点列表：${NC}"
  for i in $(seq 0 $((count-1))); do
    n=$(echo "$nodes" | jq ".[$i]")
    name=$(echo "$n" | jq -r .name)
    proto=$(echo "$n" | jq -r .proto)
    port=$(echo "$n" | jq -r .port)
    echo "$((i+1)). $name [$proto] 端口:$port"
  done
  read -rp "请输入要删除的节点序号（0返回）: " idx
  if [ "$idx" = "0" ]; then node_menu; return; fi
  if ! [[ "$idx" =~ ^[0-9]+$ ]] || [ "$idx" -lt 1 ] || [ "$idx" -gt "$count" ]; then
    echo -e "${RED}输入无效！${NC}"; sleep 1; del_node; return
  fi
  nodes=$(echo "$nodes" | jq ".[:$((idx-1))] + .[$idx:]")
  save_nodes "$nodes"
  echo -e "${GREEN}节点已删除。${NC}"
  update_config_and_restart
  pause_return_menu node_menu
}

# 查看节点
list_node() {
  clear
  nodes=$(read_nodes)
  count=$(echo "$nodes" | jq 'length')
  if [ "$count" -eq 0 ]; then
    echo -e "${YELLOW}暂无节点。${NC}"
    pause_return_menu node_menu
    return
  fi
  echo -e "${GREEN}现有节点列表：${NC}"
  for i in $(seq 0 $((count-1))); do
    n=$(echo "$nodes" | jq ".[$i]")
    name=$(echo "$n" | jq -r .name)
    proto=$(echo "$n" | jq -r .proto)
    port=$(echo "$n" | jq -r .port)
    echo "$((i+1)). $name [$proto] 端口:$port"
  done
  pause_return_menu node_menu
}

# 根据节点信息自动生成 sing-box 配置并重启服务
update_config_and_restart() {
  nodes=$(read_nodes)
  inbounds="[]"
  outbounds="[]"
  # 遍历节点，生成 inbounds/outbounds
  count=$(echo "$nodes" | jq 'length')
  for i in $(seq 0 $((count-1))); do
    n=$(echo "$nodes" | jq ".[$i]")
    proto=$(echo "$n" | jq -r .proto)
    port=$(echo "$n" | jq -r .port)
    if [ "$proto" = "reality" ]; then
      uuid=$(echo "$n" | jq -r .uuid)
      sni=$(echo "$n" | jq -r .sni)
      pubkey=$(echo "$n" | jq -r .pubkey)
      shortid=$(echo "$n" | jq -r .shortid)
      spiderx=$(echo "$n" | jq -r .spiderx)
      inbound=$(jq -n --arg port "$port" --arg uuid "$uuid" --arg sni "$sni" --arg pubkey "$pubkey" --arg shortid "$shortid" --arg spiderx "$spiderx" '{
        type: "vless",
        listen: "::",
        listen_port: ($port|tonumber),
        users: [{uuid: $uuid}],
        tls: {
          enabled: true,
          server_name: $sni,
          reality: {
            enabled: true,
            public_key: $pubkey,
            short_id: $shortid
          }
        },
        sniff: {enabled: true, override_destination: true},
        tag: ("inbound-vless-"+$port)
      }')
      inbounds=$(echo "$inbounds" | jq ". + [ $inbound ]")
    elif [ "$proto" = "hysteria2" ]; then
      password=$(echo "$n" | jq -r .password)
      sni=$(echo "$n" | jq -r .sni)
      alpn=$(echo "$n" | jq -r .alpn)
      [ -z "$alpn" ] && alpn="h3"
      inbound=$(jq -n --arg port "$port" --arg password "$password" --arg sni "$sni" --arg alpn "$alpn" '{
        type: "hysteria2",
        listen: "::",
        listen_port: ($port|tonumber),
        users: [{password: $password}],
        tls: {
          enabled: true,
          server_name: $sni,
          alpn: [$alpn]
        },
        tag: ("inbound-hy2-"+$port)
      }')
      inbounds=$(echo "$inbounds" | jq ". + [ $inbound ]")
    fi
  done
  # 默认出站
  outbounds='[{"type":"direct","tag":"direct"},{"type":"block","tag":"block"}]'
  # 组装 config
  config=$(jq -n --argjson inbounds "$inbounds" --argjson outbounds "$outbounds" '{log:{level:"info",output:"/var/log/sing-box.log"},inbounds:$inbounds,outbounds:$outbounds}')
  echo "$config" > "$CONFIG_FILE"
  systemctl restart sing-box 2>/dev/null || true
}

# 批量导入节点
import_node() {
  clear
  echo -e "${GREEN}批量导入节点${NC}"
  echo -e "请粘贴节点链接（每行一个，支持 Reality/VLESS、Hysteria2），输入完毕后 Ctrl+D 结束："
  input_links=""
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    input_links+="$line\n"
  done
  # 解析每一行
  nodes=$(read_nodes)
  added=0
  echo -e "$input_links" | while IFS= read -r link; do
    proto=$(echo "$link" | cut -d':' -f1)
    if [[ "$proto" == "vless"* ]]; then
      # vless://uuid@host:port?params#name
      uuid=$(echo "$link" | sed -n 's#vless://\([^@]*\)@.*#\1#p')
      host=$(echo "$link" | sed -n 's#vless://[^@]*@\([^:]*\):.*#\1#p')
      port=$(echo "$link" | sed -n 's#vless://[^@]*@[^:]*:\([0-9]*\).*#\1#p')
      name=$(echo "$link" | grep -oE '#.*' | sed 's/#//')
      sni=$(echo "$link" | grep -oE 'sni=[^&]*' | cut -d'=' -f2)
      pubkey=$(echo "$link" | grep -oE 'publicKey=[^&]*' | cut -d'=' -f2)
      shortid=$(echo "$link" | grep -oE 'shortId=[^&]*' | cut -d'=' -f2)
      node=$(jq -n --arg name "$name" --arg proto "reality" --arg port "$port" --arg uuid "$uuid" --arg sni "$sni" --arg pubkey "$pubkey" --arg shortid "$shortid" '{name:$name,proto:$proto,port:$port,uuid:$uuid,sni:$sni,pubkey:$pubkey,shortid:$shortid}')
      nodes=$(echo "$nodes" | jq ". + [ $node ]")
      added=1
    elif [[ "$proto" == "hy2"* || "$proto" == "hysteria2"* ]]; then
      # hy2://base64pwd@host:port?params#name
      password=$(echo "$link" | sed -n 's#hy2://\([^@]*\)@.*#\1#p')
      host=$(echo "$link" | sed -n 's#hy2://[^@]*@\([^:]*\):.*#\1#p')
      port=$(echo "$link" | sed -n 's#hy2://[^@]*@[^:]*:\([0-9]*\).*#\1#p')
      name=$(echo "$link" | grep -oE '#.*' | sed 's/#//')
      sni=$(echo "$link" | grep -oE 'sni=[^&]*' | cut -d'=' -f2)
      alpn=$(echo "$link" | grep -oE 'alpn=[^&]*' | cut -d'=' -f2)
      node=$(jq -n --arg name "$name" --arg proto "hysteria2" --arg port "$port" --arg password "$password" --arg sni "$sni" --arg alpn "$alpn" '{name:$name,proto:$proto,port:$port,password:$password,sni:$sni,alpn:$alpn}')
      nodes=$(echo "$nodes" | jq ". + [ $node ]")
      added=1
    fi
  done
  if [ "$added" = "1" ]; then
    save_nodes "$nodes"
    echo -e "${GREEN}批量导入完成！${NC}"
    update_config_and_restart
  else
    echo -e "${YELLOW}未识别到有效节点。${NC}"
  fi
  pause_return_menu node_menu
}

# 批量导出节点
export_node() {
  clear
  nodes=$(read_nodes)
  count=$(echo "$nodes" | jq 'length')
  if [ "$count" -eq 0 ]; then
    echo -e "${YELLOW}暂无节点可导出。${NC}"
    pause_return_menu node_menu
    return
  fi
  echo -e "${GREEN}节点链接如下（可直接复制导入主流客户端）：${NC}"
  for i in $(seq 0 $((count-1))); do
    n=$(echo "$nodes" | jq ".[$i]")
    proto=$(echo "$n" | jq -r .proto)
    name=$(echo "$n" | jq -r .name)
    if [ "$proto" = "reality" ]; then
      uuid=$(echo "$n" | jq -r .uuid)
      port=$(echo "$n" | jq -r .port)
      sni=$(echo "$n" | jq -r .sni)
      pubkey=$(echo "$n" | jq -r .pubkey)
      shortid=$(echo "$n" | jq -r .shortid)
      echo "vless://$uuid@your.domain:$port?encryption=none&security=reality&sni=$sni&fp=chrome&pbk=$pubkey&sid=$shortid#${name}"
    elif [ "$proto" = "hysteria2" ]; then
      password=$(echo "$n" | jq -r .password)
      port=$(echo "$n" | jq -r .port)
      sni=$(echo "$n" | jq -r .sni)
      alpn=$(echo "$n" | jq -r .alpn)
      echo "hy2://$password@your.domain:$port?sni=$sni&alpn=$alpn#${name}"
    fi
  done
  pause_return_menu node_menu
}

# 显示节点二维码（终端扫码）
show_qr() {
  clear
  # 检查 qrencode
  if ! command -v qrencode >/dev/null 2>&1; then
    echo -e "${YELLOW}未检测到 qrencode，正在尝试安装...${NC}"
    case "$SYS" in
      debian) apt update && apt install -y qrencode ;;
      centos) yum install -y qrencode ;;
      alpine) apk add --no-cache qrencode ;;
      arch) pacman -Sy --noconfirm qrencode ;;
      macos) brew install qrencode ;;
      *) echo "请手动安装 qrencode"; pause_return_menu node_menu; return ;;
    esac
  fi
  nodes=$(read_nodes)
  count=$(echo "$nodes" | jq 'length')
  if [ "$count" -eq 0 ]; then
    echo -e "${YELLOW}暂无节点。${NC}"
    pause_return_menu node_menu
    return
  fi
  echo -e "${GREEN}请选择要显示二维码的节点：${NC}"
  for i in $(seq 0 $((count-1))); do
    n=$(echo "$nodes" | jq ".[$i]")
    name=$(echo "$n" | jq -r .name)
    proto=$(echo "$n" | jq -r .proto)
    port=$(echo "$n" | jq -r .port)
    echo "$((i+1)). $name [$proto] 端口:$port"
  done
  read -rp "请输入节点序号（0返回）: " idx
  if [ "$idx" = "0" ]; then node_menu; return; fi
  if ! [[ "$idx" =~ ^[0-9]+$ ]] || [ "$idx" -lt 1 ] || [ "$idx" -gt "$count" ]; then
    echo -e "${RED}输入无效！${NC}"; sleep 1; show_qr; return
  fi
  n=$(echo "$nodes" | jq ".[$((idx-1))]")
  proto=$(echo "$n" | jq -r .proto)
  name=$(echo "$n" | jq -r .name)
  if [ "$proto" = "reality" ]; then
    uuid=$(echo "$n" | jq -r .uuid)
    port=$(echo "$n" | jq -r .port)
    sni=$(echo "$n" | jq -r .sni)
    pubkey=$(echo "$n" | jq -r .pubkey)
    shortid=$(echo "$n" | jq -r .shortid)
    link="vless://$uuid@your.domain:$port?encryption=none&security=reality&sni=$sni&fp=chrome&pbk=$pubkey&sid=$shortid#${name}"
  elif [ "$proto" = "hysteria2" ]; then
    password=$(echo "$n" | jq -r .password)
    port=$(echo "$n" | jq -r .port)
    sni=$(echo "$n" | jq -r .sni)
    alpn=$(echo "$n" | jq -r .alpn)
    link="hy2://$password@your.domain:$port?sni=$sni&alpn=$alpn#${name}"
  else
    echo -e "${RED}暂不支持该协议二维码显示。${NC}"
    pause_return_menu node_menu
    return
  fi
  echo -e "${GREEN}节点链接：${NC}\n$link"
  echo -e "${YELLOW}请用客户端扫码下方二维码导入：${NC}"
  echo "$link" | qrencode -t ANSIUTF8
  pause_return_menu node_menu
}

# 证书管理菜单
cert_menu() {
  clear
  echo -e "${YELLOW}------ 证书管理 ------${NC}"
  echo -e "1. 安装 acme.sh"
  echo -e "2. 申请/续签证书"
  echo -e "3. 导入现有证书"
  echo -e "4. 返回上级菜单"
  read -rp "请选择 [1-4]: " cert_num
  case $cert_num in
    1) install_acme ;;
    2) apply_cert ;;
    3) import_cert ;;
    4) sys_menu ;;
    *) echo -e "${RED}无效输入！${NC}"; sleep 1; cert_menu ;;
  esac
}

# 安装 acme.sh
install_acme() {
  if command -v acme.sh >/dev/null 2>&1; then
    echo -e "${GREEN}acme.sh 已安装。${NC}"
  else
    curl https://get.acme.sh | sh && source ~/.bashrc
    echo -e "${GREEN}acme.sh 安装完成。${NC}"
  fi
  pause_return_menu cert_menu
}

# 申请/续签证书
apply_cert() {
  read -rp "请输入要申请证书的域名: " domain
  read -rp "请输入证书验证方式（dns/dns_api/http，默认http）: " mode
  [ -z "$mode" ] && mode="http"
  if [ "$mode" = "dns" ] || [ "$mode" = "dns_api" ]; then
    read -rp "请输入 DNS API 环境变量（如 export CF_Token=xxx）: " dns_env
    eval "$dns_env"
    acme.sh --issue --dns $mode -d "$domain"
  else
    acme.sh --issue -d "$domain" --standalone
  fi
  acme.sh --install-cert -d "$domain" \
    --key-file /etc/sing-box/$domain.key \
    --fullchain-file /etc/sing-box/$domain.crt
  echo -e "${GREEN}证书已申请并安装到 /etc/sing-box/ 目录。${NC}"
  # 写入 sing-box 配置（如有节点，自动写入 tls 证书路径）
  update_config_cert_path "/etc/sing-box/$domain.crt" "/etc/sing-box/$domain.key"
  systemctl restart sing-box 2>/dev/null || true
  pause_return_menu cert_menu
}

# 导入现有证书
import_cert() {
  read -rp "请输入 crt 证书文件路径: " crt
  read -rp "请输入 key 私钥文件路径: " key
  cp "$crt" /etc/sing-box/server.crt
  cp "$key" /etc/sing-box/server.key
  echo -e "${GREEN}证书已导入到 /etc/sing-box/ 目录。${NC}"
  update_config_cert_path "/etc/sing-box/server.crt" "/etc/sing-box/server.key"
  systemctl restart sing-box 2>/dev/null || true
  pause_return_menu cert_menu
}

# 更新 sing-box 配置证书路径（仅 Reality/VLESS 节点）
update_config_cert_path() {
  crt="$1"; key="$2"
  if [ ! -f "$CONFIG_FILE" ]; then return; fi
  # 只更新 vless 节点的 tls 字段
  tmp=$(mktemp)
  jq --arg crt "$crt" --arg key "$key" '(.inbounds[] | select(.type=="vless") | .tls.certificate = $crt | .tls.key = $key)' "$CONFIG_FILE" > "$tmp" && mv "$tmp" "$CONFIG_FILE"
}

# 配置备份
backup_config() {
  mkdir -p /etc/sing-box/backup
  ts=$(date +%Y%m%d_%H%M%S)
  tar czf /etc/sing-box/backup/backup_$ts.tar.gz -C /etc/sing-box .
  echo -e "${GREEN}已备份到 /etc/sing-box/backup/backup_$ts.tar.gz${NC}"
  pause_return_menu sys_menu
}

# 配置恢复
restore_config() {
  clear
  echo -e "${GREEN}可用备份文件：${NC}"
  ls /etc/sing-box/backup/backup_*.tar.gz 2>/dev/null || { echo -e "${YELLOW}无备份文件。${NC}"; pause_return_menu sys_menu; return; }
  read -rp "请输入要恢复的备份文件名: " bak
  if [ ! -f "/etc/sing-box/backup/$bak" ]; then
    echo -e "${RED}文件不存在！${NC}"
    pause_return_menu sys_menu
    return
  fi
  tar xzf "/etc/sing-box/backup/$bak" -C /etc/sing-box/
  echo -e "${GREEN}恢复完成。${NC}"
  systemctl restart sing-box 2>/dev/null || true
  pause_return_menu sys_menu
}

# 查看 sing-box 日志
view_log() {
  clear
  LOG_FILE="/var/log/sing-box.log"
  if [ ! -f "$LOG_FILE" ]; then
    echo -e "${YELLOW}未找到日志文件：$LOG_FILE${NC}"
  else
    echo -e "${GREEN}sing-box 最近100行日志：${NC}"
    tail -n 100 "$LOG_FILE"
  fi
  pause_return_menu sys_menu
}

# 安装常用工具
install_tools() {
  clear
  echo -e "${GREEN}正在安装常用工具...${NC}"
  get_system_arch
  case "$SYS" in
    debian)
      apt update
      apt install -y btop htop speedtest-cli curl wget vim
      ;;
    centos)
      yum install -y epel-release
      yum install -y btop htop curl wget vim
      yum install -y python3-pip
      pip3 install speedtest-cli
      ;;
    alpine)
      apk add --no-cache btop htop curl wget vim
      ;;
    arch)
      pacman -Sy --noconfirm btop htop speedtest-cli curl wget vim
      ;;
    macos)
      brew install btop htop speedtest-cli curl wget vim
      ;;
    *)
      echo "未知系统，请手动安装 btop htop speedtest-cli curl wget vim"
      ;;
  esac
  echo -e "${GREEN}常用工具安装完成。${NC}"
  pause_return_menu toolbox_menu
}

# 更新脚本
update_script() {
  echo "[待实现] 检查更新本脚本"; pause_return_menu script_menu;
}

# 关于/帮助
about_script() {
  echo "[待实现] 关于/帮助"; pause_return_menu script_menu;
}

# 通用暂停返回函数
pause_return_menu() {
  echo -e "\n按任意键返回..."; read -n 1 -s; $1
}

# 启动时初始化节点文件
init_node_file

# 启动主菜单
main_menu
