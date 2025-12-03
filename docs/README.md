# STM32MP157F-DK2 Documentation Index
# STM32MP157F-DK2 文档索引

**Complete guides for AirAccount TMS hardware TEE implementation**
**AirAccount TMS 硬件 TEE 实现完整指南**

---

## 🚀 Quick Start Guides / 快速开始指南

### For Mac Users / Mac 用户

| Guide / 指南 | Description / 描述 |
|--------------|-------------------|
| [USB Keyboard Quick Start](quick-start-with-usb-keyboard.md) | ⭐ **Fastest method** - Borrow a keyboard, configure WiFi in 5 mins<br>⭐ **最快方案** - 借个键盘,5 分钟配置 WiFi |
| [Type-C Only Mac Connection](connection-guide-typec-only-mac.md) | 💻 Mac with only Type-C ports? 3 connection solutions<br>💻 Mac 只有 Type-C 口? 3 种连接方案 |
| [Mac Troubleshooting](troubleshooting-mac-connection.md) | 🔧 ST-LINK not recognized? Network issues? Solutions here<br>🔧 ST-LINK 未识别? 网络问题? 解决方案在此 |
| [Mac Development Workflow](mac-development-workflow.md) | 📱 Complete VNC/SSH workflow, on-board compilation guide<br>📱 完整 VNC/SSH 工作流,板上编译指南 |

### For Ubuntu/Debian Users / Ubuntu/Debian 用户

| Guide / 指南 | Description / 描述 |
|--------------|-------------------|
| [Hardware Setup](phase1-hardware-setup.md) | 🔌 Step-by-step hardware connection from unboxing<br>🔌 从开箱到首次启动的硬件连接 |
| [Development Environment](phase1-development-environment.md) | 🛠️ Cross-compilation toolchain setup<br>🛠️ 交叉编译工具链完整安装 |
| [OP-TEE Setup](phase1-optee-setup.md) | 🔐 OP-TEE compilation, deployment and TA development<br>🔐 OP-TEE 编译、部署和 TA 开发 |

---

## 📚 Phase Documentation / 阶段文档

### Phase 1: Hardware Migration (2-3 months) / 阶段 1: 硬件迁移 (2-3 个月)

**Goal / 目标**: Migrate KMS from Docker/QEMU to real STM32MP157F-DK2 hardware
**目标**: 将 KMS 从 Docker/QEMU 迁移到真实的 STM32MP157F-DK2 硬件

| Document / 文档 | Content / 内容 |
|-----------------|---------------|
| [Phase 1 Hardware Setup](phase1-hardware-setup.md) | Hardware checklist, connection guide, serial port config<br>硬件清单、连接指南、串口配置 |
| [Phase 1 Dev Environment](phase1-development-environment.md) | Ubuntu toolchain, NFS/TFTP, ST-LINK udev rules<br>Ubuntu 工具链、NFS/TFTP、ST-LINK udev 规则 |
| [Phase 1 OP-TEE](phase1-optee-setup.md) | OP-TEE architecture, compilation, Hello World TA<br>OP-TEE 架构、编译、Hello World TA |

### Phase 2: Industrialization (2-3 months) / 阶段 2: 工业化 (2-3 个月)

**Goal / 目标**: Transition to industrial-grade hardware (<$500/node)
**目标**: 过渡到工业级硬件 (<$500/节点)

| Document / 文档 | Content / 内容 |
|-----------------|---------------|
| [Industrial Hardware](phase2-industrial-hardware.md) | SBC comparison, migration path, procurement<br>SBC 对比、迁移路径、采购渠道 |

### Phase 3: Decentralization (6-9 months) / 阶段 3: 去中心化 (6-9 个月)

**Goal / 目标**: Deploy 3-5 nodes in Chiang Mai for community experiment
**目标**: 在清迈部署 3-5 节点进行社区实验

| Document / 文档 | Content / 内容 |
|-----------------|---------------|
| [Architecture Design](phase3-architecture.md) | Distributed KMS, Shamir Secret Sharing, TSS<br>分布式 KMS、Shamir 秘密共享、TSS |

---

## 🔧 Common Scenarios / 常见场景

### Scenario 1: Just Got the Board / 刚拿到开发板

**You have / 你有**: STM32MP157F-DK2 board with SD card
**You have / 你有**: STM32MP157F-DK2 开发板和 SD 卡

**Recommended path / 推荐路径**:
1. Read [USB Keyboard Quick Start](quick-start-with-usb-keyboard.md) / 阅读 [USB 键盘快速上手](quick-start-with-usb-keyboard.md)
2. Borrow a USB keyboard / 借一个 USB 键盘
3. Connect keyboard to board CN7 (OTG) / 将键盘连到开发板 CN7 (OTG)
4. Configure WiFi on LCD / 在 LCD 上配置 WiFi
5. SSH from Mac and start developing! / 从 Mac SSH 连接,开始开发!

### Scenario 2: Mac with Only Type-C Ports / Mac 只有 Type-C 口

**Problem / 问题**: No USB-A port, no USB keyboard
**问题**: 没有 USB-A 口,没有 USB 键盘

**Recommended path / 推荐路径**:
1. Read [Type-C Only Mac Guide](connection-guide-typec-only-mac.md) / 阅读 [Type-C Only Mac 指南](connection-guide-typec-only-mac.md)
2. **Option A**: Buy USB-C to Ethernet adapter ($15-30) / **方案 A**: 购买 USB-C 转以太网适配器 ($15-30)
3. **Option B**: Borrow USB keyboard + Hub / **方案 B**: 借 USB 键盘 + Hub

### Scenario 3: ST-LINK Not Recognized / ST-LINK 未识别

**Problem / 问题**: Mini USB connected but Mac doesn't see /dev/tty.usbmodem*
**问题**: Mini USB 已连接但 Mac 看不到 /dev/tty.usbmodem*

**Solution / 解决方案**:
1. Read [Mac Troubleshooting](troubleshooting-mac-connection.md) / 阅读 [Mac 连接故障排查](troubleshooting-mac-connection.md)
2. **Important**: ST-LINK is not required for daily development! / **重要**: ST-LINK 不是日常开发必需的!
3. Use WiFi/Ethernet + SSH instead / 使用 WiFi/以太网 + SSH 代替

### Scenario 4: Ready to Start Development / 准备开始开发

**You have / 你有**: Board connected to WiFi, SSH working
**你有**: 开发板已连 WiFi,SSH 可用

**Recommended path / 推荐路径**:
1. Read [Mac Development Workflow](mac-development-workflow.md) / 阅读 [Mac 开发工作流](mac-development-workflow.md)
2. Clone code: `git clone https://github.com/AAStarCommunity/AirAccount.git`
3. Compile on-board: `cd AirAccount && make`
4. Start KMS TA development! / 开始 KMS TA 开发!

---

## 🎯 Hardware Interfaces Reference / 硬件接口参考

### STM32MP157F-DK2 Connectors / 接口说明

| Connector / 接口 | Type / 类型 | Purpose / 用途 | Your Use Case / 你的用途 |
|------------------|-------------|----------------|------------------------|
| **CN6** | USB Type-C | Power (5V/3A) / 供电 (5V/3A) | ✅ Must connect / 必须连接 |
| **CN7** | USB Type-C | OTG (connect USB devices) / OTG (连接 USB 设备) | ✅ Connect keyboard! / 连接键盘! |
| **CN11** | Mini USB | ST-LINK debug / ST-LINK 调试 | ⚠️ Optional / 可选 |
| **CN2** | RJ45 | Ethernet / 以太网 | ✅ If you have adapter / 如果有适配器 |

### Buttons / 按钮

| Button / 按钮 | Function / 功能 |
|---------------|----------------|
| **B1** (Reset) | Restart board / 重启开发板 |
| **B2** (User) | User programmable / 用户可编程 |
| ❌ No power button / 无电源按钮 | Shutdown via command: `sudo poweroff` / 通过命令关机: `sudo poweroff` |

### LEDs / 指示灯

| LED | Color / 颜色 | Meaning / 含义 |
|-----|-------------|---------------|
| **LD6** | Green / 绿色 | Power on / 供电正常 |
| **LD7** | Red/Orange / 红/橙 | ST-LINK activity / ST-LINK 活动 |
| **LD4** | Blue / 蓝色 | User programmable / 用户可编程 |

---

## 💡 Key Concepts / 关键概念

### What is ST-LINK? / ST-LINK 是什么?

**ST-LINK is NOT a cable!** It's a debug chip soldered on the board.
**ST-LINK 不是线!** 它是焊接在开发板上的调试芯片。

- **Purpose / 用途**: Serial console, firmware flashing, debugging
- **用途**: 串口控制台、固件烧录、调试
- **Connection / 连接**: Mac → Mini USB cable → CN11 → ST-LINK chip
- **连接**: Mac → Mini USB 线 → CN11 → ST-LINK 芯片
- **Important / 重要**: Not required for daily development! Use SSH instead.
- **重要**: 日常开发不需要!用 SSH 代替。

### USB OTG Two Modes / USB OTG 两种模式

#### Mode 1: Device Mode (Flashing) / 模式 1: 设备模式 (烧录)
- Board acts as USB device / 开发板作为 USB 设备
- Connect to PC with STM32CubeProgrammer / 连接 PC 用 STM32CubeProgrammer
- Used for: Flash images, update firmware / 用于: 烧录镜像、更新固件
- **Do you need this? / 你需要吗?**: ❌ No, SD card already has image / 否,SD 卡已有镜像

#### Mode 2: Host Mode (Connect Devices) / 模式 2: 主机模式 (连接设备)
- Board acts as USB host / 开发板作为 USB 主机
- Connect: Keyboard, mouse, flash drive / 连接: 键盘、鼠标、U 盘
- Used for: Operating on LCD, configuring WiFi / 用于: 在 LCD 操作、配置 WiFi
- **Do you need this? / 你需要吗?**: ✅ Yes! Connect keyboard / 是的!连接键盘

### WiFi Configuration / WiFi 配置

**Once configured, saved permanently! / 配置一次,永久保存!**

```bash
# Scan networks / 扫描网络
nmcli device wifi list

# Connect / 连接
nmcli device wifi connect "WiFi-Name" password "password"

# Check IP / 查看 IP
ip addr show wlan0
```

Next boot will auto-connect! / 下次开机自动连接!

---

## 📞 Getting Help / 获取帮助

### If you're stuck / 如果遇到问题:

1. **Check the relevant guide / 查看相关指南**:
   - Connection issue? → [Troubleshooting](troubleshooting-mac-connection.md)
   - 连接问题? → [故障排查](troubleshooting-mac-connection.md)
   - No keyboard? → [Type-C Only Guide](connection-guide-typec-only-mac.md)
   - 没键盘? → [Type-C Only 指南](connection-guide-typec-only-mac.md)

2. **Common solutions / 常见解决方案**:
   - ✅ Use WiFi instead of ST-LINK / 用 WiFi 代替 ST-LINK
   - ✅ Borrow a USB keyboard / 借一个 USB 键盘
   - ✅ Buy USB-C to Ethernet adapter / 买 USB-C 转以太网适配器

3. **Check project resources / 查看项目资源**:
   - [Main README](../README.md)
   - [Roadmap](../ROADMAP.md)
   - [CLAUDE.md](../CLAUDE.md)

---

## 🎓 Learning Path / 学习路径

### For Beginners / 新手

1. Start with [USB Keyboard Quick Start](quick-start-with-usb-keyboard.md)
2. 从 [USB 键盘快速上手](quick-start-with-usb-keyboard.md) 开始
3. Get board connected to WiFi / 让开发板连上 WiFi
4. Learn [Mac Development Workflow](mac-development-workflow.md)
5. 学习 [Mac 开发工作流](mac-development-workflow.md)
6. Try Hello World TA from [OP-TEE Guide](phase1-optee-setup.md)
7. 试试 [OP-TEE 指南](phase1-optee-setup.md) 中的 Hello World TA

### For Experienced Developers / 有经验的开发者

1. Skim [Hardware Setup](phase1-hardware-setup.md)
2. 浏览 [硬件设置](phase1-hardware-setup.md)
3. Focus on [OP-TEE Setup](phase1-optee-setup.md)
4. 专注于 [OP-TEE 设置](phase1-optee-setup.md)
5. Review [Phase 3 Architecture](phase3-architecture.md) for distributed design
6. 查看 [阶段 3 架构](phase3-architecture.md) 了解分布式设计
7. Start KMS TA development! / 开始 KMS TA 开发!

---

## 📦 What's in the Box / 包装清单

**Typical STM32MP157F-DK2 package includes / 典型 STM32MP157F-DK2 包装包含**:

- ✅ STM32MP157F-DK2 board / 开发板
- ✅ Power adapter (USB-C) / 电源适配器 (USB-C)
- ✅ USB Type-C cable (power) / USB Type-C 线 (供电用)
- ❓ Mini USB cable (may not be included) / Mini USB 线 (可能不包含)
- ❌ USB keyboard (not included) / USB 键盘 (不包含)
- ❌ Ethernet cable (not included) / 网线 (不包含)

**You may need to buy / 你可能需要购买**:
- USB keyboard / USB 键盘
- OR USB-C to Ethernet adapter / 或 USB-C 转以太网适配器
- Mini USB data cable (for ST-LINK, optional) / Mini USB 数据线 (用于 ST-LINK,可选)

---

## 🚀 Next Steps / 下一步

After completing hardware setup / 硬件设置完成后:

1. **Clone AirAccount KMS code / 克隆 AirAccount KMS 代码**:
   ```bash
   git clone https://github.com/AAStarCommunity/AirAccount.git
   cd AirAccount
   ```

2. **Start Phase 1 development / 开始阶段 1 开发**:
   - Implement KMS TA / 实现 KMS TA
   - Test key generation and signing / 测试密钥生成和签名
   - Verify secure storage / 验证安全存储

3. **Follow the [Roadmap](../ROADMAP.md) / 跟随 [路线图](../ROADMAP.md)**

---

**Happy developing! / 开发愉快!** 🎉
