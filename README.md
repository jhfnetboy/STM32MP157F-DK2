# STM32MP157F-DK2
My poor dev experience on ARM chips with TEE for AirAccount TMS

## Background
We select this as our dev env for our AirAccount TMS:
<img src="https://raw.githubusercontent.com/jhfnetboy/MarkDownImg/main/img/202511161401453.png" alignment="left" />
More info at here: [KMS](https://github.com/AAStarCommunity/AirAccount/tree/KMS)

```mermaid
graph TB
    subgraph "Client Layer"
        CLI[CLI Tools]
        WebApp[Web Applications]
        SDK[Language SDKs]
    end

    subgraph "API Gateway"
        CF[Cloudflare Tunnel<br/>HTTPS Proxy]
        LB[Load Balancer<br/>Rate Limiting]
    end

    subgraph "KMS Service Layer"
        API[KMS API Server<br/>:8080<br/>AWS Compatible]
        Health[Health Monitor<br/>Service Status]
    end

    subgraph "Core Logic Layer"
        Core[KMS Core<br/>Cryptographic Logic]
        Proto[Protocol Definitions<br/>TEE Communication]
    end

    subgraph "TEE Layer (Secure)"
        Host[KMS Host<br/>TEE Interface]
        TA[Trusted Application<br/>Key Operations]
        Storage[Secure Storage<br/>Private Keys]
    end

    subgraph "Testing & Tools"
        MockTEE[Mock TEE<br/>Development]
        Tests[Test Suite<br/>API Validation]
        Scripts[Deployment Scripts<br/>Automation]
    end

    %% Connections
    CLI --> CF
    WebApp --> CF
    SDK --> CF
    CF --> LB
    LB --> API
    API --> Health
    API --> Core
    Core --> Proto
    Proto --> Host
    Host --> TA
    TA --> Storage

    %% Development connections
    Core -.-> MockTEE
    Tests -.-> API
    Scripts -.-> API

    %% Styling
    classDef secure fill:#ff6b6b,stroke:#333,stroke-width:3px
    classDef api fill:#4ecdc4,stroke:#333,stroke-width:2px
    classDef tool fill:#45b7d1,stroke:#333,stroke-width:1px

    class TA,Storage,Host secure
    class API,CF,LB api
    class Tests,Scripts,MockTEE tool
```

## Resources

AI
https://www.bilibili.com/video/BV111y8BuELC/?spm_id_from=333.1387.homepage.video_card.click&vd_source=0a978d5cb963890b0cab49f66fae30af

官方B站：
https://space.bilibili.com/2100019006?from=search&seid=6727742697039098458&spm_id_from=333.337.0.0
st中国
https://www.stmcu.com.cn/Designresource/list/STM32%20MCU/firmware_software/software
官方论坛：
https://shequ.stmicroelectronics.cn/thread-636531-1-1.html

wiki：
https://wiki.st.com/stm32mpu/wiki/STM32MP157x-DKx_-_hardware_description
https://wiki.st.com/stm32mpu/wiki/Getting_started/STM32MP1_boards/STM32MP157x-DK2%20

官方文档：
https://www.st.com/resource/en/user_manual/um2909-getting-started-with-xlinuxgnss1-package-for-developing-gnss-applications-on-linux-os-stmicroelectronics.pdf

工具:
https://www.st.com/en/evaluation-tools/stm32mp157f-dk2.html#documentation

