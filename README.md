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

