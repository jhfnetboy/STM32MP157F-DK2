# Phase 1: OP-TEE 开发环境搭建

> 📖 **中文用户快速导航** | **Quick Navigation for Chinese Users**
> - [🎹 USB 键盘快速上手](quick-start-with-usb-keyboard.md) | [📱 Mac 开发工作流](mac-development-workflow.md) | [🔧 故障排查](troubleshooting-mac-connection.md)
> - [🔌 硬件设置](phase1-hardware-setup.md) | [🛠️ 开发环境](phase1-development-environment.md) | [🏭 工业硬件](phase2-industrial-hardware.md)
> - [🏠 返回主页](../README.md) | [📚 所有文档](../docs/)

## 概述

本文档详细说明如何在 STM32MP157F-DK2 上配置和开发 OP-TEE (Open Portable Trusted Execution Environment),这是 AirAccount KMS 项目的核心安全组件。

## 什么是 OP-TEE?

OP-TEE 是一个开源的 Trusted Execution Environment (TEE) 实现,符合 ARM TrustZone 技术和 GlobalPlatform TEE 规范。

### 核心概念

- **Secure World (安全世界)**: 运行可信代码,保护敏感数据
- **Normal World (普通世界)**: 运行常规操作系统 (Linux)
- **Trusted Application (TA)**: 运行在 Secure World 的应用
- **Client Application (CA)**: 运行在 Normal World,调用 TA 的应用

```
┌─────────────────────────────────────────┐
│         Normal World (Linux)            │
│  ┌────────────────────────────────┐    │
│  │   Client Application (CA)      │    │
│  │   - KMS API Server             │    │
│  │   - User Applications          │    │
│  └────────────┬───────────────────┘    │
│               │ TEE Client API          │
│  ┌────────────▼───────────────────┐    │
│  │   libteec (TEE Client Lib)     │    │
│  └────────────┬───────────────────┘    │
└───────────────┼─────────────────────────┘
                │ SMC (Secure Monitor Call)
┌───────────────▼─────────────────────────┐
│         Secure World (OP-TEE)           │
│  ┌────────────────────────────────┐    │
│  │   Trusted Application (TA)     │    │
│  │   - Key Management             │    │
│  │   - Crypto Operations          │    │
│  │   - Secure Storage             │    │
│  └────────────┬───────────────────┘    │
│  ┌────────────▼───────────────────┐    │
│  │   OP-TEE OS Core               │    │
│  │   - Scheduler                  │    │
│  │   - Memory Management          │    │
│  │   - Crypto API                 │    │
│  └────────────────────────────────┘    │
└─────────────────────────────────────────┘
```

## 准备工作

### 前置条件

- 已完成 [硬件连接](phase1-hardware-setup.md)
- 已完成 [开发环境配置](phase1-development-environment.md)
- 磁盘空间 ≥30GB
- 内存 ≥8GB

### 所需工具

确保已安装:
```bash
# 验证工具
which arm-linux-gnueabihf-gcc
which python3
which git
which repo
```

## 方法 1: 使用预编译镜像 (快速开始)

### 下载官方镜像

```bash
# 创建工作目录
mkdir -p ~/STM32MPU/optee
cd ~/STM32MPU/optee

# 下载包含 OP-TEE 的官方镜像
# 访问: https://www.st.com/en/embedded-software/stm32mp1starter.html
# 选择: OpenSTLinux Starter Package
# 下载: st-image-weston-openstlinux-weston-stm32mp1.wic.bz2

# 解压
bunzip2 st-image-weston-openstlinux-weston-stm32mp1.wic.bz2
```

### 烧录到 SD 卡

```bash
# 查看 SD 卡设备名
lsblk

# 烧录 (假设 SD 卡是 /dev/sdX)
sudo dd if=st-image-weston-openstlinux-weston-stm32mp1.wic \
        of=/dev/sdX \
        bs=4M \
        conv=fsync \
        status=progress

# 或使用我们提供的脚本
cd ~/Dev/crypto-projects/STM32MP157F-DK2
sudo ./scripts/flash-sd-card.sh st-image-weston-openstlinux-weston-stm32mp1.wic /dev/sdX
```

### 验证 OP-TEE

```bash
# 在开发板上启动后
ssh root@<board-ip>

# 检查 OP-TEE 设备
ls -la /dev/tee*

# 预期输出:
# crw------- 1 root root 10, 223 Jan  1  1970 /dev/tee0
# crw------- 1 root root 10, 224 Jan  1  1970 /dev/teepriv0

# 检查 TEE supplicant
ps aux | grep tee-supplicant

# 运行 OP-TEE 测试
xtest
```

## 方法 2: 从源码编译 OP-TEE (完整开发)

### 步骤 1: 获取 OP-TEE 源码

#### 使用 Repo 工具同步

```bash
# 创建工作目录
mkdir -p ~/optee-stm32mp1
cd ~/optee-stm32mp1

# 初始化 Repo (使用 ST 官方 manifest)
repo init -u https://github.com/STMicroelectronics/optee-manifest.git \
          -b refs/tags/openstlinux-5.15-yocto-kirkstone-mp1-v22.11.23 \
          -m stm32mp1.xml

# 同步代码 (需要一些时间,约 5-10GB)
repo sync -j$(nproc)
```

#### 或使用 Git 手动克隆 (精简方式)

```bash
mkdir -p ~/optee-stm32mp1
cd ~/optee-stm32mp1

# 克隆核心组件
git clone https://github.com/OP-TEE/optee_os.git
git clone https://github.com/OP-TEE/optee_client.git
git clone https://github.com/OP-TEE/optee_test.git
git clone https://github.com/linaro-swg/optee_examples.git

# 切换到稳定分支
cd optee_os && git checkout 3.20.0 && cd ..
cd optee_client && git checkout 3.20.0 && cd ..
cd optee_test && git checkout 3.20.0 && cd ..
```

### 步骤 2: 配置构建环境

```bash
# 设置交叉编译器
export CROSS_COMPILE=arm-linux-gnueabihf-
export CROSS_COMPILE_core=arm-linux-gnueabihf-
export CROSS_COMPILE_ta_arm32=arm-linux-gnueabihf-

# 设置平台
export PLATFORM=stm32mp1
export PLATFORM_FLAVOR=157F_DK2

# 设置核心数
export CFG_TEE_CORE_NB_CORE=2

# 可选: 启用调试
export CFG_TEE_CORE_LOG_LEVEL=4
export CFG_TEE_TA_LOG_LEVEL=4
```

### 步骤 3: 编译 OP-TEE OS

```bash
cd ~/optee-stm32mp1/optee_os

# 编译
make PLATFORM=stm32mp1 \
     PLATFORM_FLAVOR=157F_DK2 \
     CFG_TEE_CORE_NB_CORE=2 \
     CFG_EMBED_DTB_SOURCE_FILE=stm32mp157f-dk2.dts \
     -j$(nproc)

# 编译成功后会生成
# out/arm-plat-stm32mp1/core/tee-header_v2.bin
# out/arm-plat-stm32mp1/core/tee-pageable_v2.bin
# out/arm-plat-stm32mp1/core/tee-pager_v2.bin
```

### 步骤 4: 编译 OP-TEE Client

```bash
cd ~/optee-stm32mp1/optee_client

# 配置
mkdir -p build
cd build

cmake -DCMAKE_C_COMPILER=arm-linux-gnueabihf-gcc \
      -DCMAKE_INSTALL_PREFIX=/usr \
      ..

# 编译
make -j$(nproc)

# 打包
make DESTDIR=./install install

# 生成的库和工具在 install/ 目录
ls -la install/usr/lib/
ls -la install/usr/bin/
```

### 步骤 5: 编译 OP-TEE 测试套件

```bash
cd ~/optee-stm32mp1/optee_test

# 编译 Host 端测试程序
export TA_DEV_KIT_DIR=~/optee-stm32mp1/optee_os/out/arm-plat-stm32mp1/export-ta_arm32
export TEEC_EXPORT=~/optee-stm32mp1/optee_client/out/export/usr
export CROSS_COMPILE_HOST=arm-linux-gnueabihf-
export CROSS_COMPILE_TA=arm-linux-gnueabihf-

make \
    CROSS_COMPILE_HOST=$CROSS_COMPILE_HOST \
    CROSS_COMPILE_TA=$CROSS_COMPILE_TA \
    TA_DEV_KIT_DIR=$TA_DEV_KIT_DIR \
    -j$(nproc)

# 生成 xtest 可执行文件和 TA
ls -la out/xtest/xtest
ls -la out/ta/*.ta
```

### 步骤 6: 部署到开发板

#### 6.1 准备文件系统

```bash
# 挂载 SD 卡的 rootfs 分区 (假设是 /dev/sdX2)
sudo mkdir -p /mnt/sdcard
sudo mount /dev/sdX2 /mnt/sdcard
```

#### 6.2 安装 OP-TEE Client

```bash
# 复制库文件
sudo cp ~/optee-stm32mp1/optee_client/build/install/usr/lib/* \
        /mnt/sdcard/usr/lib/

# 复制可执行文件
sudo cp ~/optee-stm32mp1/optee_client/build/install/usr/bin/* \
        /mnt/sdcard/usr/bin/

# 创建 TA 目录
sudo mkdir -p /mnt/sdcard/lib/optee_armtz
```

#### 6.3 安装测试 TA

```bash
# 复制测试 TA
sudo cp ~/optee-stm32mp1/optee_test/out/ta/*.ta \
        /mnt/sdcard/lib/optee_armtz/

# 复制 xtest
sudo cp ~/optee-stm32mp1/optee_test/out/xtest/xtest \
        /mnt/sdcard/usr/bin/
```

#### 6.4 卸载并启动

```bash
# 同步并卸载
sudo sync
sudo umount /mnt/sdcard

# 将 SD 卡插入开发板并启动
```

### 步骤 7: 验证安装

在开发板上:

```bash
# 检查 TEE 设备
ls -la /dev/tee*

# 检查库
ls -la /usr/lib/libteec*

# 运行测试
xtest

# 预期输出大量测试结果,应全部通过
# +-----------------------------------------------------
# + 25000+ test cases
# +-----------------------------------------------------
# Result of testsuite regression:
# <number> subtests of which <small_number> failed
```

## 开发自定义 Trusted Application

### Hello World TA 示例

#### 步骤 1: 创建 TA 项目

```bash
mkdir -p ~/my-ta/hello_world
cd ~/my-ta/hello_world
```

#### 步骤 2: 编写 TA 代码

创建 `hello_world_ta.c`:

```c
#include <tee_internal_api.h>
#include <tee_internal_api_extensions.h>
#include <hello_world_ta.h>

/*
 * Called when the instance of the TA is created
 */
TEE_Result TA_CreateEntryPoint(void)
{
    DMSG("TA_CreateEntryPoint: Hello World TA is created!");
    return TEE_SUCCESS;
}

/*
 * Called when the instance of the TA is destroyed
 */
void TA_DestroyEntryPoint(void)
{
    DMSG("TA_DestroyEntryPoint: Goodbye!");
}

/*
 * Called when a new session is opened to the TA
 */
TEE_Result TA_OpenSessionEntryPoint(uint32_t param_types,
                                     TEE_Param __unused params[4],
                                     void __unused **sess_ctx)
{
    uint32_t exp_param_types = TEE_PARAM_TYPES(TEE_PARAM_TYPE_NONE,
                                               TEE_PARAM_TYPE_NONE,
                                                TEE_PARAM_TYPE_NONE,
                                                TEE_PARAM_TYPE_NONE);

    DMSG("TA_OpenSessionEntryPoint: Session opened");

    if (param_types != exp_param_types)
        return TEE_ERROR_BAD_PARAMETERS;

    return TEE_SUCCESS;
}

/*
 * Called when a session is closed
 */
void TA_CloseSessionEntryPoint(void __unused *sess_ctx)
{
    DMSG("TA_CloseSessionEntryPoint: Session closed");
}

/*
 * Called when a TA is invoked
 */
TEE_Result TA_InvokeCommandEntryPoint(void __unused *sess_ctx,
                                       uint32_t cmd_id,
                                       uint32_t param_types,
                                       TEE_Param params[4])
{
    (void)&sess_ctx;

    switch (cmd_id) {
    case TA_HELLO_WORLD_CMD_INC_VALUE:
        return inc_value(param_types, params);
    default:
        return TEE_ERROR_BAD_PARAMETERS;
    }
}

static TEE_Result inc_value(uint32_t param_types, TEE_Param params[4])
{
    uint32_t exp_param_types = TEE_PARAM_TYPES(TEE_PARAM_TYPE_VALUE_INOUT,
                                               TEE_PARAM_TYPE_NONE,
                                               TEE_PARAM_TYPE_NONE,
                                               TEE_PARAM_TYPE_NONE);

    if (param_types != exp_param_types)
        return TEE_ERROR_BAD_PARAMETERS;

    DMSG("Got value: %u from NW", params[0].value.a);
    params[0].value.a++;
    DMSG("Increase value to: %u", params[0].value.a);

    return TEE_SUCCESS;
}
```

创建 `hello_world_ta.h`:

```c
#ifndef HELLO_WORLD_TA_H
#define HELLO_WORLD_TA_H

/* UUID of the TA */
#define TA_HELLO_WORLD_UUID \
    { 0x8aaaf200, 0x2450, 0x11e4, \
        { 0xab, 0xe2, 0x00, 0x02, 0xa5, 0xd5, 0xc5, 0x1b} }

/* Command IDs */
#define TA_HELLO_WORLD_CMD_INC_VALUE 0

#endif /* HELLO_WORLD_TA_H */
```

创建 `sub.mk`:

```makefile
global-incdirs-y += include
srcs-y += hello_world_ta.c

# Optional: enable debugging
CFG_TEE_TA_LOG_LEVEL ?= 4
```

创建 `Makefile`:

```makefile
export V ?= 0

TA_DEV_KIT_DIR ?= $(HOME)/optee-stm32mp1/optee_os/out/arm-plat-stm32mp1/export-ta_arm32

BINARY = 8aaaf200-2450-11e4-abe2-0002a5d5c51b

include $(TA_DEV_KIT_DIR)/mk/ta_dev_kit.mk
```

#### 步骤 3: 编译 TA

```bash
cd ~/my-ta/hello_world
make CROSS_COMPILE=arm-linux-gnueabihf-

# 生成 TA
ls -la 8aaaf200-2450-11e4-abe2-0002a5d5c51b.ta
```

#### 步骤 4: 编写 Client Application

创建 `hello_world_ca.c`:

```c
#include <stdio.h>
#include <tee_client_api.h>
#include "hello_world_ta.h"

int main(void)
{
    TEEC_Result res;
    TEEC_Context ctx;
    TEEC_Session sess;
    TEEC_Operation op;
    TEEC_UUID uuid = TA_HELLO_WORLD_UUID;
    uint32_t err_origin;

    /* Initialize context */
    res = TEEC_InitializeContext(NULL, &ctx);
    if (res != TEEC_SUCCESS) {
        fprintf(stderr, "TEEC_InitializeContext failed with code 0x%x\n", res);
        return 1;
    }

    /* Open session */
    res = TEEC_OpenSession(&ctx, &sess, &uuid,
                           TEEC_LOGIN_PUBLIC, NULL, NULL, &err_origin);
    if (res != TEEC_SUCCESS) {
        fprintf(stderr, "TEEC_OpenSession failed with code 0x%x origin 0x%x\n",
                res, err_origin);
        TEEC_FinalizeContext(&ctx);
        return 1;
    }

    /* Prepare operation */
    memset(&op, 0, sizeof(op));
    op.paramTypes = TEEC_PARAM_TYPES(TEEC_VALUE_INOUT, TEEC_NONE,
                                     TEEC_NONE, TEEC_NONE);
    op.params[0].value.a = 42;

    /* Invoke command */
    printf("Invoking TA with value %d\n", op.params[0].value.a);
    res = TEEC_InvokeCommand(&sess, TA_HELLO_WORLD_CMD_INC_VALUE,
                             &op, &err_origin);
    if (res != TEEC_SUCCESS) {
        fprintf(stderr, "TEEC_InvokeCommand failed with code 0x%x origin 0x%x\n",
                res, err_origin);
    } else {
        printf("TA incremented value to %d\n", op.params[0].value.a);
    }

    /* Cleanup */
    TEEC_CloseSession(&sess);
    TEEC_FinalizeContext(&ctx);

    return 0;
}
```

编译 CA:

```bash
arm-linux-gnueabihf-gcc -o hello_world_ca hello_world_ca.c \
    -I~/optee-stm32mp1/optee_client/public \
    -L~/optee-stm32mp1/optee_client/build/install/usr/lib \
    -lteec
```

#### 步骤 5: 部署和运行

```bash
# 复制 TA 到开发板
scp 8aaaf200-2450-11e4-abe2-0002a5d5c51b.ta root@<board-ip>:/lib/optee_armtz/

# 复制 CA 到开发板
scp hello_world_ca root@<board-ip>:/usr/bin/

# 在开发板上运行
ssh root@<board-ip>
hello_world_ca

# 预期输出:
# Invoking TA with value 42
# TA incremented value to 43
```

## 调试 OP-TEE

### 查看 TEE 日志

```bash
# 在开发板串口查看 TEE 日志
dmesg | grep -i tee
dmesg | grep -i optee

# 或实时监控
dmesg -w | grep -i tee
```

### 启用详细调试日志

重新编译 OP-TEE OS 时:

```bash
make PLATFORM=stm32mp1 \
     CFG_TEE_CORE_LOG_LEVEL=4 \
     CFG_TEE_TA_LOG_LEVEL=4 \
     -j$(nproc)
```

日志级别:
- 0 = No output
- 1 = Error
- 2 = Info
- 3 = Debug
- 4 = Trace (最详细)

### 使用 GDB 调试

```bash
# 在 PC 上启动 GDB server (通过 OpenOCD)
openocd -f board/stm32mp15x_dk2.cfg

# 在另一个终端启动 GDB
gdb-multiarch ~/optee-stm32mp1/optee_os/out/arm-plat-stm32mp1/core/tee.elf

# 在 GDB 中连接
(gdb) target remote localhost:3333
(gdb) load
(gdb) continue
```

## 下一步

- [Phase 1: 故障排查](phase1-troubleshooting.md) - 解决常见 OP-TEE 问题
- [Phase 2: 工业硬件选型](phase2-industrial-hardware.md) - 探索工业级部署方案
- 开始开发 AirAccount KMS 的 Trusted Application

## 参考资源

- [OP-TEE 官方文档](https://optee.readthedocs.io/)
- [OP-TEE on STM32MP1](https://wiki.st.com/stm32mpu/wiki/OP-TEE_overview)
- [GlobalPlatform TEE 规范](https://globalplatform.org/specs-library/tee-internal-core-api-specification/)
- [OP-TEE GitHub](https://github.com/OP-TEE)
- [OP-TEE 示例代码](https://github.com/linaro-swg/optee_examples)
