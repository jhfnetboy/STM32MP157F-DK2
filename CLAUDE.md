# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

STM32MP157F-DK2 开发环境项目,用于 AirAccount TMS (Trusted Management Service) 的硬件 TEE 实现。

**核心目标**: 将基于 Docker/QEMU 的 OP-TEE 模拟环境迁移到真实的 STM32MP157F-DK2 硬件平台,提供稳定的密钥管理服务。

### 关键背景
- 原 OP-TEE on QEMU on Docker 环境不稳定,断电后数据丢失
- 需要真实硬件存储私钥、密钥 ID 等敏感数据
- 项目为 AirAccount 公共产品的一部分,使命是 "Accounts for All"

## Architecture

项目采用分层架构:

```
Client Layer (CLI/Web/SDK)
    ↓
API Gateway (Cloudflare Tunnel + Load Balancer)
    ↓
KMS Service Layer (KMS API Server :8080, AWS Compatible)
    ↓
Core Logic Layer (Cryptographic Logic + Protocol Definitions)
    ↓
TEE Layer (KMS Host → Trusted Application → Secure Storage)
```

**开发辅助组件**:
- Mock TEE: 开发时模拟 TEE 环境
- Test Suite: API 验证
- Deployment Scripts: 自动化部署

## Development Environment

### 硬件平台
- **开发板**: STM32MP157F-DK2
- **CPU**: STM32MP157F (ARM Cortex-A7 双核 + Cortex-M4)
- **TEE**: OP-TEE OS 支持

### 参考资源
- [官方 Wiki](https://wiki.st.com/stm32mpu/wiki/Getting_started/STM32MP1_boards/STM32MP157x-DK2)
- [硬件描述](https://wiki.st.com/stm32mpu/wiki/STM32MP157x-DKx_-_hardware_description)
- [评估工具文档](https://www.st.com/en/evaluation-tools/stm32mp157f-dk2.html#documentation)
- [相关项目: AirAccount KMS](https://github.com/AAStarCommunity/AirAccount/tree/KMS)

## Code Organization

### 当前目录结构

```
STM32MP157F-DK2/
├── docs/                          # 完整项目文档
│   ├── phase1-hardware-setup.md          # Phase 1: 硬件连接手把手指南
│   ├── phase1-development-environment.md # Phase 1: Ubuntu 开发环境配置
│   ├── phase1-optee-setup.md            # Phase 1: OP-TEE 编译和 TA 开发
│   ├── phase2-industrial-hardware.md    # Phase 2: 工业硬件选型对比
│   └── phase3-architecture.md           # Phase 3: 去中心化架构设计
│
├── scripts/                       # 自动化脚本
│   ├── setup-ubuntu-dev-env.sh          # Ubuntu 开发环境一键安装
│   ├── build-optee.sh (TODO)            # OP-TEE 自动编译
│   ├── flash-sd-card.sh (TODO)          # SD 卡烧录辅助
│   └── verify-tee.sh (TODO)             # TEE 环境验证
│
├── CLAUDE.md                      # 本文件 - Claude Code 指导
├── README.md                      # 项目主页和文档导航
├── ROADMAP.md                     # 三阶段详细路线图
└── LICENSE                        # MIT 许可证
```

### 未来代码目录 (Phase 1+ 将添加)

```
├── ta/                            # Trusted Applications (OP-TEE)
│   ├── kms/                              # KMS TA 主代码
│   │   ├── include/                      # TA 头文件
│   │   ├── src/                          # TA 源码
│   │   ├── Makefile                      # TA 编译配置
│   │   └── sub.mk                        # TA 子模块配置
│   └── examples/                         # TA 示例代码
│
├── host/                          # Normal World 主机端代码
│   ├── kms-client/                       # KMS Client Library (libteec 封装)
│   ├── tests/                            # 集成测试
│   └── examples/                         # 使用示例
│
├── api/                           # KMS API Server (Go/Rust)
│   ├── server/                           # HTTP/gRPC 服务器
│   ├── handlers/                         # API 路由处理
│   ├── models/                           # 数据模型
│   └── config/                           # 配置管理
│
├── core/                          # 核心逻辑层
│   ├── crypto/                           # 加密算法封装
│   ├── policy/                           # 访问策略引擎
│   └── audit/                            # 审计日志
│
├── proto/                         # 协议定义
│   ├── tee.proto                         # TEE 通信协议 (Protobuf)
│   └── api.proto                         # API 定义
│
├── tests/                         # 测试套件
│   ├── unit/                             # 单元测试
│   ├── integration/                      # 集成测试
│   ├── performance/                      # 性能测试
│   └── security/                         # 安全测试
│
└── build/                         # 构建输出
    ├── optee/                            # OP-TEE 编译输出
    ├── images/                           # 系统镜像
    └── deploy/                           # 部署包
```

## Development Workflow

### 三阶段开发流程

参考 [ROADMAP.md](ROADMAP.md) 获取完整时间表。

#### Phase 1: 硬件迁移 (2-3 个月)

1. **硬件准备** (Week 1-2)
   - 参考: [docs/phase1-hardware-setup.md](docs/phase1-hardware-setup.md)
   - 连接开发板,验证 OP-TEE 环境

2. **开发环境** (Week 2-3)
   - 运行: `./scripts/setup-ubuntu-dev-env.sh`
   - 参考: [docs/phase1-development-environment.md](docs/phase1-development-environment.md)

3. **OP-TEE 开发** (Week 4-8)
   - 参考: [docs/phase1-optee-setup.md](docs/phase1-optee-setup.md)
   - 开发 KMS TA,实现密钥生成和签名

4. **测试验证** (Week 9-12)
   - 运行测试套件
   - 性能和稳定性验证

#### Phase 2: 工业化 (2-3 个月)

1. **硬件选型**
   - 参考: [docs/phase2-industrial-hardware.md](docs/phase2-industrial-hardware.md)
   - 推荐: Phytec phyBOARD-Sargas ($299)

2. **软件迁移**
   - 适配工业硬件
   - 重新编译和测试

3. **生产部署**
   - 单节点生产环境
   - 监控和备份

#### Phase 3: 去中心化 (6-9 个月)

1. **架构设计**
   - 参考: [docs/phase3-architecture.md](docs/phase3-architecture.md)
   - 设计 3-5 节点架构

2. **清迈部署**
   - 物理节点部署
   - 社区运营

### 常用命令

```bash
# 设置开发环境
./scripts/setup-ubuntu-dev-env.sh

# 编译 OP-TEE (Phase 1+)
# ./scripts/build-optee.sh

# 烧录 SD 卡 (Phase 1+)
# ./scripts/flash-sd-card.sh <image> <device>

# 验证 TEE 环境 (Phase 1+)
# ./scripts/verify-tee.sh
```

### 关键开发原则

1. **安全性优先**:
   - 所有密钥操作必须在 TEE 内完成
   - 私钥永不离开 Secure World
   - 使用 Secure Storage (RPMB/eMMC)

2. **硬件特性充分利用**:
   - STM32MP157F 硬件加密加速器
   - 安全启动 (Secure Boot)
   - 真随机数生成器 (TRNG)

3. **数据持久化**:
   - 确保断电后密钥数据不丢失
   - 定期备份到多个节点

4. **兼容性**:
   - API 保持 AWS KMS 兼容性
   - 支持标准的 PKCS#11 接口

5. **文档同步**:
   - 代码变更必须同步更新文档
   - 重大变更更新 ROADMAP.md

### 测试策略

1. **单元测试**: 每个 TA 函数单独测试
2. **集成测试**: CA + TA 端到端测试
3. **性能测试**: 签名 TPS,延迟测试
4. **安全测试**: 模糊测试,渗透测试
5. **稳定性测试**: 7x24 小时压力测试

## Security Considerations

- **私钥隔离**: 私钥永不离开 TEE 环境
- **安全启动**: 启用 STM32MP157F 的 Secure Boot
- **访问控制**: 实现严格的 API 认证和授权
- **审计日志**: 记录所有密钥操作

## Related Projects

- [AirAccount 主项目](https://airaccount.aastar.io)
- [Istanbul Hackathon 原型](https://ethglobal.com/showcase/airaccount-swqix)
- [AirAccount KMS 分支](https://github.com/AAStarCommunity/AirAccount/tree/KMS)
