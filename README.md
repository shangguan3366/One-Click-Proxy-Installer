# One-Click-Proxy-Installer/一键安装脚本
### 🌟 简介    ✨快捷启动脚本"k"
# Sing-Box Hysteria2 & Reality 快速配置脚本
>★真正适合小白自己折腾的脚本！
一个用于在 Linux 服务器上快速安装、配置和管理 [Sing-Box](https://github.com/SagerNet/sing-box) 的 Shell 脚本，特别针对 Hysteria2 和 VLESS Reality 协议进行了优化。



## ✨使用方法✨

** ✨1. 下载并运行脚本(任选一种方式)：**

```bash
wget -O lvhy.sh https://github.com/shangguancaiyun/One-Click-Proxy-Installer/raw/main/lvhy.sh && chmod +x lvhy.sh && ./lvhy.sh
```
或者
```bash
bash <(curl -sSL https://github.com/shangguancaiyun/One-Click-Proxy-Installer/raw/main/lvhy.sh)
```

### ✨. 再次运行脚本，快捷启动命令👉'k'
或者
```bash
sudo bash lvhy.sh
```

脚本将以 root 权限运行，并显示主菜单。


**2. 按提示选择菜单，输入数字即可完成安装和管理。**

- 选择【1】一键安装 Hysteria2 + Reality（共存）
- 选择【2】只装 Hysteria2
- 选择【3】只装 Reality (VLESS)
- 其他选项可管理服务、查看/编辑配置、卸载等

**3. 安装完成后，终端会显示所有节点和二维码，直接扫码或复制即可安全食用。**

---

## 常见问题

- **需要 root 权限**：请用 `sudo` 运行脚本。
- **依赖自动安装**：脚本会自动检测并安装 curl、openssl、qrencode 等依赖。
- **配置文件路径**：`/usr/local/etc/sing-box/config.json`
- **导入信息保存**：上次安装的节点信息会自动保存，可随时通过菜单查看。
- **防火墙端口**：如有防火墙，需放行你选择的端口（如 443、8443）。

---

### 4. 菜单选项说明

脚本启动后，你会看到类似如下的菜单：

```
================================================
 Sing-Box Hysteria2 & Reality 管理脚本 
================================================
 作者:      Zhong Yuan
================================================
安装选项:
  1. 安装 Hysteria2 + Reality (共存)
  2. 单独安装 Hysteria2
  3. 单独安装 Reality (VLESS)
------------------------------------------------
管理选项:
  4. 启动 Sing-box 服务
  5. 停止 Sing-box 服务
  6. 重启 Sing-box 服务
  7. 查看 Sing-box 服务状态
  8. 查看 Sing-box 实时日志
  9. 查看当前配置文件
  10. 编辑当前配置文件 (使用 nano)
  11. 显示上次保存的导入信息 (含二维码)
------------------------------------------------
其他选项:
  12. 更新 Sing-box 内核 (使用官方beta脚本)
  13. 卸载 Sing-box
  0. 退出脚本
================================================
请输入选项 [0-13]: 
```

根据提示输入数字选择相应功能即可。

---

### ❤❤❤注意事项❤❤❤  瞎写的，可不必理会！

*   **防火墙**: 如果你的服务器启用了防火墙 (如 ufw, firewalld)，请确保放行 Sing-Box 使用的端口。
    例如，如果使用 ufw 并且 Reality 使用 443 端口，Hysteria2 使用 8443 端口：
    ```bash
    sudo ufw allow 443/tcp
    sudo ufw allow 8443/tcp
    sudo ufw allow 8443/udp # Hysteria2 需要 UDP
    sudo ufw reload
    ```

###

宝宝们如果觉得好用，记得点个小星星⭐️哦



**在线订阅转换网站**(支持多种协议互转):[订阅转换](https://sub.crazyact.com/)


#
## ❤ ✨VPS工具箱推荐:^^目前我正在使用的工具箱>✨


>


# 1.(老王一键工具箱)可用于代理节点的搭建. 快捷启动"k",建议在本工具中改为"w"
```curl -fsSL https://raw.githubusercontent.com/eooce/ssh_tool/main/ssh_tool.sh -o ssh_tool.sh && chmod +x ssh_tool.sh && ./ssh_tool.sh

# 2.(科技lion)#科技lion一键脚本. 快捷启动为"k"，为避免冲突可改为"i"
```bash <(curl -sL kejilion.sh)


---

>




#
安卓/ios/mac/linux/win等平台详见:[支持hysteia2三方应用](https://v2.hysteria.network/zh/docs/getting-started/3rd-party-apps/)

ios端推荐:
免费开源❤Karing❤ 强烈推荐
hiddfy,Shadowrocket等

安卓端推荐：

[karing](https://github.com/KaringX/karing/releases/tag/v1.1.2.606)(点资产后缀为apk的最新版下载)

[nekobox](https://github.com/MatsuriDayo/NekoBoxForAndroid/releases)

[husi](https://github.com/xchacha20-poly1305/husi/releases)(非常不错+nice)

[Clash-Meta](https://github.com/MetaCubeX/ClashMetaForAndroid/releases)

[hiddify](https://github.com/hiddify/hiddify-next/releases)(国外大神制作) 

[v2rayNG](https://github.com/2dust/v2rayNG/releases)

电脑端推荐:

[karing](https://github.com/KaringX/karing/releases/download/v1.1.2.606/karing_1.1.2.606_windows_x64.exe)(免费开源点击即可下载)

[v2ray](https://github.com/2dust/v2rayN/releases)(推荐)

[Clash-Verge](https://github.com/clash-verge-rev/clash-verge-rev/releases)

[hiddify](https://github.com/hiddify/hiddify-next/releases)(国外大神制作) 

## 服务器推荐

akile的dns解锁流媒体vps [akile](https://akile.io/register?aff_code=99532291-0323-491e-bdd7-fbcfebbd1fa5)










---


## 快速开始
# ✨BBR 管理脚本✨  
  

>   
 

### 🚀 如何使用？
>>>
#若VPS是纯IPV6,如"德基euserv""哈鸡Hax"; 我们可以先给它添加warp的IPV4:
---
>apt-get update && apt-get install -y curl #(更新系统养成习惯)

#套warp
---
```wget -N https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh && bash menu.sh [option] [lisence/url/token]#warp

---

**一键部署BBR加速**  
   ```bash
   bash <(curl -l -s https://raw.githubusercontent.com/byJoey/Actions-bbr-v3/refs/heads/main/install.sh)
   ```



>






## 欢迎添加小⭐⭐




## 贡献

欢迎提交 Pull Requests 或在 Issues 中报告错误、提出建议。

## 开源协议

MIT License

维护者：Zhong Yuan



## 免责声明:
*   本脚本仅供学习和测试，请勿用于非法用途。
*   作者不对使用此脚本可能造成的任何后果负责。



## 致谢

*   [Sing-Box](https://github.com/SagerNet/sing-box) *   [开源项目](https://github.com/Netflixxp/vlhy2)及其开发者。
*   所有为开源社区做出贡献的人。 
*   [副本](https://github.com/shangguan3366/vlhy2)





# Sing-Box Hysteria2 & Reality 一键安装脚本

> **适用人群：Linux 新手/小白，零基础也能用！**

## 简介

本脚本可在 Linux 服务器上一键安装、配置和管理 [Sing-Box](https://github.com/SagerNet/sing-box) 的 Hysteria2 和 Reality (VLESS) 节点。无需手动配置，自动生成所有参数，菜单操作，极简上手。

---

## 一键安装方法（推荐）

**1. 下载并运行脚本（任选一种方式）：**

```bash
wget -O lvhy.sh https://github.com/shangguan3366/One-Click-Proxy-Installer/raw/main/lvhy.sh && chmod +x lvhy.sh && sudo ./lvhy.sh
```
或
```bash
sudo bash <(curl -sSL https://github.com/shangguan3366/One-Click-Proxy-Installer/raw/main/lvhy.sh)
```

**2. 按提示选择菜单，输入数字即可完成安装和管理。**

- 选择【1】一键安装 Hysteria2 + Reality（共存）
- 选择【2】只装 Hysteria2
- 选择【3】只装 Reality (VLESS)
- 其他选项可管理服务、查看/编辑配置、卸载等

**3. 安装完成后，终端会显示所有导入信息和二维码，直接扫码或复制即可用。**

---

## 常见问题

- **需要 root 权限**：请用 `sudo` 运行脚本。
- **依赖自动安装**：脚本会自动检测并安装 curl、openssl、qrencode 等依赖。
- **配置文件路径**：`/usr/local/etc/sing-box/config.json`
- **导入信息保存**：上次安装的节点信息会自动保存，可随时通过菜单查看。
- **防火墙端口**：如有防火墙，需放行你选择的端口（如 443、8443）。

---

## 免责声明

- 本脚本仅供学习和测试，请勿用于非法用途。
- 使用前请确保符合当地法律法规，风险自负。

---

## 致谢

- [Sing-Box](https://github.com/SagerNet/sing-box) 及其开发者
- 开源社区所有贡献者



