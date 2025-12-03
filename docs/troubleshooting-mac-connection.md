# Mac 连接 STM32MP157F-DK2 故障排查指南

> 📖 **中文用户快速导航** | **Quick Navigation for Chinese Users**
> - [🎹 USB 键盘快速上手](quick-start-with-usb-keyboard.md) | [📱 Mac 开发工作流](mac-development-workflow.md) | [💻 Type-C Mac 方案](connection-guide-typec-only-mac.md)
> - [🔌 硬件设置](phase1-hardware-setup.md) | [🛠️ 开发环境](phase1-development-environment.md) | [🔐 OP-TEE 开发](phase1-optee-setup.md)
> - [🏠 返回主页](../README.md) | [📚 所有文档](../docs/)

## 问题: ST-LINK 串口设备未检测到

### 症状
- 运行 `ls /dev/tty.usbmodem*` 显示 "no matches found"
- `system_profiler SPUSBDataType` 未显示 STM32 设备
- 开发板已正常加电,LCD 显示正常

---

## 解决方案

### ✅ 方案 1: 使用 LCD 触摸屏直接配置 (推荐)

**优势**: 无需串口,直接在开发板上操作

#### 步骤:

1. **在 LCD 屏幕上打开终端**
   - STM32MP157F-DK2 官方镜像使用 Weston 桌面环境
   - 触摸屏幕,找到 Terminal 图标并点击

2. **查看当前网络状态**
   ```bash
   # 查看所有网络接口
   ip addr

   # 查看网络管理器状态
   nmcli device status
   ```

3. **配置 WiFi 连接**
   ```bash
   # 扫描可用 WiFi 网络
   nmcli device wifi list

   # 连接到你的 WiFi (替换 SSID 和密码)
   nmcli device wifi connect "你的WiFi名称" password "你的WiFi密码"

   # 或者使用交互式配置
   nmtui
   ```

4. **获取 IP 地址**
   ```bash
   # 查看 WiFi IP 地址
   ip addr show wlan0

   # 或者
   ifconfig wlan0
   ```

5. **在 Mac 上 SSH 连接**
   ```bash
   # 使用刚才获取的 IP 地址
   ssh root@<开发板IP>

   # 默认密码通常是空或 "root"
   ```

6. **启用 VNC 服务器(可选)**
   ```bash
   # 安装 wayvnc
   apt update && apt install -y wayvnc

   # 启动 VNC 服务器
   wayvnc 0.0.0.0 5900 &

   # 或者使用 x11vnc (如果使用 X11)
   apt install -y x11vnc
   x11vnc -display :0 -forever -shared &
   ```

7. **Mac 上使用 VNC Viewer 连接**
   - 下载 [VNC Viewer](https://www.realvnc.com/download/viewer/)
   - 连接到 `<开发板IP>:5900`

---

### ✅ 方案 2: 使用以太网线连接

**优势**: 稳定,速度快,适合大量数据传输

#### 步骤:

1. **连接网线**
   - 将以太网线一端连接到开发板 RJ45 接口
   - 另一端连接到路由器

2. **开发板自动获取 IP**
   - 在 LCD 屏幕终端运行: `ip addr show eth0`
   - 或者检查路由器 DHCP 客户端列表

3. **在 Mac 上查找开发板**
   ```bash
   # 方法 1: 检查 ARP 缓存
   arp -a | grep "192.168.40"

   # 方法 2: 使用 nmap 扫描(需安装: brew install nmap)
   nmap -sn 192.168.40.0/24 | grep -B 2 "ST\|STMicro"

   # 方法 3: 扫描常见端口
   nmap -p 22,5900 192.168.40.0/24
   ```

4. **SSH 连接**
   ```bash
   ssh root@<开发板IP>
   ```

---

### ✅ 方案 3: 修复 ST-LINK 串口问题

#### 检查 1: 验证硬件连接

- **确认使用的是 Mini USB 数据线** (不是只能充电的线)
- **连接到正确的接口**: CN11 (ST-LINK)
- **重新插拔** Mini USB 线
- **尝试不同的 USB 端口** 在 Mac 上

#### 检查 2: 验证驱动和工具

```bash
# 1. 确认 stlink 已安装
brew list stlink
# 输出: /usr/local/Cellar/stlink/1.8.0/...

# 2. 确认 libusb 已安装
brew list libusb
# 输出: /usr/local/Cellar/libusb/...

# 3. 检查 USB 设备(拔插后对比)
system_profiler SPUSBDataType

# 4. 检查内核扩展
kextstat | grep -i usb
```

#### 检查 3: ST-LINK 固件版本

某些旧版本 ST-LINK 固件可能不兼容 macOS。需要在 Windows/Linux 上使用 STM32CubeProgrammer 升级固件。

#### 检查 4: macOS 权限问题

```bash
# 检查当前用户是否有权限
ls -la /dev/tty.*

# 重启系统后再试(有时 macOS 需要重启才能识别新设备)
sudo reboot
```

#### 如果仍然无法识别

可能原因:
1. **Mini USB 线缆问题** - 尝试更换线缆
2. **ST-LINK 硬件故障** - 检查 LED 指示灯
3. **macOS 版本兼容性** - 某些 macOS 版本对 USB-Serial 设备支持有限
4. **USB 集线器问题** - 尝试直接连接到 Mac,不使用 Hub

**临时解决方案**: 使用网络连接(WiFi/以太网)代替串口,串口仅用于紧急调试。

---

### ✅ 方案 4: Mac 网络共享 (直连 Mac)

如果你想避免依赖路由器:

#### 步骤:

1. **Mac 系统偏好设置 → 共享**
   - 勾选 "互联网共享"
   - 共享来源: WiFi
   - 共享给: (选择连接开发板的接口)

2. **连接开发板**
   - USB-Ethernet 适配器 或 以太网直连

3. **开发板将获得 192.168.2.x 段 IP**

4. **在 Mac 终端查找**
   ```bash
   arp -a | grep 192.168.2
   ```

5. **SSH 连接**
   ```bash
   ssh root@192.168.2.2  # 通常是 .2
   ```

---

## 故障排查检查清单

### 硬件检查
- [ ] Mini USB 线是数据线(不是充电线)
- [ ] 连接到正确的 ST-LINK 接口 (CN11)
- [ ] USB-C 电源已连接
- [ ] LCD 显示正常,系统已启动
- [ ] 尝试不同的 USB 端口
- [ ] 尝试不同的 USB 线缆

### 软件检查
- [ ] stlink 工具已安装 (`brew list stlink`)
- [ ] libusb 已安装 (`brew list libusb`)
- [ ] 重启 Mac 后再试
- [ ] 检查 `system_profiler SPUSBDataType` 输出

### 替代方案
- [ ] 尝试使用 LCD 触摸屏直接配置
- [ ] 尝试以太网连接
- [ ] 尝试 Mac 网络共享
- [ ] 考虑在 Ubuntu 虚拟机中使用串口

---

## 最佳实践建议

### 推荐工作流程 (Mac)

```
主要开发方式: SSH/VNC (通过 WiFi 或以太网)
├── 优点: 稳定、快速、支持图形界面
├── 缺点: 需要网络配置
└── 适用: 日常开发、调试、编译

紧急调试: 串口控制台 (ST-LINK)
├── 优点: 系统崩溃时仍可用
├── 缺点: Mac 兼容性问题
└── 适用: 引导故障、内核调试
```

### 初次配置流程

1. **使用 LCD 触摸屏** 配置网络 (WiFi 或静态 IP)
2. **通过 SSH** 进行后续所有开发工作
3. **串口作为备份** (如果 Mac 能识别的话)

---

## 常见问题

### Q1: 为什么 Mac 不识别 ST-LINK?

**A**: macOS 对某些 USB-Serial 芯片支持有限,特别是:
- 较新的 macOS 版本(Monterey+)
- Apple Silicon Mac (M1/M2/M3)
- 某些 ST-LINK 固件版本

**解决方案**:
- 使用网络连接代替串口
- 在 Ubuntu 虚拟机中使用串口
- 升级 ST-LINK 固件

### Q2: SSH 连接显示 "Connection refused"

**A**: 可能原因:
- SSH 服务未启动: 在 LCD 终端运行 `systemctl start sshd`
- 防火墙阻止: `systemctl stop firewalld`
- IP 地址错误: 重新确认 `ip addr`

### Q3: VNC 连接黑屏

**A**: 检查:
- Wayland 环境使用 `wayvnc`
- X11 环境使用 `x11vnc`
- 确认显示服务器正在运行

### Q4: WiFi 连接后无法 SSH

**A**: 检查:
```bash
# 在开发板 LCD 终端运行
ping 8.8.8.8           # 测试网络连通性
ip route show          # 查看路由表
systemctl status sshd  # 确认 SSH 服务运行
```

---

## 下一步

一旦建立了 SSH/VNC 连接:

1. **克隆代码仓库**
   ```bash
   ssh root@<开发板IP>
   git clone https://github.com/AAStarCommunity/AirAccount.git
   cd AirAccount
   ```

2. **在开发板上编译**
   ```bash
   make
   ```

3. **参考完整开发流程**
   - [Mac 开发工作流](mac-development-workflow.md)
   - [OP-TEE 开发指南](phase1-optee-setup.md)

---

**推荐**: 优先使用 LCD 触摸屏配置 WiFi,这是最快捷的方法!
