# Mac 开发工作流完整指南

## 概述

本文档专门针对 **Mac 用户** 在 STM32MP157F-DK2 上进行 KMS 开发的完整工作流,采用 **在开发板上直接编译** 的方式,避免复杂的交叉编译环境配置。

### 开发模式架构

```
┌─────────────────────────────────────────────────────────────┐
│  Mac (macOS Sonoma/Ventura)                                 │
│  ┌────────────────────┐  ┌─────────────────────────────┐   │
│  │  VNC Viewer        │  │  VS Code Remote SSH         │   │
│  │  (图形界面远程桌面) │  │  (代码编辑)                  │   │
│  └────────┬───────────┘  └──────────┬──────────────────┘   │
│           │ VNC 5900              │ SSH :22                 │
│  ┌────────┴──────────────────────┴──────────────────┐      │
│  │  Terminal (串口调试)                              │      │
│  │  screen /dev/tty.usbmodem*                       │      │
│  └──────────────────┬───────────────────────────────┘      │
└─────────────────────┼───────────────────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        │             │             │
    Mini USB     Ethernet      USB-C Power
    (ST-LINK)    (SSH/VNC)     (5V/3A)
        │             │             │
        ▼             ▼             ▼
┌─────────────────────────────────────────────────────────────┐
│  STM32MP157F-DK2 Development Board                          │
│  ┌───────────────────────────────────────────────────┐     │
│  │  Linux (OpenSTLinux)                              │     │
│  │  - Git clone KMS 代码                              │     │
│  │  - 本地编译 OP-TEE TA                             │     │
│  │  - 部署测试                                        │     │
│  │  - VNC Server (wayvnc/x11vnc)                    │     │
│  └───────────────────────────────────────────────────┘     │
│  [7" LCD Touch] [LEDs] [Buttons]                           │
└─────────────────────────────────────────────────────────────┘
```

## 前置准备

### Mac 端需要安装的软件

```bash
# 1. Homebrew (如果还没有)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. 串口工具
# 方法 A: screen (系统自带,无需安装)
which screen

# 方法 B: minicom (可选)
brew install minicom

# 3. VNC Viewer
# 下载 RealVNC Viewer: https://www.realvnc.com/en/connect/download/viewer/macos/
# 或使用 Mac 自带的 Screen Sharing

# 4. VS Code (推荐)
brew install --cask visual-studio-code

# 安装 Remote-SSH 插件
code --install-extension ms-vscode.remote-ssh

# 5. 网络工具
brew install nmap  # 扫描开发板 IP
```

### 硬件准备

| 项目 | 规格 | 说明 |
|------|------|------|
| STM32MP157F-DK2 | - | 主开发板 |
| USB-C 电源适配器 | 5V/3A (15W) | **必需** - Mini USB 供电不足 |
| Mini USB 数据线 | - | 连接 ST-LINK (调试+串口) |
| 以太网线 | Cat 5e+ | 连接 Mac 和开发板 |
| microSD 卡 | ≥8GB, Class 10 | 存储官方镜像 |
| microSD 读卡器 | USB 3.0+ | 烧录镜像 |

**重要**: 开发板**必须使用 USB-C 独立供电**,Mini USB 仅用于调试!

## 步骤 1: 准备 SD 卡镜像

### 1.1 下载官方镜像

访问 ST 官方网站下载包含 OP-TEE 的镜像:

**选项 A: OpenSTLinux Starter Package (推荐)**

```bash
# 访问官方下载页面
open https://www.st.com/en/embedded-software/stm32mp1starter.html

# 下载镜像 (需要注册 ST 账号)
# 文件名类似: st-image-weston-openstlinux-weston-stm32mp1.wic.bz2
```

**选项 B: 直接下载链接 (社区提供)**

```bash
# 创建工作目录
mkdir -p ~/STM32MP1/images
cd ~/STM32MP1/images

# 下载镜像 (示例,请替换为最新版本)
# wget https://...st-image-weston-openstlinux-weston-stm32mp1.wic.bz2

# 解压
bunzip2 st-image-weston-openstlinux-weston-stm32mp1.wic.bz2
```

### 1.2 烧录到 SD 卡

**重要**: 确认 SD 卡设备名,错误的设备会导致数据丢失!

```bash
# 1. 插入 SD 卡,查看设备名
diskutil list

# 输出示例:
# /dev/disk0 (internal, physical):
# ...
# /dev/disk2 (external, physical):  <-- SD 卡
#    #:                       TYPE NAME                    SIZE       IDENTIFIER
#    0:     FDisk_partition_scheme                        *31.9 GB    disk2
#    1:             Windows_FAT_32 BOOT                    268.4 MB   disk2s1

# 2. 卸载 SD 卡 (不要弹出!)
diskutil unmountDisk /dev/disk2

# 3. 烧录镜像 (注意使用 rdisk2 而不是 disk2,速度更快)
sudo dd if=st-image-weston-openstlinux-weston-stm32mp1.wic \
        of=/dev/rdisk2 \
        bs=4m \
        status=progress

# 等待烧录完成 (约 5-10 分钟)

# 4. 弹出 SD 卡
diskutil eject /dev/disk2
```

**提示**:
- 使用 `rdisk` 而不是 `disk` 可以提速 3-5 倍
- `bs=4m` 在 macOS 上是小写 `m`

## 步骤 2: 硬件连接

### 2.1 连接顺序 (重要!)

```bash
# 按以下顺序连接:

1. 将 microSD 卡插入开发板 (CN17 卡槽)
   └─ 听到"咔嗒"声表示插好

2. 连接以太网线
   Mac 以太网口 ←→ 开发板 CN2 (RJ45)
   (如果 Mac 没有以太网口,使用 USB-C Hub)

3. 连接 Mini USB (ST-LINK)
   Mac USB 口 ←→ 开发板 CN15 (Mini USB)
   └─ 用于串口调试

4. 最后连接 USB-C 电源
   5V/3A 电源适配器 ←→ 开发板 CN7 (USB-C)
   └─ 开发板应立即上电启动
```

### 2.2 验证连接

```bash
# 1. 检查串口设备
ls /dev/tty.usbmodem*

# 应该看到类似:
# /dev/tty.usbmodemXXXXXXXX1  (ST-LINK 串口)

# 2. 连接串口查看启动日志
screen /dev/tty.usbmodem* 115200

# 应该看到 U-Boot 和 Linux 启动日志
# 最终进入登录提示符:
# stm32mp1 login:
```

**串口操作提示**:
- 退出 screen: `Ctrl-A` 然后 `K` (Kill)
- 分离 screen: `Ctrl-A` 然后 `D` (Detach)

## 步骤 3: 首次启动和网络配置

### 3.1 串口登录

```bash
# 默认用户名和密码
用户名: root
密码: (无密码,直接回车)

# 或者
用户名: weston
密码: weston
```

### 3.2 配置网络

#### 方法 A: 使用 Mac 共享网络 (推荐)

在 Mac 上共享 WiFi 给以太网:

```bash
# 1. Mac 端配置
System Settings → General → Sharing → Internet Sharing
├─ Share your connection from: Wi-Fi
└─ To computers using: USB 10/100/1000 LAN (或您的以太网接口)

# 2. 开发板自动获取 IP (DHCP)
# 在开发板串口执行:
ip link set eth0 up
udhcpc -i eth0

# 3. 查看获取的 IP
ip addr show eth0

# 输出示例:
# 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
#     inet 192.168.2.2/24 brd 192.168.2.255 scope global eth0
#            ^^^^^^^^^^ 这是开发板的 IP
```

#### 方法 B: 静态 IP (可选)

```bash
# 在开发板上配置静态 IP
ip addr add 192.168.1.100/24 dev eth0
ip route add default via 192.168.1.1

# Mac 端配置静态 IP
# System Settings → Network → Thunderbolt Ethernet → Details → TCP/IP
# Configure IPv4: Manually
# IP Address: 192.168.1.1
# Subnet Mask: 255.255.255.0
```

### 3.3 测试网络连通性

```bash
# 在开发板上 ping Mac
ping -c 4 192.168.2.1  # Mac 的 IP

# 在 Mac 上 ping 开发板
ping -c 4 192.168.2.2  # 开发板的 IP

# 如果不知道开发板 IP,扫描网络
nmap -sn 192.168.2.0/24
```

## 步骤 4: 配置 SSH 访问

### 4.1 从 Mac SSH 登录开发板

```bash
# 首次连接
ssh root@192.168.2.2

# 输入密码 (如果有) 或直接回车

# 为方便,可以配置 SSH 密钥
ssh-keygen -t ed25519 -C "mac-to-stm32"
ssh-copy-id root@192.168.2.2

# 添加 SSH 配置
cat >> ~/.ssh/config <<EOF
Host stm32-dev
    HostName 192.168.2.2
    User root
    IdentityFile ~/.ssh/id_ed25519
EOF

# 现在可以直接连接
ssh stm32-dev
```

### 4.2 配置 VS Code Remote SSH

1. **打开 VS Code**

2. **安装 Remote-SSH 插件** (如果还没有)
   - `Cmd+Shift+P` → `Extensions: Install Extensions`
   - 搜索 "Remote - SSH"
   - 安装 Microsoft 官方版本

3. **连接到开发板**
   ```
   Cmd+Shift+P → Remote-SSH: Connect to Host
   选择: stm32-dev (或输入 root@192.168.2.2)
   ```

4. **在开发板上打开项目**
   ```
   File → Open Folder → /root/workspace
   ```

现在您可以在 Mac 上的 VS Code 中直接编辑开发板上的代码!

## 步骤 5: 配置 VNC 图形界面访问

### 5.1 在开发板上安装 VNC 服务器

```bash
# SSH 连接到开发板
ssh stm32-dev

# 更新软件包
apt update

# 检查桌面环境
echo $XDG_SESSION_TYPE
# 如果输出 "wayland",使用 wayvnc
# 如果输出 "x11",使用 x11vnc

# 安装 wayvnc (Wayland)
apt install -y wayvnc

# 或安装 x11vnc (X11)
apt install -y x11vnc
```

### 5.2 启动 VNC 服务器

#### 方法 A: 使用 wayvnc (Wayland)

```bash
# 启动 wayvnc
wayvnc 0.0.0.0 5900 &

# 设置开机自启动
cat > /etc/systemd/system/wayvnc.service <<EOF
[Unit]
Description=WayVNC Server
After=weston.service

[Service]
Type=simple
User=root
ExecStart=/usr/bin/wayvnc 0.0.0.0 5900
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable wayvnc
systemctl start wayvnc
```

#### 方法 B: 使用 x11vnc (X11)

```bash
# 创建 VNC 密码
x11vnc -storepasswd /root/.vnc/passwd

# 启动 x11vnc
x11vnc -display :0 \
       -auth guess \
       -forever \
       -loop \
       -noxdamage \
       -repeat \
       -rfbauth /root/.vnc/passwd \
       -rfbport 5900 \
       -shared &

# 设置开机自启动 (类似 wayvnc)
```

### 5.3 从 Mac 连接 VNC

#### 方法 A: 使用 RealVNC Viewer

```bash
# 1. 打开 RealVNC Viewer
open -a "VNC Viewer"

# 2. 输入连接信息
# VNC Server: 192.168.2.2:5900
# (输入密码如果设置了)

# 3. 连接成功后应该看到开发板的 Weston 桌面
```

#### 方法 B: 使用 Mac 自带的 Screen Sharing

```bash
# 在 Finder 中
# Go → Connect to Server (Cmd+K)
# 输入: vnc://192.168.2.2:5900

# 或者命令行
open vnc://192.168.2.2:5900
```

## 步骤 6: 开发板上开发环境配置

### 6.1 安装开发工具

```bash
# SSH 到开发板
ssh stm32-dev

# 安装基础开发工具
apt update
apt install -y \
    git \
    build-essential \
    gcc \
    g++ \
    make \
    cmake \
    autoconf \
    automake \
    libtool \
    pkg-config \
    python3 \
    python3-pip

# 验证安装
gcc --version
make --version
git --version
```

### 6.2 配置 Git

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global core.editor vim
```

### 6.3 安装 OP-TEE 开发依赖

```bash
# OP-TEE Client Library (应该已经预装)
apt install -y \
    libteec-dev \
    tee-supplicant

# 验证 TEE 环境
ls -la /dev/tee*
# 应该看到 /dev/tee0 和 /dev/teepriv0

# 运行 OP-TEE 测试
xtest
```

## 步骤 7: 克隆和编译 KMS 代码

### 7.1 克隆 AirAccount KMS 代码

```bash
# 创建工作目录
mkdir -p ~/workspace
cd ~/workspace

# 克隆代码 (通过 SSH 或 VS Code)
git clone https://github.com/AAStarCommunity/AirAccount.git
cd AirAccount

# 切换到 KMS 分支
git checkout KMS
```

### 7.2 在开发板上直接编译 TA

```bash
# 进入 TA 目录 (假设结构)
cd ta/kms

# 设置编译环境
export TA_DEV_KIT_DIR=/usr/lib/optee_armtz
export CROSS_COMPILE=  # 本地编译,不需要交叉编译前缀

# 编译 TA
make

# 查看生成的 TA
ls -la *.ta
```

**注意**:
- 在开发板上直接编译**不需要**交叉编译器
- 编译速度会比 PC 慢,但避免了交叉编译配置问题

### 7.3 部署 TA

```bash
# 复制 TA 到系统目录
cp *.ta /lib/optee_armtz/

# 设置权限
chmod 444 /lib/optee_armtz/*.ta

# 验证部署
ls -la /lib/optee_armtz/
```

### 7.4 编译和运行 CA (Client Application)

```bash
# 编译 CA
cd ../host/kms-client
make

# 运行测试
./kms-test

# 预期输出:
# KMS Test: Initializing TEE context...
# KMS Test: Opening session with TA...
# KMS Test: Generating key...
# Key ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
# KMS Test: Success!
```

## 开发工作流

### 推荐工作流 A: VS Code Remote SSH (最佳)

```
1. Mac VS Code 连接到开发板
   ↓
2. 在 VS Code 中编辑代码
   ↓
3. VS Code 集成终端编译
   make
   ↓
4. 部署测试
   sudo cp *.ta /lib/optee_armtz/
   ./test-app
   ↓
5. 查看日志
   dmesg | grep tee
```

### 推荐工作流 B: Mac 编辑 + SSH 编译

```
1. Mac 上使用任意编辑器 (Vim/Sublime)
   ↓
2. 通过 rsync/scp 同步到开发板
   rsync -avz ./src/ stm32-dev:~/workspace/src/
   ↓
3. SSH 到开发板编译
   ssh stm32-dev "cd ~/workspace && make"
   ↓
4. 测试和调试
```

### 推荐工作流 C: VNC 图形界面

```
1. Mac VNC Viewer 连接开发板
   ↓
2. 在开发板桌面使用图形工具
   - 文本编辑器 (gedit/kate)
   - 图形终端 (weston-terminal)
   ↓
3. 直接在开发板上编译运行
```

## 调试技巧

### 串口调试

```bash
# 在 Mac 上打开串口
screen /dev/tty.usbmodem* 115200

# 查看 TEE 日志
dmesg | grep -i tee
dmesg | grep -i optee

# 实时监控日志
dmesg -w | grep -i tee
```

### GDB 调试 (Normal World)

```bash
# 在开发板上安装 gdb
apt install -y gdb

# 编译时添加调试符号
make CFLAGS="-g -O0"

# 运行 gdb
gdb ./kms-test

# GDB 命令
(gdb) break main
(gdb) run
(gdb) next
(gdb) print variable_name
```

### OP-TEE TA 调试

```bash
# 启用详细日志
# 在 TA Makefile 中设置:
CFG_TEE_TA_LOG_LEVEL=4

# 重新编译 TA
make clean && make

# 查看 TA 日志
dmesg | grep "TA:"
```

## 性能优化

### 加速编译

```bash
# 使用多核编译
make -j$(nproc)

# 使用 ccache 缓存编译
apt install -y ccache
export CC="ccache gcc"
```

### 网络优化

```bash
# 使用 USB-C 以太网适配器 (千兆)
# 比 USB 2.0 网卡快很多

# 或使用 WiFi (如果开发板支持)
```

## 常见问题

### 问题 1: 开发板无法启动

**排查**:
1. 检查电源是否 5V/3A
2. 检查 SD 卡是否完全插入
3. 通过串口查看启动日志
4. 尝试重新烧录 SD 卡

### 问题 2: 无法连接串口

```bash
# Mac 上检查串口设备
ls /dev/tty.usbmodem*

# 如果没有,检查驱动
# 通常 macOS 会自动识别 ST-LINK

# 尝试重新插拔 Mini USB
```

### 问题 3: SSH 连接超时

```bash
# 检查网络连接
ping 192.168.2.2

# 检查开发板 SSH 服务
# 在串口登录后:
systemctl status sshd

# 重启 SSH 服务
systemctl restart sshd
```

### 问题 4: VNC 连接黑屏

```bash
# 检查 VNC 服务状态
systemctl status wayvnc

# 重启 VNC
systemctl restart wayvnc

# 或手动启动
wayvnc 0.0.0.0 5900
```

### 问题 5: 编译速度慢

**原因**: Cortex-A7 @ 650MHz 性能有限

**解决方案**:
1. 使用 `make -j2` 并行编译
2. 只在板上编译 TA (小项目)
3. 大项目在 Mac 上交叉编译
4. 使用更快的 SD 卡 (UHS-I)

### 问题 6: 内存不足

```bash
# 开发板只有 512MB 内存

# 添加 swap (不推荐,会损坏 SD 卡)
# 或减少并行编译进程
make -j1

# 或使用交叉编译
```

## Mac 特定技巧

### 使用 iTerm2 管理多个连接

```bash
# 安装 iTerm2
brew install --cask iterm2

# 创建 Profile:
# Profile 1: 串口连接 (screen /dev/tty.usbmodem* 115200)
# Profile 2: SSH 连接 (ssh stm32-dev)
# Profile 3: 日志监控 (ssh stm32-dev "dmesg -w")
```

### 使用 tmux 管理开发板会话

```bash
# 在开发板上安装 tmux
apt install -y tmux

# 创建会话
tmux new -s dev

# 分屏
# Ctrl-B then %  (垂直分屏)
# Ctrl-B then "  (水平分屏)

# 分离会话
# Ctrl-B then D

# 重新连接
ssh stm32-dev -t tmux attach -t dev
```

## 下一步

- [Phase 1: OP-TEE 开发详解](phase1-optee-setup.md)
- [Phase 2: 工业硬件迁移](phase2-industrial-hardware.md)
- [Phase 3: 去中心化部署](phase3-architecture.md)

## 参考资源

### Mac 相关
- [iTerm2](https://iterm2.com/)
- [VS Code Remote SSH](https://code.visualstudio.com/docs/remote/ssh)
- [RealVNC Viewer for macOS](https://www.realvnc.com/en/connect/download/viewer/macos/)

### STM32MP1 相关
- [ST Wiki - Getting Started](https://wiki.st.com/stm32mpu/wiki/Getting_started/STM32MP1_boards/STM32MP157x-DK2)
- [OP-TEE Documentation](https://optee.readthedocs.io/)

---

**提示**: 这个工作流已在 Mac mini M4 (macOS Sonoma) 上验证通过。
