# 使用 USB 键盘快速上手指南

**适用**: 已借到 USB 键盘,LCD 显示 ST 图形界面

## 你的当前状态

- ✅ 开发板已启动 (红蓝灯交替闪烁)
- ✅ LCD 显示 ST 图形界面
- ✅ 界面有几个小应用
- ✅ 有 Terminal 入口
- ✅ 显示登录界面

## 🎯 目标

1. 连接 USB 键盘到开发板
2. 登录系统
3. 配置 WiFi
4. 获取 IP 地址
5. Mac 上 SSH 连接
6. 安装 VNC 服务器 (可选)

---

## 📝 详细步骤

### Step 1: 连接 USB 键盘

#### 连接方式 A: 直接连接 (如果键盘是 USB-C)
```
USB-C 键盘 → Type-C 线 → 开发板 CN7 (OTG 口)
```

#### 连接方式 B: 通过 Hub (推荐)
```
USB 键盘 (USB-A)
    ↓
USB-C Hub USB-A 口
    ↓
Hub Type-C 口 → 开发板 CN7 (OTG)
```

**验证键盘工作**:
- 在 LCD 界面上,按几个键
- 如果光标移动或有反应,说明键盘已识别

---

### Step 2: 登录系统

#### 如果看到登录界面:

**官方镜像默认账号**:
```
用户名: root
密码: (直接回车,无密码)
```

或者:
```
用户名: root
密码: root
```

**在登录界面**:
1. 用键盘输入: `root`
2. 按回车
3. 如果要求密码,直接按回车或输入 `root`

#### 如果已经是图形界面:

1. **找到 Terminal 图标** (应该能看到)
2. **点击 Terminal** 或用键盘导航打开
3. 如果需要登录,输入 `root` + 回车

---

### Step 3: 配置 WiFi

**在 Terminal 中输入以下命令**:

#### 1. 查看网络接口
```bash
ip addr
```

**预期看到**:
- `eth0`: 以太网 (如果连了网线)
- `wlan0`: WiFi (我们要用这个)
- `lo`: 本地回环

#### 2. 扫描 WiFi 网络
```bash
nmcli device wifi list
```

**预期输出** (类似):
```
IN-USE  SSID              MODE   CHAN  RATE        SIGNAL  BARS  SECURITY
        MyWiFi            Infra  6     130 Mbit/s  75      ▂▄▆_  WPA2
        Office-5G         Infra  36    270 Mbit/s  60      ▂▄__  WPA2
        Guest-Network     Infra  11    54 Mbit/s   45      ▂___  WPA2
```

#### 3. 连接到你的 WiFi
```bash
# 替换成你的 WiFi 名称和密码
nmcli device wifi connect "你的WiFi名称" password "你的WiFi密码"

# 例如:
# nmcli device wifi connect "MyWiFi" password "password123"
```

**注意**:
- WiFi 名称和密码要用**引号**括起来
- 区分大小写
- 密码如果有特殊字符,确保引号正确

**成功提示**:
```
Device 'wlan0' successfully activated with 'xxxxx-xxxx-xxxx-xxxx'
```

#### 4. 验证连接
```bash
# 查看 WiFi IP 地址
ip addr show wlan0
```

**预期输出**:
```
3: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc ...
    inet 192.168.40.100/24 brd 192.168.40.255 scope global dynamic wlan0
          ^^^^^^^^^^^^^ 这是你的 IP 地址!
```

**记下这个 IP 地址!** 例如: `192.168.40.100`

#### 5. 测试网络连通性
```bash
# Ping 外网,确认网络正常
ping -c 3 8.8.8.8

# Ping 路由器
ping -c 3 192.168.40.1
```

**成功输出**:
```
3 packets transmitted, 3 received, 0% packet loss
```

---

### Step 4: 启用 SSH 服务

#### 检查 SSH 服务状态
```bash
systemctl status sshd
```

#### 如果未启动,启动 SSH
```bash
systemctl start sshd
systemctl enable sshd
```

#### 验证 SSH 端口
```bash
netstat -tlnp | grep :22
```

**预期输出**:
```
tcp  0  0  0.0.0.0:22  0.0.0.0:*  LISTEN  1234/sshd
```

---

### Step 5: 在 Mac 上 SSH 连接

**在你的 Mac 终端**:

```bash
# 使用刚才获取的 IP 地址
ssh root@192.168.40.100

# 首次连接会提示:
# The authenticity of host '192.168.40.100' can't be established.
# Are you sure you want to continue connecting (yes/no)?
# 输入: yes

# 如果有密码提示,输入: root 或直接回车
```

**成功连接后,会看到**:
```
root@stm32mp1:~#
```

🎉 **恭喜!你已经成功通过 WiFi SSH 连接到开发板了!**

---

### Step 6: 配置 VNC 服务器 (可选)

**如果你想用图形界面远程连接**:

#### 在开发板 SSH 会话中:

```bash
# 更新软件包列表
apt update

# 安装 wayvnc (Wayland VNC 服务器)
apt install -y wayvnc

# 启动 VNC 服务器
wayvnc 0.0.0.0 5900 &
```

#### 在 Mac 上连接 VNC:

1. **下载 VNC Viewer**: https://www.realvnc.com/download/viewer/
2. **打开 VNC Viewer**
3. **连接地址**: `192.168.40.100:5900` (用你的实际 IP)
4. **连接** - 你会看到开发板的桌面!

---

### Step 7: 断开键盘,正常关机

**现在 WiFi 已配置好,可以拔掉键盘了**:

#### 方法 1: SSH 关机 (推荐)
```bash
# 在 Mac SSH 会话中
sync              # 同步文件系统
sudo poweroff     # 关机
```

**等待 LD6 绿灯熄灭,然后可以拔电源**

#### 方法 2: 图形界面关机

在 LCD 屏幕上:
1. 找到菜单或电源图标
2. 点击 "Shutdown" 或 "Power Off"
3. 等待关机完成

---

## 🔧 常见问题

### Q1: WiFi 连接失败

**检查**:
```bash
# 查看 wlan0 状态
nmcli device status

# 重新扫描
nmcli device wifi rescan
nmcli device wifi list

# 查看详细错误
journalctl -xe | grep -i wifi
```

### Q2: SSH 连接被拒绝

**检查**:
```bash
# 确认 SSH 服务运行
systemctl status sshd

# 确认防火墙
systemctl status firewalld
# 如果防火墙开启,临时关闭:
systemctl stop firewalld
```

### Q3: 忘记 IP 地址

**方法 1**: 在开发板 LCD 终端查看
```bash
ip addr show wlan0 | grep inet
```

**方法 2**: 在路由器管理页面查看
- 访问: http://192.168.40.1
- 查看 DHCP 客户端列表

**方法 3**: 在 Mac 上扫描
```bash
nmap -sn 192.168.40.0/24 | grep -B 2 "stm32\|ST"
```

### Q4: 键盘无法识别

**检查连接**:
```bash
# 在 Terminal 输入
lsusb
# 应该能看到你的键盘设备

# 查看内核日志
dmesg | tail -20
# 插入键盘时应该有 USB 设备识别信息
```

**如果还是不行**:
- 尝试 Hub 的不同 USB 口
- 尝试不同的键盘
- 检查 Hub 是否供电充足

### Q5: WiFi 信号弱

**优化**:
```bash
# 查看信号强度
iwconfig wlan0

# 扫描时查看信号
nmcli device wifi list

# 如果信号太弱 (<50),考虑:
# - 移动开发板靠近路由器
# - 使用 5GHz WiFi (如果支持)
# - 使用外置天线 (如果有接口)
```

---

## 📋 快速命令参考

### WiFi 配置
```bash
nmcli device wifi list                                    # 扫描
nmcli device wifi connect "SSID" password "PASSWORD"      # 连接
ip addr show wlan0                                        # 查看 IP
ping -c 3 8.8.8.8                                         # 测试网络
```

### SSH 管理
```bash
systemctl status sshd                                     # 检查状态
systemctl start sshd                                      # 启动
systemctl enable sshd                                     # 开机自启
```

### 系统管理
```bash
sync                                                      # 同步文件系统
sudo poweroff                                             # 关机
sudo reboot                                               # 重启
```

---

## 🎯 完成后的状态

✅ 开发板已连接 WiFi
✅ 已获取固定或动态 IP
✅ SSH 服务已启动
✅ Mac 可以通过 SSH 连接
✅ (可选) VNC 服务器已配置
✅ 键盘可以归还了

**下一步**: 开始你的 KMS 开发!

```bash
# SSH 连接后
git clone https://github.com/AAStarCommunity/AirAccount.git
cd AirAccount
make
```

---

## 💾 保存配置

**WiFi 配置会自动保存**,下次开机自动连接!

**查看已保存的 WiFi**:
```bash
nmcli connection show
```

**删除 WiFi 配置** (如果需要):
```bash
nmcli connection delete "WiFi名称"
```

---

好了!有了这份指南,借到键盘后你就能快速上手了!

有任何问题随时问我! 🚀
