# Phase 1: STM32MP157F-DK2 硬件连接完全指南

## 概述

本文档提供 STM32MP157F-DK2 开发板从开箱到首次启动的完整硬件连接指南,适合完全没有 STM32 经验的开发者。

## 硬件清单

### 必需硬件

| 项目 | 规格要求 | 参考价格 | 说明 |
|------|---------|---------|------|
| **STM32MP157F-DK2 开发板** | - | ~$100 | 主开发板 |
| **USB Type-C 电源适配器** | 5V/3A (15W) | ~$10-15 | 为开发板供电 |
| **USB Micro-B 数据线** | 支持数据传输 | ~$5 | 连接 ST-LINK (调试和串口) |
| **microSD 卡** | ≥8GB, Class 10 或 UHS-I | ~$10-20 | 存储系统镜像 |
| **microSD 读卡器** | USB 3.0+ | ~$10 | 烧录镜像到 SD 卡 |

### 推荐硬件

| 项目 | 规格要求 | 参考价格 | 说明 |
|------|---------|---------|------|
| **以太网线** | Cat 5e 或更高 | ~$5 | 网络连接(推荐) |
| **HDMI 线** | HDMI Type-A | ~$8 | 连接显示器(调试用) |
| **显示器** | 支持 HDMI 输入 | - | 图形界面调试 |
| **USB 键盘/鼠标** | USB-A 接口 | - | 交互操作(可选) |

### 可选硬件

| 项目 | 规格要求 | 参考价格 | 说明 |
|------|---------|---------|------|
| **JTAG/SWD 调试器** | ST-LINK/V2-1 或兼容 | ~$20-50 | 高级调试(板载 ST-LINK 通常够用) |
| **USB-TTL 转换器** | 3.3V 电平,FTDI/CH340 | ~$5-10 | 备用串口调试 |

## STM32MP157F-DK2 接口说明

### 开发板布局图

```
┌─────────────────────────────────────────────────┐
│                                                 │
│  [Ethernet]                      [HDMI]        │
│                                                 │
│  [USB-C]  [USB-A]  [USB-A]                     │
│  (Power)  (Host)   (Host)                      │
│                                                 │
│                    [microSD slot]               │
│                                                 │
│  [USB Micro-B]                    [GPIO Header]│
│  (ST-LINK)                                      │
│                                                 │
│                 [Reset] [User Buttons]          │
└─────────────────────────────────────────────────┘
```

### 关键接口详解

1. **CN7 - USB Type-C (Power)**
   - 功能: 主电源输入
   - 规格: 5V DC, 3A
   - 注意: 必须使用支持数据+电源的 USB-C 线

2. **CN15 - USB Micro-B (ST-LINK)**
   - 功能: 板载调试器和虚拟串口
   - 用途:
     - 程序下载和调试
     - 串口控制台 (115200 baud, 8N1)
     - 固件更新

3. **CN2 - 以太网 RJ45**
   - 功能: 千兆以太网
   - 推荐: 连接到局域网路由器

4. **CN13 - HDMI Type-A**
   - 功能: 视频输出
   - 分辨率: 最高 1920x1080@60Hz

5. **CN17 - microSD 卡槽**
   - 功能: 启动介质和文件系统
   - 支持: microSDHC/SDXC

6. **CN11/CN16 - USB Type-A (Host)**
   - 功能: USB 主机接口
   - 用途: 连接键盘、鼠标、U盘等

7. **GPIO 扩展排针**
   - 位置: Arduino Uno v3 兼容
   - 用途: 自定义硬件扩展

## 逐步连接指南

### 步骤 1: 准备 SD 卡

1. **格式化 SD 卡**
   ```bash
   # Ubuntu/Debian
   # 插入 SD 卡后查看设备名
   lsblk

   # 假设 SD 卡是 /dev/sdX (请替换为实际设备)
   sudo umount /dev/sdX*
   ```

2. **下载官方测试镜像**
   - 访问: [ST OpenSTLinux](https://www.st.com/en/embedded-software/stm32mp1starter.html)
   - 选择: `st-image-weston` (带图形界面) 或 `st-image-core` (最小系统)
   - 版本: OpenSTLinux 5.0 或更高

3. **烧录镜像到 SD 卡**
   ```bash
   # 方法 1: 使用 dd
   sudo dd if=st-image-weston-openstlinux-weston-stm32mp1.wic \
           of=/dev/sdX \
           bs=4M \
           conv=fsync \
           status=progress

   # 方法 2: 使用 bmaptool (更快)
   sudo apt install bmap-tools
   sudo bmaptool copy st-image-weston-*.wic.bz2 /dev/sdX

   # 方法 3: 使用 Etcher (图形界面)
   # 下载: https://www.balena.io/etcher/
   ```

### 步骤 2: 硬件连接顺序

**重要**: 按以下顺序连接,避免潜在问题

1. **插入 SD 卡**
   - 将准备好的 SD 卡插入开发板的 microSD 卡槽 (CN17)
   - 确保卡完全插入,听到"咔嗒"声

2. **连接调试串口**
   - 使用 USB Micro-B 线连接开发板的 CN15 到 PC
   - 连接后,PC 会识别为虚拟串口设备
   - Linux: `/dev/ttyACM0` 或 `/dev/ttyUSB0`
   - macOS: `/dev/cu.usbmodemXXXX`
   - Windows: `COMx`

3. **连接以太网 (推荐)**
   - 将以太网线连接到 CN2
   - 另一端连接到路由器或交换机

4. **连接显示器 (可选)**
   - 使用 HDMI 线连接 CN13 到显示器

5. **连接 USB 外设 (可选)**
   - 键盘/鼠标连接到 CN11 或 CN16

6. **最后连接电源**
   - 使用 USB Type-C 线连接 5V/3A 电源适配器到 CN7
   - 连接电源后,开发板会自动上电

### 步骤 3: 启动配置

#### 启动模式选择

STM32MP157F-DK2 支持多种启动模式,通过板上的 Boot 开关配置:

| Boot 模式 | 开关位置 | 说明 |
|-----------|---------|------|
| **SD Card** | BOOT0=0, BOOT2=1 | 从 SD 卡启动 (默认) |
| **eMMC** | BOOT0=0, BOOT2=0 | 从板载 eMMC 启动 |
| **USB (DFU)** | BOOT0=1, BOOT2=0 | USB 固件更新模式 |

**首次启动推荐**: 使用 SD Card 模式 (出厂默认)

### 步骤 4: 串口连接和监控

1. **安装串口工具**
   ```bash
   # Ubuntu/Debian
   sudo apt install minicom screen picocom

   # macOS
   brew install minicom

   # 或使用 screen (系统自带)
   ```

2. **连接串口**
   ```bash
   # 方法 1: 使用 minicom
   sudo minicom -D /dev/ttyACM0 -b 115200

   # 方法 2: 使用 screen
   sudo screen /dev/ttyACM0 115200

   # 方法 3: 使用 picocom
   sudo picocom -b 115200 /dev/ttyACM0
   ```

3. **串口配置**
   - 波特率: **115200**
   - 数据位: **8**
   - 校验位: **None**
   - 停止位: **1**
   - 流控制: **None**

### 步骤 5: 首次启动

1. **上电启动**
   - 连接电源后,观察以下指示:
     - LED 指示灯开始闪烁
     - 串口输出启动日志
     - HDMI 显示启动画面 (如已连接)

2. **启动日志示例**
   ```
   U-Boot 2022.10 (STM32MP157F-DK2)

   CPU: STM32MP157FAC Rev.Z
   Model: STMicroelectronics STM32MP157F-DK2 Discovery Board
   DRAM:  512 MiB

   [    0.000000] Booting Linux on physical CPU 0x0
   [    0.000000] Linux version 6.1.28
   ...

   OpenSTLinux weston stm32mp1 /dev/ttySTM0

   stm32mp1 login:
   ```

3. **默认登录凭据**
   - 用户名: `root`
   - 密码: (无密码,直接按回车)

   或者:
   - 用户名: `weston`
   - 密码: `weston`

### 步骤 6: 验证系统

登录后执行以下命令验证系统:

```bash
# 检查系统信息
uname -a
cat /etc/os-release

# 检查 CPU 信息
cat /proc/cpuinfo

# 检查内存
free -h

# 检查存储
df -h

# 检查网络 (如果连接以太网)
ip addr
ping -c 4 8.8.8.8

# 检查 TEE 是否正常 (重要!)
ls -la /dev/tee*
tee-supplicant --version
```

预期输出:
```bash
root@stm32mp1:~# ls -la /dev/tee*
crw------- 1 root root 10, 223 Jan  1  1970 /dev/tee0
crw------- 1 root root 10, 224 Jan  1  1970 /dev/teepriv0
```

如果看到 `/dev/tee0` 设备,说明 OP-TEE 已正常加载。

## 网络配置

### 以太网配置 (DHCP)

```bash
# 查看网络接口
ip link

# 启用以太网 (通常是 eth0 或 end0)
ip link set eth0 up

# 获取 DHCP 地址
udhcpc -i eth0

# 查看 IP 地址
ip addr show eth0
```

### SSH 远程访问

```bash
# 在开发板上查看 IP 地址
ip addr show eth0 | grep inet

# 在 PC 上通过 SSH 连接
ssh root@<开发板IP>
```

## 常见问题排查

### 问题 1: 开发板无法启动

**症状**: 上电后无任何反应,LED 不亮

**排查步骤**:
1. 检查电源适配器是否为 5V/3A
2. 确认 USB-C 线支持数据传输 (不是充电线)
3. 测量 CN7 的电压是否为 5V
4. 尝试更换电源线和适配器

### 问题 2: 串口无输出

**症状**: 连接串口后看不到任何输出

**排查步骤**:
1. 确认串口参数: 115200, 8N1
2. 检查 USB Micro-B 线是否连接到 CN15
3. 确认 PC 识别了串口设备:
   ```bash
   # Linux
   ls -la /dev/ttyACM*
   dmesg | grep tty

   # macOS
   ls -la /dev/cu.usbmodem*
   ```
4. 尝试不同的串口工具 (minicom, screen, picocom)
5. 检查用户权限:
   ```bash
   sudo usermod -aG dialout $USER
   # 需要重新登录生效
   ```

### 问题 3: SD 卡无法识别

**症状**: 启动停留在 U-Boot 或提示找不到 SD 卡

**排查步骤**:
1. 确认 SD 卡完全插入
2. 尝试重新格式化并烧录镜像
3. 更换 SD 卡 (建议使用品牌卡)
4. 检查启动模式开关是否设置为 SD Card 模式
5. 在 U-Boot 下手动检测:
   ```
   STM32MP> mmc list
   STM32MP> mmc dev 0
   STM32MP> mmc info
   ```

### 问题 4: 网络不通

**症状**: 无法获取 IP 地址或 ping 不通

**排查步骤**:
1. 检查以太网线是否插好
2. 确认路由器 DHCP 功能开启
3. 查看网卡状态:
   ```bash
   ip link show eth0
   dmesg | grep eth0
   ```
4. 手动配置静态 IP:
   ```bash
   ip addr add 192.168.1.100/24 dev eth0
   ip route add default via 192.168.1.1
   ```

### 问题 5: HDMI 无显示

**症状**: 显示器显示"无信号"

**排查步骤**:
1. 确认 HDMI 线连接牢固
2. 检查显示器输入源选择
3. 尝试不同的 HDMI 线
4. 通过串口检查图形系统是否启动:
   ```bash
   ps aux | grep weston
   ```

### 问题 6: TEE 设备不存在

**症状**: `/dev/tee0` 不存在

**排查步骤**:
1. 检查内核日志:
   ```bash
   dmesg | grep -i tee
   dmesg | grep -i optee
   ```
2. 确认使用的镜像支持 OP-TEE
3. 检查设备树配置
4. 尝试使用官方最新镜像

## LED 指示灯说明

| LED | 位置 | 说明 |
|-----|------|------|
| **LD4 (红色)** | 电源指示 | 上电后常亮 |
| **LD5 (绿色)** | 用户 LED | 可编程控制 |
| **LD6 (橙色)** | Cortex-M4 心跳 | M4 核运行时闪烁 |
| **LD7 (蓝色)** | Cortex-A7 心跳 | A7 核运行时闪烁 |

正常启动后应看到:
- LD4 常亮 (电源)
- LD7 闪烁 (A7 核活动)

## 按钮功能

| 按钮 | 位置 | 功能 |
|------|------|------|
| **RESET** | 黑色按钮 | 硬件复位 |
| **USER1** | 蓝色按钮 | 用户可编程按钮 1 |
| **USER2** | 蓝色按钮 | 用户可编程按钮 2 |

## 下一步

硬件连接完成后,请继续阅读:
- [Phase 1: 开发环境配置](phase1-development-environment.md) - 配置 Ubuntu 开发工具链
- [Phase 1: OP-TEE 设置](phase1-optee-setup.md) - 编译和配置 OP-TEE

## 参考资源

- [STM32MP157F-DK2 官方页面](https://www.st.com/en/evaluation-tools/stm32mp157f-dk2.html)
- [硬件描述 Wiki](https://wiki.st.com/stm32mpu/wiki/STM32MP157x-DKx_-_hardware_description)
- [入门指南](https://wiki.st.com/stm32mpu/wiki/Getting_started/STM32MP1_boards/STM32MP157x-DK2)
- [用户手册 (UM2534)](https://www.st.com/resource/en/user_manual/um2534-discovery-kits-with-stm32mp157-mpus-stmicroelectronics.pdf)
