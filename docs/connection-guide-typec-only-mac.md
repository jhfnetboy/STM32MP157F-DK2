# Mac Type-C Only 连接指南

> 📖 **中文用户快速导航** | **Quick Navigation for Chinese Users**
> - [🎹 USB 键盘快速上手](quick-start-with-usb-keyboard.md) | [📱 Mac 开发工作流](mac-development-workflow.md) | [🔧 故障排查](troubleshooting-mac-connection.md)
> - [🔌 硬件设置](phase1-hardware-setup.md) | [🛠️ 开发环境](phase1-development-environment.md) | [🔐 OP-TEE 开发](phase1-optee-setup.md)
> - [🏠 返回主页](../README.md) | [📚 所有文档](../docs/)

**适用**: Mac 只有 Type-C 接口,无 USB-A 接口

## 问题现状

- ✅ 开发板已供电,LCD 显示正常
- 🔴🔵 开发板红蓝灯交替闪烁 (系统正常运行)
- ❌ 没有 USB 键盘,无法在 LCD 上操作
- ❌ Mac 无 RJ45 网口,无法直接连网线
- ❌ ST-LINK Mini USB 未被 Mac 识别

## 解决方案 (3 种)

### 🥇 方案 1: 购买 USB-C 转以太网适配器 (推荐)

**优点**: 最稳定,速度快,一劳永逸

#### 需要购买:
- **USB-C to Ethernet Adapter** ($15-30)
  - Anker USB-C to Ethernet (~$20)
  - Apple USB-C Digital AV Multiport Adapter (~$70,含 HDMI)
  - TP-Link UE300C (~$15)

#### 连接步骤:

```
Mac USB-C 口
    ↓
USB-C 转以太网适配器
    ↓
网线 (Cat5e/Cat6)
    ↓
开发板 CN2 (RJ45 接口)
```

#### 配置步骤:

1. **连接硬件**
   - 适配器插入 Mac Type-C 口
   - 网线一端连适配器,另一端连开发板 CN2

2. **开发板自动获取 IP**
   - 等待 10-20 秒
   - 开发板通过 DHCP 自动获取 IP

3. **方法 A: 在路由器查看 IP**
   - 登录路由器管理页面 (通常是 http://192.168.40.1)
   - 查看 DHCP 客户端列表
   - 找设备名包含 "stm32" 或 MAC 地址 `00:80:E1:xx:xx:xx`

4. **方法 B: 使用 Mac 网络共享**
   - Mac 系统偏好设置 → 共享
   - 勾选 "互联网共享"
   - 共享来源: WiFi
   - 共享给: USB 10/100/1000 LAN (你的以太网适配器)
   - 开发板将获得 `192.168.2.2` 的 IP

5. **SSH 连接**
   ```bash
   ssh root@<开发板IP>
   # 或如果用网络共享: ssh root@192.168.2.2
   ```

#### 完成后可以做什么:

- ✅ SSH 远程开发
- ✅ 配置 WiFi (下次可以无线连接)
- ✅ 安装 VNC 服务器
- ✅ 开始你的 KMS 开发

---

### 🥈 方案 2: 借用/购买 USB 键盘

**优点**: 一次配置 WiFi,后续无线连接

#### 需要:
- **USB 键盘** (任何 USB-A 接口的键盘)
- **你现有的 USB-C Hub**

#### 连接步骤:

```
USB 键盘
    ↓
USB-C Hub USB-A 口
    ↓
Hub Type-C 口 → 开发板 CN7 (OTG)
```

#### 配置步骤:

1. **连接键盘到开发板**
   - USB 键盘插入 Hub
   - Hub 通过 Type-C 线连到开发板 CN7 (OTG 口)

2. **在 LCD 屏幕上操作**
   - 如果看到桌面,点击 Terminal 图标
   - 如果是命令行,直接输入命令

3. **连接 WiFi**
   ```bash
   # 扫描 WiFi 网络
   nmcli device wifi list

   # 连接到你的 WiFi (替换 SSID 和密码)
   nmcli device wifi connect "你的WiFi名称" password "你的WiFi密码"

   # 查看 IP 地址
   ip addr show wlan0
   ```

4. **记录 IP 后断开键盘**
   - 记下 wlan0 的 IP 地址 (例如 192.168.40.100)
   - 可以拔掉键盘了

5. **Mac 上 SSH 连接**
   ```bash
   ssh root@<刚才记录的IP>
   ```

#### 完成后:
- ✅ 开发板已连 WiFi
- ✅ 后续都用 SSH/VNC 无线开发
- ✅ 键盘可以还回去了

---

### 🥉 方案 3: 尝试触摸屏直接操作

**优点**: 免费,不需要购买任何东西

#### STM32MP157F-DK2 有 4 寸电容触摸屏

**可能性**: 官方镜像可能支持虚拟键盘

#### 尝试步骤:

1. **探索触摸屏界面**
   - 在屏幕上**点击**不同位置
   - **滑动**屏幕,看有没有菜单
   - **长按**屏幕,看有没有上下文菜单

2. **寻找设置入口**
   - 可能有 "Settings" 图标
   - 可能有 "Network" 或 "WiFi" 设置
   - 可能在屏幕底部有应用栏

3. **如果找到虚拟键盘**
   - 打开 Terminal 应用
   - 用虚拟键盘输入 WiFi 配置命令:
     ```bash
     nmcli device wifi connect "WiFi名" password "密码"
     ip addr show wlan0
     ```

4. **如果没有虚拟键盘**
   - 这个方案可能行不通
   - 需要回到方案 1 或 2

#### LCD 屏幕可能显示的内容:

**情况 A: Weston 桌面**
- 看到图形界面
- 底部可能有应用图标
- 尝试点击 "Terminal" 或 "Settings"

**情况 B: 登录提示符**
```
STM32MP1 login: _
```
- 这种情况**必须有键盘**才能输入
- 回到方案 1 或 2

**情况 C: 命令行 Shell**
```
root@stm32mp1:~# _
```
- 已经登录了!
- 但没有键盘还是无法输入
- 需要键盘或方案 1

---

## 🔍 调试和排查

### 查找开发板 IP (如果它已经在网络上)

#### 方法 1: 登录路由器
```
浏览器访问: http://192.168.40.1
用户名/密码: (路由器背面标签)
查看: DHCP 客户端列表
寻找: 设备名包含 "stm32" 或新出现的设备
```

#### 方法 2: ARP 扫描 (已执行,未找到)
```bash
arp -a | grep 192.168.40
```

#### 方法 3: nmap 扫描 SSH 端口
```bash
# 需要安装 nmap: brew install nmap
nmap -p 22 --open 192.168.40.0/24
```

### ST-LINK 串口问题排查

**为什么 Mac 未识别 ST-LINK?**

可能原因:
1. **线缆问题**: Mini USB 是充电线,不是数据线
2. **Hub 兼容性**: 某些 Hub 不支持 ST-LINK
3. **macOS 驱动**: M1/M2 Mac 对某些 USB 设备支持有限

**测试方法**:
1. 更换 Mini USB 数据线
2. 直接连 Mac (不通过 Hub) - 需要 USB-C to USB-A 转接头
3. 检查开发板 LD7 LED 是否闪烁

**重要**: ST-LINK 串口**不是必需的**!
- 仅用于:
  - 系统引导调试
  - 烧录新固件
  - 内核级调试
- 日常开发: **SSH/VNC 足够**

---

## 📚 购买清单和预算

### 必买 (二选一):

| 方案 | 设备 | 价格 | 链接示例 |
|------|------|------|---------|
| **推荐** | USB-C 转以太网适配器 | $15-30 | [Amazon](https://amazon.com) |
| 备选 | USB 键盘 + Type-C 转接 | $20-40 | 任意电脑配件店 |

### 可选:

| 设备 | 价格 | 用途 |
|------|------|------|
| Mini USB 数据线 | $5-10 | ST-LINK 调试 (非必需) |
| USB-C Hub (已有) | - | 多设备连接 |

---

## 🎯 推荐流程

### Step 1: 先尝试免费方案
1. 尝试触摸屏操作 (5 分钟)
2. 登录路由器查找开发板 IP (5 分钟)
3. 如果找到 IP,直接 SSH 连接

### Step 2: 如果免费方案不行
**购买 USB-C 转以太网适配器** ($15-30)
- 清迈有很多电脑配件店
- Lazada/Shopee 1-2 天送达
- 或借用朋友的

### Step 3: 连接后配置 WiFi
```bash
ssh root@<开发板IP>
nmcli device wifi connect "WiFi名" password "密码"
```

### Step 4: 开始开发
- SSH 连接开发板
- clone KMS 代码
- 板上编译开发

---

## 🆘 如果遇到问题

### 问题: 路由器找不到开发板

**可能原因**:
- 开发板未连接到网络 (没有网线,没有 WiFi 配置)
- 开发板网络功能未启动

**解决**:
- 必须通过键盘或以太网连接配置网络

### 问题: SSH 连接被拒绝

**可能原因**:
- SSH 服务未启动
- 防火墙阻止

**解决** (在 LCD 能看到的情况下):
- 需要键盘输入: `systemctl start sshd`

### 问题: 忘记 root 密码

**官方镜像默认**:
- 用户名: `root`
- 密码: 空 (直接回车) 或 `root`

---

## 📞 下一步

请告诉我:

1. **LCD 屏幕当前显示什么?**
   - 图形界面?
   - 登录提示?
   - 命令行?
   - 其他?

2. **触摸屏幕有反应吗?**

3. **你准备选择哪个方案?**
   - 方案 1: 买以太网适配器
   - 方案 2: 借键盘
   - 方案 3: 试试触摸屏

4. **你能访问路由器吗?** (http://192.168.40.1)

把这些信息告诉我,我会给你最精准的下一步指导!
