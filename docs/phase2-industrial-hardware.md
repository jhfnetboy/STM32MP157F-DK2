# Phase 2: 工业级硬件选型对比

> 📖 **中文用户快速导航** | **Quick Navigation for Chinese Users**
> - [🎹 USB 键盘快速上手](quick-start-with-usb-keyboard.md) | [📱 Mac 开发工作流](mac-development-workflow.md) | [🔧 故障排查](troubleshooting-mac-connection.md)
> - [🔌 硬件设置](phase1-hardware-setup.md) | [🛠️ 开发环境](phase1-development-environment.md) | [🔐 OP-TEE 开发](phase1-optee-setup.md)
> - [🌐 去中心化架构](phase3-architecture.md) | [🏠 返回主页](../README.md) | [📚 所有文档](../docs/)

## 概述

本文档对比适用于去中心化 KMS 部署的工业级嵌入式硬件平台,重点关注 TEE 支持、成本效益和社区部署可行性。

**目标**: 单节点部署,预算 < $500/节点,支持 OP-TEE

## 开发板 vs 工业级产品

### 关键差异

| 特性 | 开发板 (如 STM32MP157F-DK2) | 工业级 SBC |
|------|---------------------------|-----------|
| **设计目的** | 开发、原型验证 | 长期运行、生产部署 |
| **可靠性** | 中等 | 高 (工业级元器件) |
| **温度范围** | 0°C ~ 70°C | -40°C ~ 85°C |
| **供电** | USB,不稳定 | 宽电压输入,抗干扰 |
| **机械强度** | 低 (裸板) | 高 (金属外壳,防护) |
| **寿命** | 1-3 年 | 5-10+ 年 |
| **认证** | 无 | CE, FCC, RoHS |
| **支持周期** | 短 (2-3 年) | 长 (7-10 年) |
| **价格** | $50-150 | $200-500+ |

### 何时选择工业级?

✅ **应选择工业级的场景**:
- 需要 24/7 不间断运行
- 部署在恶劣环境 (温度、湿度、振动)
- 需要长期可靠性 (5+ 年)
- 商业化产品

⚠️ **可以使用开发板的场景**:
- Phase 1: 技术验证和原型开发
- 短期测试 (<6 个月)
- 有备用设备的冗余部署

## 工业级硬件选型 (预算 < $500)

### 1. 基于 STM32MP1 的工业产品

#### 1.1 Phytec phyBOARD-Sargas

**官网**: https://www.phytec.com/product/phyboard-sargas/

**配置**:
- SoC: STM32MP157C (双核 Cortex-A7 @650MHz + Cortex-M4 @209MHz)
- RAM: 512MB DDR3L
- Storage: 4GB eMMC + microSD
- 网络: 千兆以太网
- 接口: CAN, RS232/485, USB, GPIO
- 温度: -40°C ~ 85°C

**TEE 支持**: ✅ OP-TEE 官方支持

**价格**: ~$299

**优点**:
- 工业级设计,适合长期部署
- 丰富的工业通信接口
- 良好的 OP-TEE 生态支持
- 完整的BSP 和文档

**缺点**:
- 相比开发板价格较高
- 需要采购最小起订量

#### 1.2 emtrion emSBC-Argon (STM32MP1)

**官网**: https://www.emtrion.com/

**配置**:
- SoC: STM32MP157F
- RAM: 512MB / 1GB DDR3L
- Storage: 8GB eMMC
- 网络: 千兆以太网
- 尺寸: 小型 (82mm x 50mm)
- 温度: -40°C ~ 85°C

**TEE 支持**: ✅ OP-TEE

**价格**: ~$350-400

**优点**:
- 紧凑设计
- 工业级可靠性
- 长期供货保证 (10年+)

**缺点**:
- 价格偏高
- 在亚洲采购渠道较少

### 2. 基于其他 ARM SoC 的工业 TEE 平台

#### 2.1 Toradex Colibri iMX8X

**官网**: https://www.toradex.com/computer-on-modules/colibri-arm-family/nxp-imx-8x

**配置**:
- SoC: NXP i.MX 8X (Quad Cortex-A35 @1.2GHz + Cortex-M4)
- RAM: 1GB / 2GB LPDDR4
- Storage: 4GB / 8GB / 16GB eMMC
- 网络: 千兆以太网
- TEE: NXP TrustZone + OP-TEE 支持

**价格**: ~$400-450

**优点**:
- 强大的计算能力
- 优秀的 OP-TEE 支持
- 工业级认证完整
- 全球供应链

**缺点**:
- 接近预算上限
- 功耗相对较高

#### 2.2 Variscite VAR-SOM-MX8M-NANO

**官网**: https://www.variscite.com/product/system-on-module-som/cortex-a53-krait/var-som-mx8m-nano/

**配置**:
- SoC: NXP i.MX 8M Nano (Quad Cortex-A53 @1.5GHz)
- RAM: 1GB / 2GB / 4GB LPDDR4
- Storage: 8GB / 16GB eMMC
- 网络: 千兆以太网
- TEE: OP-TEE 官方支持

**价格**: ~$89-199 (模块),完整套件 ~$300-350

**优点**:
- 性价比高
- OP-TEE 支持良好
- 丰富的外设接口

**缺点**:
- 需要定制载板 (额外成本)
- 功耗比 STM32MP1 高

### 3. 高性价比选择 (OP-TEE 参考平台)

#### 3.1 HiKey 960 / HiKey 970

**官网**: https://www.96boards.org/product/hikey960/

**配置** (HiKey 960):
- SoC: Huawei Kirin 960 (4x Cortex-A73 @2.4GHz + 4x Cortex-A53 @1.8GHz)
- RAM: 3GB LPDDR4
- Storage: 32GB UFS 2.1
- 网络: WiFi 5 + 蓝牙 4.1
- TEE: OP-TEE 官方参考平台

**价格**: ~$239 (HiKey 960), ~$299 (HiKey 970)

**优点**:
- OP-TEE 官方支持最好的平台之一
- 性能强劲
- 活跃的社区支持
- 价格适中

**缺点**:
- 非工业级 (消费级设计)
- 没有以太网 (需 USB 转接)
- 供货不稳定

#### 3.2 Raspberry Pi 4 + OP-TEE 移植

**配置**:
- SoC: Broadcom BCM2711 (Quad Cortex-A72 @1.5GHz)
- RAM: 2GB / 4GB / 8GB LPDDR4
- 网络: 千兆以太网 + WiFi 5
- Storage: microSD / USB SSD

**TEE 支持**: ⚠️ 社区移植,非官方支持

**价格**: ~$55-95 (板子) + 配件

**优点**:
- 超高性价比
- 全球可用性最强
- 庞大的社区

**缺点**:
- OP-TEE 支持不完整 (社区移植)
- 非工业级
- 安全性不如专用 TEE 平台

### 4. 专用安全硬件 (备选)

#### 4.1 Arduino Portenta X8

**官网**: https://store.arduino.cc/products/portenta-x8

**配置**:
- SoC: NXP i.MX 8M Mini (Quad Cortex-A53 @1.8GHz)
- RAM: 2GB LPDDR4
- Storage: 16GB eMMC
- 网络: WiFi 6 + 蓝牙 5.1 + 千兆以太网
- TEE: NXP EdgeLock (OP-TEE 兼容)

**价格**: ~$229

**优点**:
- Arduino 生态支持
- 良好的硬件安全特性
- 开发友好

**缺点**:
- 非传统工业级
- 以太网需扩展板

## 推荐方案

### Phase 2 推荐配置 (单节点,< $500)

#### 方案 A: 经济型 (开发验证)

**硬件**: STM32MP157F-DK2 开发板
- 成本: ~$100
- 用途: Phase 1 完成,Phase 2 初期验证
- 适用场景: 技术验证,短期测试

#### 方案 B: 平衡型 (推荐)

**硬件**: Phytec phyBOARD-Sargas
- 成本: ~$299
- 用途: Phase 2 单节点生产环境
- 适用场景: 长期运行,中等可靠性要求
- 优势: 工业级 + STM32MP1 (与开发板一致) + 良好 OP-TEE 支持

#### 方案 C: 性能型

**硬件**: Toradex Colibri iMX8X
- 成本: ~$400-450
- 用途: 高性能需求场景
- 适用场景: 需要更强计算能力,更多并发

#### 方案 D: 高性价比型 (实验性)

**硬件**: HiKey 960
- 成本: ~$239
- 用途: OP-TEE 开发和测试
- 适用场景: 社区实验,技术探索
- 风险: 供货不稳定,非工业级

## 配套硬件清单

### 单节点完整配置

以 Phytec phyBOARD-Sargas 为例:

| 项目 | 规格 | 预估成本 |
|------|------|---------|
| 主板 | phyBOARD-Sargas | $299 |
| 电源 | 12V/2A 工业电源 | $15-20 |
| 外壳 | DIN 导轨安装外壳 | $30-50 |
| 存储 | 32GB 工业级 microSD (备份) | $20 |
| 散热 | 被动散热片 + 风扇 (可选) | $10-15 |
| 网络 | 以太网线 Cat6 | $5 |
| **总计** | | **$379-409** |

### 3-5 节点配置 (Phase 3 准备)

| 配置 | 3节点 | 5节点 |
|------|-------|-------|
| 硬件成本 | ~$1,137-1,227 | ~$1,895-2,045 |
| 网络设备 | 千兆交换机 $50 | 千兆交换机 $80 |
| 机柜/机架 | 小型机柜 $100 | 标准机柜 $200 |
| UPS | 600W UPS $150 | 1000W UPS $250 |
| **总计** | **~$1,437-1,527** | **~$2,425-2,575** |

## 软件兼容性

### OP-TEE 支持矩阵

| 平台 | OP-TEE 支持 | 社区活跃度 | 文档质量 | 长期维护 |
|------|------------|-----------|---------|---------|
| STM32MP1 (Phytec) | ✅ 官方 | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ✅ 10年+ |
| i.MX 8X (Toradex) | ✅ 官方 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ✅ 10年+ |
| i.MX 8M (Variscite) | ✅ 官方 | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ✅ 7年+ |
| HiKey 960/970 | ✅ 参考平台 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⚠️ 不确定 |
| Raspberry Pi 4 | ⚠️ 社区移植 | ⭐⭐⭐ | ⭐⭐ | ❌ 无保证 |

### 从 STM32MP157F-DK2 迁移

#### 迁移到 Phytec phyBOARD-Sargas (推荐)

**兼容性**: ⭐⭐⭐⭐⭐ 最高

**原因**:
- 同样使用 STM32MP157 SoC
- 软件栈几乎完全兼容
- OP-TEE 代码无需修改
- 设备树只需微调

**迁移步骤**:
1. 使用相同的 OP-TEE 编译配置
2. 调整设备树 (DTS) 以适配 phyBOARD 硬件
3. 重新编译镜像
4. 测试验证

**预计工作量**: 1-2 周

#### 迁移到 i.MX 8X 平台

**兼容性**: ⭐⭐⭐⭐ 高

**差异**:
- 不同的 SoC (需要重新编译)
- OP-TEE API 兼容 (代码层面无需大改)
- 设备驱动需要适配

**预计工作量**: 2-4 周

## 采购渠道

### 中国大陆

- **Arrow Electronics**: https://www.arrow.cn/
- **Avnet**: https://www.avnet.com/wps/portal/apac/
- **Digi-Key** (中国): https://www.digikey.cn/
- **Mouser** (中国): https://www.mouser.cn/

### 东南亚 (泰国/清迈)

- **RS Components Thailand**: https://th.rs-online.com/
- **element14 Thailand**: https://th.element14.com/
- **Mouser (海运)**: https://www.mouser.com/ (需付国际运费)

### 直接从厂商

- **Phytec**: sales@phytec.com
- **Toradex**: https://www.toradex.com/contact
- **Variscite**: https://www.variscite.com/contact/

## 可靠性和维护

### 预期寿命

| 平台类型 | MTBF | 预期寿命 | 备件策略 |
|---------|------|---------|---------|
| 开发板 | ~20,000h | 1-3年 | 提前采购备件 |
| 工业 SBC | ~100,000h+ | 5-10年 | 厂商长期供货 |

### 冗余和备份

对于 Phase 3 的 3-5 节点部署:

1. **主备模式 (3节点)**:
   - 1 个主节点,2 个热备
   - 自动故障切换

2. **负载均衡 (5节点)**:
   - 5 节点同时工作
   - 任意 2 节点故障仍可服务

## 总结和建议

### Phase 2 首选方案

**Phytec phyBOARD-Sargas ($299)**

**理由**:
1. 与 Phase 1 (STM32MP157F-DK2) 软件完全兼容
2. 工业级可靠性
3. 长期供货保证
4. 价格在预算内
5. 良好的 OP-TEE 生态

### 替代方案

如预算紧张:
- **短期**: 继续使用 STM32MP157F-DK2 + 冗余备份
- **长期**: 等待更多 STM32MP1 工业板上市

如需要更高性能:
- **Toradex Colibri iMX8X** ($400-450)
- 或等待 Phase 3 评估更高端方案

## 下一步

- [Phase 2: 单节点部署指南](phase2-deployment-guide.md) - 详细部署流程
- [Phase 3: 架构设计](phase3-architecture.md) - 多节点集群设计

## 参考资源

- [Embedded Computing Design - Industrial SBC Guide](https://embeddedcomputing.com/)
- [OP-TEE Supported Platforms](https://optee.readthedocs.io/en/latest/general/platforms.html)
- [96Boards Hardware](https://www.96boards.org/)
