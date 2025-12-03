# USB Keyboard Quick Start Guide
# USB 键盘快速上手指南

**Applicable**: You have a USB keyboard and LCD shows ST graphical interface
**适用**: 已借到 USB 键盘,LCD 显示 ST 图形界面

## Current Status / 当前状态

- ✅ Board powered on (red/blue LEDs blinking alternately) / 开发板已启动 (红蓝灯交替闪烁)
- ✅ LCD shows ST graphical interface / LCD 显示 ST 图形界面
- ✅ Several small applications visible / 界面有几个小应用
- ✅ Terminal entry available / 有 Terminal 入口
- ✅ Login interface displayed / 显示登录界面

## 🎯 Goals / 目标

1. Connect USB keyboard to board / 连接 USB 键盘到开发板
2. Login to system / 登录系统
3. Configure WiFi / 配置 WiFi
4. Get IP address / 获取 IP 地址
5. SSH from Mac / Mac 上 SSH 连接
6. Install VNC server (optional) / 安装 VNC 服务器 (可选)

---

## 📝 Detailed Steps / 详细步骤

### Step 1: Connect USB Keyboard / 连接 USB 键盘

#### Method A: Direct Connection (if keyboard is USB-C)
#### 方式 A: 直接连接 (如果键盘是 USB-C)

```
USB-C Keyboard → Type-C Cable → Board CN7 (OTG Port)
USB-C 键盘 → Type-C 线 → 开发板 CN7 (OTG 口)
```

#### Method B: Via Hub (Recommended)
#### 方式 B: 通过 Hub (推荐)

```
USB Keyboard (USB-A) / USB 键盘 (USB-A)
    ↓
USB-C Hub USB-A Port / USB-C Hub USB-A 口
    ↓
Hub Type-C Port → Board CN7 (OTG) / Hub Type-C 口 → 开发板 CN7 (OTG)
```

**Verify Keyboard Works / 验证键盘工作**:
- Press some keys on the LCD interface / 在 LCD 界面上,按几个键
- If cursor moves or shows response, keyboard is recognized / 如果光标移动或有反应,说明键盘已识别

---

### Step 2: Login to System / 登录系统

#### If You See Login Interface / 如果看到登录界面

**Default Account for Official Image / 官方镜像默认账号**:
```
Username / 用户名: root
Password / 密码: (press Enter, no password) / (直接回车,无密码)
```

Or / 或者:
```
Username / 用户名: root
Password / 密码: root
```

**At Login Interface / 在登录界面**:
1. Type with keyboard: `root` / 用键盘输入: `root`
2. Press Enter / 按回车
3. If password required, press Enter or type `root` / 如果要求密码,直接按回车或输入 `root`

#### If Already in Graphical Interface / 如果已经是图形界面

1. **Find Terminal icon** (should be visible) / **找到 Terminal 图标** (应该能看到)
2. **Click Terminal** or navigate with keyboard / **点击 Terminal** 或用键盘导航打开
3. If login required, type `root` + Enter / 如果需要登录,输入 `root` + 回车

---

### Step 3: Configure WiFi / 配置 WiFi

**Enter the following commands in Terminal / 在 Terminal 中输入以下命令**:

#### 1. Check network interfaces / 查看网络接口
```bash
ip addr
```

**Expected to see / 预期看到**:
- `eth0`: Ethernet (if cable connected) / 以太网 (如果连了网线)
- `wlan0`: WiFi (we'll use this) / WiFi (我们要用这个)
- `lo`: Loopback / 本地回环

#### 2. Scan WiFi networks / 扫描 WiFi 网络
```bash
nmcli device wifi list
```

**Expected output / 预期输出** (similar to / 类似):
```
IN-USE  SSID              MODE   CHAN  RATE        SIGNAL  BARS  SECURITY
        MyWiFi            Infra  6     130 Mbit/s  75      ▂▄▆_  WPA2
        Office-5G         Infra  36    270 Mbit/s  60      ▂▄__  WPA2
        Guest-Network     Infra  11    54 Mbit/s   45      ▂___  WPA2
```

#### 3. Connect to your WiFi / 连接到你的 WiFi
```bash
# Replace with your WiFi name and password
# 替换成你的 WiFi 名称和密码
nmcli device wifi connect "Your-WiFi-Name" password "Your-WiFi-Password"

# Example / 例如:
# nmcli device wifi connect "MyWiFi" password "password123"
```

**Notes / 注意**:
- WiFi name and password must be in **quotes** / WiFi 名称和密码要用**引号**括起来
- Case-sensitive / 区分大小写
- For special characters in password, ensure quotes are correct / 密码如果有特殊字符,确保引号正确

**Success message / 成功提示**:
```
Device 'wlan0' successfully activated with 'xxxxx-xxxx-xxxx-xxxx'
```

#### 4. Verify connection / 验证连接
```bash
# Check WiFi IP address / 查看 WiFi IP 地址
ip addr show wlan0
```

**Expected output / 预期输出**:
```
3: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc ...
    inet 192.168.40.100/24 brd 192.168.40.255 scope global dynamic wlan0
          ^^^^^^^^^^^^^ This is your IP address! / 这是你的 IP 地址!
```

**Write down this IP address! / 记下这个 IP 地址!** Example / 例如: `192.168.40.100`

#### 5. Test network connectivity / 测试网络连通性
```bash
# Ping external network to confirm / Ping 外网,确认网络正常
ping -c 3 8.8.8.8

# Ping router / Ping 路由器
ping -c 3 192.168.40.1
```

**Success output / 成功输出**:
```
3 packets transmitted, 3 received, 0% packet loss
```

---

### Step 4: Enable SSH Service / 启用 SSH 服务

#### Check SSH service status / 检查 SSH 服务状态
```bash
systemctl status sshd
```

#### If not started, start SSH / 如果未启动,启动 SSH
```bash
systemctl start sshd
systemctl enable sshd
```

#### Verify SSH port / 验证 SSH 端口
```bash
netstat -tlnp | grep :22
```

**Expected output / 预期输出**:
```
tcp  0  0  0.0.0.0:22  0.0.0.0:*  LISTEN  1234/sshd
```

---

### Step 5: SSH from Mac / 在 Mac 上 SSH 连接

**In your Mac Terminal / 在你的 Mac 终端**:

```bash
# Use the IP address you got earlier
# 使用刚才获取的 IP 地址
ssh root@192.168.40.100

# First connection will prompt / 首次连接会提示:
# The authenticity of host '192.168.40.100' can't be established.
# Are you sure you want to continue connecting (yes/no)?
# Type / 输入: yes

# If password prompt, type: root or just press Enter
# 如果有密码提示,输入: root 或直接回车
```

**After successful connection / 成功连接后,会看到**:
```
root@stm32mp1:~#
```

🎉 **Congratulations! You've successfully connected to the board via WiFi SSH!**
🎉 **恭喜!你已经成功通过 WiFi SSH 连接到开发板了!**

---

### Step 6: Configure VNC Server (Optional) / 配置 VNC 服务器 (可选)

**If you want graphical remote access / 如果你想用图形界面远程连接**:

#### In board SSH session / 在开发板 SSH 会话中:

```bash
# Update package list / 更新软件包列表
apt update

# Install wayvnc (Wayland VNC server) / 安装 wayvnc (Wayland VNC 服务器)
apt install -y wayvnc

# Start VNC server / 启动 VNC 服务器
wayvnc 0.0.0.0 5900 &
```

#### Connect VNC from Mac / 在 Mac 上连接 VNC:

1. **Download VNC Viewer / 下载 VNC Viewer**: https://www.realvnc.com/download/viewer/
2. **Open VNC Viewer / 打开 VNC Viewer**
3. **Connection address / 连接地址**: `192.168.40.100:5900` (use your actual IP / 用你的实际 IP)
4. **Connect / 连接** - You'll see the board's desktop! / 你会看到开发板的桌面!

---

### Step 7: Disconnect Keyboard and Shutdown Safely / 断开键盘,正常关机

**Now WiFi is configured, you can remove the keyboard / 现在 WiFi 已配置好,可以拔掉键盘了**:

#### Method 1: SSH Shutdown (Recommended) / 方法 1: SSH 关机 (推荐)
```bash
# In Mac SSH session / 在 Mac SSH 会话中
sync              # Sync filesystem / 同步文件系统
sudo poweroff     # Shutdown / 关机
```

**Wait for LD6 green LED to turn off, then you can unplug power / 等待 LD6 绿灯熄灭,然后可以拔电源**

#### Method 2: GUI Shutdown / 方法 2: 图形界面关机

On LCD screen / 在 LCD 屏幕上:
1. Find menu or power icon / 找到菜单或电源图标
2. Click "Shutdown" or "Power Off" / 点击 "Shutdown" 或 "Power Off"
3. Wait for shutdown to complete / 等待关机完成

---

## 🔧 Troubleshooting / 常见问题

### Q1: WiFi Connection Failed / WiFi 连接失败

**Check / 检查**:
```bash
# Check wlan0 status / 查看 wlan0 状态
nmcli device status

# Rescan / 重新扫描
nmcli device wifi rescan
nmcli device wifi list

# Check detailed errors / 查看详细错误
journalctl -xe | grep -i wifi
```

### Q2: SSH Connection Refused / SSH 连接被拒绝

**Check / 检查**:
```bash
# Confirm SSH service is running / 确认 SSH 服务运行
systemctl status sshd

# Check firewall / 确认防火墙
systemctl status firewalld
# If firewall is on, temporarily disable / 如果防火墙开启,临时关闭:
systemctl stop firewalld
```

### Q3: Forgot IP Address / 忘记 IP 地址

**Method 1 / 方法 1**: Check on board LCD terminal / 在开发板 LCD 终端查看
```bash
ip addr show wlan0 | grep inet
```

**Method 2 / 方法 2**: Check in router admin page / 在路由器管理页面查看
- Visit / 访问: http://192.168.40.1
- Check DHCP client list / 查看 DHCP 客户端列表

**Method 3 / 方法 3**: Scan from Mac / 在 Mac 上扫描
```bash
nmap -sn 192.168.40.0/24 | grep -B 2 "stm32\|ST"
```

### Q4: Keyboard Not Recognized / 键盘无法识别

**Check connection / 检查连接**:
```bash
# In Terminal / 在 Terminal 输入
lsusb
# Should see your keyboard device / 应该能看到你的键盘设备

# Check kernel log / 查看内核日志
dmesg | tail -20
# Should see USB device recognition when plugging keyboard
# 插入键盘时应该有 USB 设备识别信息
```

**If still not working / 如果还是不行**:
- Try different USB port on Hub / 尝试 Hub 的不同 USB 口
- Try different keyboard / 尝试不同的键盘
- Check if Hub is sufficiently powered / 检查 Hub 是否供电充足

### Q5: Weak WiFi Signal / WiFi 信号弱

**Optimize / 优化**:
```bash
# Check signal strength / 查看信号强度
iwconfig wlan0

# Check signal during scan / 扫描时查看信号
nmcli device wifi list

# If signal too weak (<50), consider / 如果信号太弱 (<50),考虑:
# - Move board closer to router / 移动开发板靠近路由器
# - Use 5GHz WiFi (if supported) / 使用 5GHz WiFi (如果支持)
# - Use external antenna (if interface available) / 使用外置天线 (如果有接口)
```

---

## 📋 Quick Command Reference / 快速命令参考

### WiFi Configuration / WiFi 配置
```bash
nmcli device wifi list                                    # Scan / 扫描
nmcli device wifi connect "SSID" password "PASSWORD"      # Connect / 连接
ip addr show wlan0                                        # Check IP / 查看 IP
ping -c 3 8.8.8.8                                         # Test network / 测试网络
```

### SSH Management / SSH 管理
```bash
systemctl status sshd                                     # Check status / 检查状态
systemctl start sshd                                      # Start / 启动
systemctl enable sshd                                     # Enable at boot / 开机自启
```

### System Management / 系统管理
```bash
sync                                                      # Sync filesystem / 同步文件系统
sudo poweroff                                             # Shutdown / 关机
sudo reboot                                               # Reboot / 重启
```

---

## 🎯 After Completion Status / 完成后的状态

✅ Board connected to WiFi / 开发板已连接 WiFi
✅ Got static or dynamic IP / 已获取固定或动态 IP
✅ SSH service started / SSH 服务已启动
✅ Mac can SSH connect / Mac 可以通过 SSH 连接
✅ (Optional) VNC server configured / (可选) VNC 服务器已配置
✅ Keyboard can be returned / 键盘可以归还了

**Next Step / 下一步**: Start your KMS development! / 开始你的 KMS 开发!

```bash
# After SSH connection / SSH 连接后
git clone https://github.com/AAStarCommunity/AirAccount.git
cd AirAccount
make
```

---

## 💾 Save Configuration / 保存配置

**WiFi configuration is saved automatically and will reconnect on next boot!**
**WiFi 配置会自动保存,下次开机自动连接!**

**Check saved WiFi / 查看已保存的 WiFi**:
```bash
nmcli connection show
```

**Delete WiFi configuration (if needed) / 删除 WiFi 配置 (如果需要)**:
```bash
nmcli connection delete "WiFi-Name"
```

---

**With this guide, you can get started quickly after borrowing a keyboard!**
**有了这份指南,借到键盘后你就能快速上手了!**

**Any questions, feel free to ask! / 有任何问题随时问我!** 🚀
