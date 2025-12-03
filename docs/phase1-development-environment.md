# Phase 1: Ubuntu/Debian 开发环境配置

> 📖 **中文用户快速导航** | **Quick Navigation for Chinese Users**
> - [🎹 USB 键盘快速上手](quick-start-with-usb-keyboard.md) | [📱 Mac 开发工作流](mac-development-workflow.md) | [🔧 故障排查](troubleshooting-mac-connection.md)
> - [🔌 硬件设置](phase1-hardware-setup.md) | [🔐 OP-TEE 开发](phase1-optee-setup.md) | [🏭 工业硬件](phase2-industrial-hardware.md)
> - [🏠 返回主页](../README.md) | [📚 所有文档](../docs/)

## 概述

本文档详细说明如何在 Ubuntu/Debian 系统上搭建 STM32MP157F-DK2 的完整开发环境,包括交叉编译工具链、SDK、调试工具等。

## 系统要求

### 推荐配置

- **操作系统**: Ubuntu 22.04 LTS / 20.04 LTS 或 Debian 11+
- **CPU**: x86_64 (Intel/AMD) 或 ARM64
- **内存**: ≥8GB (推荐 16GB+)
- **硬盘空间**: ≥50GB 可用空间
- **网络**: 稳定的互联网连接

### 支持的 Ubuntu 版本

| 版本 | 代号 | 支持状态 | 说明 |
|------|------|---------|------|
| Ubuntu 24.04 LTS | Noble | ✅ 推荐 | 最新 LTS,工具链完善 |
| Ubuntu 22.04 LTS | Jammy | ✅ 推荐 | 稳定,官方主要测试版本 |
| Ubuntu 20.04 LTS | Focal | ✅ 支持 | 长期支持,稳定性好 |
| Ubuntu 18.04 LTS | Bionic | ⚠️ 可用 | 即将结束支持 |

## 快速开始

如果您想快速搭建环境,可以使用我们提供的自动化脚本:

```bash
# 下载并运行自动安装脚本
cd ~/Dev/crypto-projects/STM32MP157F-DK2
./scripts/setup-ubuntu-dev-env.sh
```

脚本会自动安装所有必需的开发工具。如果您想了解详细步骤或手动安装,请继续阅读下文。

## 手动安装步骤

### 步骤 1: 更新系统

```bash
# 更新软件包列表
sudo apt update

# 升级已安装的软件包
sudo apt upgrade -y

# 安装基础构建工具
sudo apt install -y build-essential git curl wget
```

### 步骤 2: 安装 ARM 交叉编译工具链

STM32MP157F 使用 ARM Cortex-A7 (32位),需要 ARM 交叉编译器。

#### 方法 1: 使用系统包管理器 (推荐)

```bash
# 安装 ARM 交叉编译器 (用于 Linux 应用)
sudo apt install -y gcc-arm-linux-gnueabihf \
                    g++-arm-linux-gnueabihf \
                    binutils-arm-linux-gnueabihf

# 验证安装
arm-linux-gnueabihf-gcc --version
```

预期输出:
```
arm-linux-gnueabihf-gcc (Ubuntu ...) 11.4.0
Copyright (C) 2021 Free Software Foundation, Inc.
```

#### 方法 2: 使用 Linaro 工具链 (可选)

```bash
# 下载 Linaro 工具链
cd ~/Downloads
wget https://releases.linaro.org/components/toolchain/binaries/latest-7/arm-linux-gnueabihf/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf.tar.xz

# 解压
sudo mkdir -p /opt/toolchains
sudo tar -xf gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf.tar.xz -C /opt/toolchains/

# 添加到 PATH
echo 'export PATH=/opt/toolchains/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# 验证
arm-linux-gnueabihf-gcc --version
```

### 步骤 3: 安装 STM32 开发工具

#### 3.1 STM32CubeProgrammer (烧录工具)

```bash
# 下载 STM32CubeProgrammer
# 访问: https://www.st.com/en/development-tools/stm32cubeprog.html
# 需要注册 ST 账号并下载 Linux 版本

# 假设下载到 ~/Downloads/en.stm32cubeprog-lin-v2-15-0.zip
cd ~/Downloads
unzip en.stm32cubeprog-lin-v2-15-0.zip
cd en.stm32cubeprog-lin-v2-15-0

# 运行安装程序
sudo ./SetupSTM32CubeProgrammer-*.linux

# 默认安装到 ~/STMicroelectronics/STM32Cube/STM32CubeProgrammer

# 添加到 PATH
echo 'export PATH=~/STMicroelectronics/STM32Cube/STM32CubeProgrammer/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# 安装依赖 (32位库)
sudo apt install -y libusb-1.0-0 libusb-1.0-0-dev
```

#### 3.2 安装 STM32 udev 规则 (USB 访问权限)

```bash
# 创建 udev 规则文件
sudo tee /etc/udev/rules.d/49-stlinkv2.rules > /dev/null <<'EOF'
# ST-LINK/V2
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", MODE="0666"
# ST-LINK/V2-1
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", MODE="0666"
# ST-LINK/V3
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374d", MODE="0666"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374e", MODE="0666"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374f", MODE="0666"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3753", MODE="0666"
# STM32MP1 DFU mode
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE="0666"
EOF

# 重新加载 udev 规则
sudo udevadm control --reload-rules
sudo udevadm trigger

# 将当前用户添加到 dialout 组 (串口访问)
sudo usermod -aG dialout $USER

# 注意: 需要注销并重新登录才能生效
```

### 步骤 4: 安装 Yocto 构建依赖

如果您计划从源码构建完整的 Linux 镜像,需要 Yocto 构建系统的依赖:

```bash
sudo apt install -y \
    gawk wget git-core diffstat unzip texinfo \
    gcc-multilib build-essential chrpath socat cpio \
    python3 python3-pip python3-pexpect xz-utils \
    debianutils iputils-ping python3-git python3-jinja2 \
    libegl1-mesa libsdl1.2-dev pylint3 xterm \
    libncurses5-dev libssl-dev \
    repo android-tools-adb android-tools-fastboot
```

### 步骤 5: 安装开发辅助工具

#### 5.1 串口通信工具

```bash
# 安装多个串口工具
sudo apt install -y minicom screen picocom

# 配置 minicom (可选)
# 运行 minicom -s 进行配置
# 设置: 串口 /dev/ttyACM0, 波特率 115200, 8N1
```

#### 5.2 网络工具

```bash
sudo apt install -y \
    openssh-server openssh-client \
    nfs-kernel-server \
    tftp-hpa tftpd-hpa \
    net-tools iputils-ping \
    tcpdump wireshark
```

#### 5.3 文件系统工具

```bash
sudo apt install -y \
    dosfstools mtools \
    e2fsprogs \
    bmap-tools \
    mtd-utils
```

#### 5.4 调试工具

```bash
# GDB 多架构支持
sudo apt install -y \
    gdb-multiarch \
    gdbserver

# OpenOCD (开源调试器)
sudo apt install -y openocd
```

### 步骤 6: 安装 ST SDK 和 BSP

#### 6.1 下载 OpenSTLinux SDK

```bash
# 创建工作目录
mkdir -p ~/STM32MPU
cd ~/STM32MPU

# 下载 SDK
# 访问: https://www.st.com/en/embedded-software/stm32mp1dev.html
# 选择: OpenSTLinux Distribution Package

# 或使用 wget (需要获取直接下载链接)
# 这里以 v5.0 为例
wget https://www.st.com/content/ccc/resource/technical/software/sw_development_suite/...

# 解压
tar xf en.SDK-x86_64-stm32mp1-openstlinux-*.tar.xz

# 安装 SDK
cd SDK
./st-image-weston-openstlinux-weston-stm32mp1-x86_64-toolchain-*.sh

# 按提示安装,默认路径: /opt/st/stm32mp1/...
```

#### 6.2 配置 SDK 环境

每次使用 SDK 前需要设置环境变量:

```bash
# 设置 SDK 环境
source /opt/st/stm32mp1/5.0-snapshot/environment-setup-cortexa7t2hf-neon-vfpv4-ostl-linux-gnueabi

# 验证
echo $CROSS_COMPILE
# 应输出: arm-ostl-linux-gnueabi-

# 为方便使用,可以添加到 ~/.bashrc
echo 'alias setup-stm32mp1="source /opt/st/stm32mp1/5.0-snapshot/environment-setup-cortexa7t2hf-neon-vfpv4-ostl-linux-gnueabi"' >> ~/.bashrc
```

### 步骤 7: 安装 Git 和 Repo 工具

```bash
# 安装 Git (应该已安装)
sudo apt install -y git

# 配置 Git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 安装 Repo (用于管理多个 Git 仓库)
sudo apt install -y repo

# 或手动安装 Repo
mkdir -p ~/.bin
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/.bin/repo
chmod a+x ~/.bin/repo
export PATH=~/.bin:$PATH
```

### 步骤 8: 安装 Python 开发环境 (可选)

某些工具需要 Python 3:

```bash
# 安装 Python 3 和 pip
sudo apt install -y python3 python3-pip python3-venv

# 安装常用 Python 包
pip3 install --user \
    pyserial \
    pycrypto \
    pycryptodome \
    requests \
    jinja2
```

## 验证安装

完成所有安装后,运行以下命令验证:

```bash
# 1. 检查交叉编译器
arm-linux-gnueabihf-gcc --version
arm-linux-gnueabihf-g++ --version

# 2. 检查构建工具
make --version
cmake --version

# 3. 检查调试工具
gdb-multiarch --version
openocd --version

# 4. 检查 Git
git --version
repo --version

# 5. 检查 Python
python3 --version
pip3 --version

# 6. 检查串口权限
groups | grep dialout

# 7. 检查 USB 设备访问
# 连接开发板后执行
lsusb | grep -i stm
```

## 测试交叉编译

创建一个简单的测试程序:

```bash
# 创建测试目录
mkdir -p ~/test-cross-compile
cd ~/test-cross-compile

# 创建测试程序
cat > hello.c <<'EOF'
#include <stdio.h>

int main() {
    printf("Hello from STM32MP157F-DK2!\n");
    printf("Compiled with %s\n", __VERSION__);
    return 0;
}
EOF

# 交叉编译
arm-linux-gnueabihf-gcc -o hello hello.c

# 检查生成的二进制
file hello
# 应输出: hello: ELF 32-bit LSB executable, ARM, ...

# 查看二进制信息
arm-linux-gnueabihf-readelf -h hello
```

将生成的 `hello` 文件传输到 STM32MP157F-DK2 并运行:

```bash
# 在开发板上
./hello

# 预期输出:
# Hello from STM32MP157F-DK2!
# Compiled with ...
```

## 配置 NFS 服务器 (推荐)

NFS 可以方便地在 PC 和开发板之间共享文件:

```bash
# 安装 NFS 服务器
sudo apt install -y nfs-kernel-server

# 创建共享目录
sudo mkdir -p /srv/nfs/stm32mp1
sudo chown nobody:nogroup /srv/nfs/stm32mp1
sudo chmod 777 /srv/nfs/stm32mp1

# 配置 NFS 导出
sudo tee -a /etc/exports > /dev/null <<EOF
/srv/nfs/stm32mp1 *(rw,sync,no_subtree_check,no_root_squash)
EOF

# 重启 NFS 服务
sudo exportfs -ra
sudo systemctl restart nfs-kernel-server

# 检查导出状态
sudo exportfs -v
```

在开发板上挂载 NFS:

```bash
# 在 STM32MP157F-DK2 上执行
mkdir -p /mnt/nfs
mount -t nfs <PC_IP>:/srv/nfs/stm32mp1 /mnt/nfs

# 验证
df -h | grep nfs
```

## 配置 TFTP 服务器 (可选)

TFTP 用于网络启动和快速传输内核镜像:

```bash
# 安装 TFTP 服务器
sudo apt install -y tftpd-hpa

# 配置 TFTP
sudo tee /etc/default/tftpd-hpa > /dev/null <<EOF
TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/srv/tftp"
TFTP_ADDRESS=":69"
TFTP_OPTIONS="--secure --create"
EOF

# 创建 TFTP 目录
sudo mkdir -p /srv/tftp
sudo chown nobody:nogroup /srv/tftp
sudo chmod 777 /srv/tftp

# 重启服务
sudo systemctl restart tftpd-hpa
sudo systemctl enable tftpd-hpa

# 测试
echo "test" > /srv/tftp/test.txt
tftp localhost -c get test.txt
```

## 开发工具推荐

### IDE 和编辑器

#### Visual Studio Code

```bash
# 安装 VS Code
sudo snap install code --classic

# 推荐插件
code --install-extension ms-vscode.cpptools
code --install-extension ms-vscode.cmake-tools
code --install-extension twxs.cmake
code --install-extension webfreak.debug
```

#### Vim/Neovim (轻量级)

```bash
sudo apt install -y vim neovim

# 安装 vim-plug (Vim 插件管理器)
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

### 版本控制 GUI

```bash
# GitKraken (图形化 Git 工具)
# 下载: https://www.gitkraken.com/

# 或使用 GitG (轻量级)
sudo apt install -y gitg
```

## 常见问题

### 问题 1: 交叉编译器找不到头文件

**解决方案**:
```bash
# 安装完整的 ARM 开发库
sudo apt install -y \
    gcc-arm-linux-gnueabihf \
    g++-arm-linux-gnueabihf \
    libc6-dev-armhf-cross
```

### 问题 2: 串口权限不足

**解决方案**:
```bash
# 添加用户到 dialout 组
sudo usermod -aG dialout $USER

# 注销并重新登录,或使用
newgrp dialout
```

### 问题 3: USB 设备无法识别

**解决方案**:
```bash
# 检查 udev 规则
cat /etc/udev/rules.d/49-stlinkv2.rules

# 重新加载规则
sudo udevadm control --reload-rules
sudo udevadm trigger

# 断开并重新连接 USB
```

### 问题 4: SDK 环境变量未设置

**错误信息**: `CROSS_COMPILE is not set`

**解决方案**:
```bash
# 每次打开新终端都需要执行
source /opt/st/stm32mp1/5.0-snapshot/environment-setup-cortexa7t2hf-neon-vfpv4-ostl-linux-gnueabi

# 或添加别名
echo 'alias setup-sdk="source /opt/st/stm32mp1/5.0-snapshot/environment-setup-cortexa7t2hf-neon-vfpv4-ostl-linux-gnueabi"' >> ~/.bashrc
```

### 问题 5: 磁盘空间不足

Yocto 构建需要大量空间 (50GB+)

**解决方案**:
```bash
# 清理不必要的文件
sudo apt clean
sudo apt autoremove

# 检查大文件
du -h --max-depth=1 ~ | sort -hr | head -20

# 清理 Yocto 构建缓存 (如果存在)
rm -rf ~/STM32MPU/Distribution-Package/build-openstlinux*/tmp/work
```

## 下一步

开发环境配置完成后,请继续:
- [Phase 1: OP-TEE 开发配置](phase1-optee-setup.md) - 编译和配置 OP-TEE
- [Phase 1: 故障排查指南](phase1-troubleshooting.md) - 常见问题解决

## 参考资源

- [STM32MP1 Developer Package](https://wiki.st.com/stm32mpu/wiki/STM32MP1_Developer_Package)
- [OpenSTLinux Distribution](https://wiki.st.com/stm32mpu/wiki/OpenSTLinux_distribution)
- [SDK for OpenSTLinux](https://wiki.st.com/stm32mpu/wiki/SDK_for_OpenSTLinux_distribution)
- [ST GitHub 仓库](https://github.com/STMicroelectronics)
