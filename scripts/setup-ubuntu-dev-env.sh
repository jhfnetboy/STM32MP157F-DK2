#!/bin/bash
#
# STM32MP157F-DK2 Ubuntu/Debian 开发环境自动安装脚本
# 用途: 一键安装所有开发所需的工具和依赖
# 支持: Ubuntu 20.04/22.04/24.04, Debian 11+
#
# 使用方法:
#   chmod +x setup-ubuntu-dev-env.sh
#   ./setup-ubuntu-dev-env.sh
#

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否为 root 或有 sudo 权限
check_sudo() {
    if [ "$EUID" -eq 0 ]; then
        log_warning "检测到以 root 用户运行,某些步骤可能需要调整"
    else
        if ! sudo -v; then
            log_error "需要 sudo 权限,请确保当前用户在 sudoers 中"
            exit 1
        fi
    fi
}

# 检测操作系统
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
        log_info "检测到操作系统: $OS $VER"

        case "$ID" in
            ubuntu|debian)
                log_success "支持的操作系统"
                ;;
            *)
                log_warning "未测试的操作系统,可能遇到问题"
                ;;
        esac
    else
        log_error "无法检测操作系统"
        exit 1
    fi
}

# 更新软件包列表
update_system() {
    log_info "更新软件包列表..."
    sudo apt update
    log_success "软件包列表已更新"
}

# 安装基础构建工具
install_build_essentials() {
    log_info "安装基础构建工具..."
    sudo apt install -y \
        build-essential \
        gcc \
        g++ \
        make \
        cmake \
        autoconf \
        automake \
        libtool \
        pkg-config \
        git \
        curl \
        wget \
        unzip \
        bzip2 \
        xz-utils
    log_success "基础构建工具已安装"
}

# 安装 ARM 交叉编译工具链
install_arm_toolchain() {
    log_info "安装 ARM 交叉编译工具链..."
    sudo apt install -y \
        gcc-arm-linux-gnueabihf \
        g++-arm-linux-gnueabihf \
        binutils-arm-linux-gnueabihf \
        libc6-dev-armhf-cross

    # 验证安装
    if arm-linux-gnueabihf-gcc --version > /dev/null 2>&1; then
        log_success "ARM 交叉编译器已安装"
        arm-linux-gnueabihf-gcc --version | head -n 1
    else
        log_error "ARM 交叉编译器安装失败"
        exit 1
    fi
}

# 安装 Yocto 构建依赖
install_yocto_deps() {
    log_info "安装 Yocto 构建依赖..."
    sudo apt install -y \
        gawk wget git-core diffstat unzip texinfo \
        gcc-multilib chrpath socat cpio \
        python3 python3-pip python3-pexpect \
        debianutils iputils-ping python3-git python3-jinja2 \
        libegl1-mesa libsdl1.2-dev xterm \
        libncurses5-dev libssl-dev \
        zstd lz4
    log_success "Yocto 构建依赖已安装"
}

# 安装串口工具
install_serial_tools() {
    log_info "安装串口通信工具..."
    sudo apt install -y \
        minicom \
        screen \
        picocom \
        cu

    # 添加用户到 dialout 组
    if ! groups | grep -q dialout; then
        log_info "将当前用户添加到 dialout 组..."
        sudo usermod -aG dialout "$USER"
        log_warning "需要注销并重新登录才能生效,或使用 'newgrp dialout'"
    fi

    log_success "串口工具已安装"
}

# 安装网络工具
install_network_tools() {
    log_info "安装网络工具..."
    sudo apt install -y \
        openssh-server \
        openssh-client \
        net-tools \
        iputils-ping \
        tcpdump \
        nmap \
        iperf3
    log_success "网络工具已安装"
}

# 安装 NFS 和 TFTP
install_nfs_tftp() {
    log_info "安装 NFS 和 TFTP 服务..."
    sudo apt install -y \
        nfs-kernel-server \
        tftp-hpa \
        tftpd-hpa

    log_info "配置 NFS..."
    sudo mkdir -p /srv/nfs/stm32mp1
    sudo chown nobody:nogroup /srv/nfs/stm32mp1
    sudo chmod 777 /srv/nfs/stm32mp1

    if ! grep -q "/srv/nfs/stm32mp1" /etc/exports; then
        echo "/srv/nfs/stm32mp1 *(rw,sync,no_subtree_check,no_root_squash)" | sudo tee -a /etc/exports
        sudo exportfs -ra
    fi

    log_info "配置 TFTP..."
    sudo mkdir -p /srv/tftp
    sudo chown nobody:nogroup /srv/tftp
    sudo chmod 777 /srv/tftp

    sudo systemctl enable nfs-kernel-server
    sudo systemctl restart nfs-kernel-server
    sudo systemctl enable tftpd-hpa
    sudo systemctl restart tftpd-hpa

    log_success "NFS 和 TFTP 已配置"
}

# 安装文件系统工具
install_fs_tools() {
    log_info "安装文件系统工具..."
    sudo apt install -y \
        dosfstools \
        mtools \
        e2fsprogs \
        bmap-tools \
        mtd-utils \
        u-boot-tools
    log_success "文件系统工具已安装"
}

# 安装调试工具
install_debug_tools() {
    log_info "安装调试工具..."
    sudo apt install -y \
        gdb-multiarch \
        gdbserver \
        openocd \
        stlink-tools
    log_success "调试工具已安装"
}

# 安装 Python 开发环境
install_python_dev() {
    log_info "安装 Python 开发环境..."
    sudo apt install -y \
        python3 \
        python3-pip \
        python3-venv \
        python3-dev

    log_info "安装 Python 包..."
    pip3 install --user \
        pyserial \
        pycryptodome \
        requests \
        jinja2 \
        pyyaml
    log_success "Python 开发环境已安装"
}

# 安装 Repo 工具
install_repo() {
    log_info "安装 Repo 工具..."
    if command -v repo &> /dev/null; then
        log_success "Repo 已安装"
        return
    fi

    sudo apt install -y repo || {
        log_warning "通过 apt 安装 repo 失败,尝试手动安装..."
        mkdir -p ~/.bin
        curl https://storage.googleapis.com/git-repo-downloads/repo > ~/.bin/repo
        chmod a+x ~/.bin/repo

        if ! grep -q '.bin' ~/.bashrc; then
            echo 'export PATH=~/.bin:$PATH' >> ~/.bashrc
        fi

        export PATH=~/.bin:$PATH
    }

    log_success "Repo 工具已安装"
}

# 配置 Git
configure_git() {
    log_info "配置 Git..."

    if [ -z "$(git config --global user.name)" ]; then
        read -p "请输入 Git 用户名: " git_name
        git config --global user.name "$git_name"
    fi

    if [ -z "$(git config --global user.email)" ]; then
        read -p "请输入 Git 邮箱: " git_email
        git config --global user.email "$git_email"
    fi

    log_success "Git 已配置"
}

# 安装 ST 开发工具 udev 规则
install_st_udev_rules() {
    log_info "安装 ST-LINK udev 规则..."

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

    sudo udevadm control --reload-rules
    sudo udevadm trigger

    log_success "ST-LINK udev 规则已安装"
}

# 创建工作目录
create_workspace() {
    log_info "创建工作目录..."

    mkdir -p ~/STM32MPU/{optee,yocto,projects}

    log_success "工作目录已创建: ~/STM32MPU/"
}

# 显示摘要
show_summary() {
    echo ""
    echo "================================"
    log_success "开发环境安装完成!"
    echo "================================"
    echo ""
    echo "已安装组件:"
    echo "  ✓ 基础构建工具"
    echo "  ✓ ARM 交叉编译器"
    echo "  ✓ Yocto 构建依赖"
    echo "  ✓ 串口工具 (minicom, screen, picocom)"
    echo "  ✓ 网络工具 (ssh, nfs, tftp)"
    echo "  ✓ 调试工具 (gdb, openocd)"
    echo "  ✓ Python 开发环境"
    echo "  ✓ Repo 工具"
    echo "  ✓ ST-LINK udev 规则"
    echo ""
    echo "工作目录: ~/STM32MPU/"
    echo ""
    echo "下一步:"
    echo "  1. 注销并重新登录 (使 dialout 组权限生效)"
    echo "  2. 连接 STM32MP157F-DK2 开发板"
    echo "  3. 参考文档: docs/phase1-hardware-setup.md"
    echo "  4. 参考文档: docs/phase1-optee-setup.md"
    echo ""
    echo "验证安装:"
    echo "  arm-linux-gnueabihf-gcc --version"
    echo "  repo --version"
    echo "  python3 --version"
    echo ""
    log_warning "请注意: 需要注销并重新登录才能使 dialout 组权限生效"
    echo ""
}

# 主函数
main() {
    echo "========================================"
    echo " STM32MP157F-DK2 开发环境自动安装脚本"
    echo "========================================"
    echo ""

    check_sudo
    detect_os

    echo ""
    read -p "是否继续安装? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "安装已取消"
        exit 0
    fi

    update_system
    install_build_essentials
    install_arm_toolchain
    install_yocto_deps
    install_serial_tools
    install_network_tools
    install_nfs_tftp
    install_fs_tools
    install_debug_tools
    install_python_dev
    install_repo
    configure_git
    install_st_udev_rules
    create_workspace

    show_summary
}

# 运行主函数
main "$@"
