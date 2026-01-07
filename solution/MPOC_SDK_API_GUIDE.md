# SUNBAY MPoC SDK API 交互指南

**版本**: v2.8  
**日期**: 2024-12-31  
**适用对象**: Android MPoC SDK 开发者

---

## 目录

1. [概述](#1-概述)
2. [系统架构](#2-系统架构)
3. [SDK 模块职责](#3-sdk-模块职责)
4. [初始化流程总览](#4-初始化流程总览)
5. [阶段一：设备注册](#5-阶段一设备注册)
6. [阶段二：证书签发](#6-阶段二证书签发)
7. [阶段三：密钥初始化](#7-阶段三密钥初始化)
8. [阶段四：交易处理](#8-阶段四交易处理)
9. [PIN 加密方案](#9-pin-加密方案)
10. [SDK 版本管理](#10-sdk-版本管理)
11. [错误处理](#11-错误处理)
12. [安全规范](#12-安全规范)
13. [附录](#13-附录)

---

## 1. 概述

### 1.1 文档目的

本文档描述 SUNBAY MPoC (Mobile Point of Contact) SDK 与后端服务的 API 交互规范，按照 **SDK 初始化调用顺序** 组织内容，为 Android 端开发者提供完整的集成指南。

### 1.2 MPoC SDK 简介

MPoC SDK 以 **AAR (Android Archive)** 形式提供，将 Android 智能手机转变为符合 PCI 标准的支付终端。

**集成方式**: App 通过 Gradle 依赖引入 SDK，使用函数调用方式进行交互。

```groovy
// Gradle 依赖
implementation 'com.sunbay:mpoc-sdk:1.0.0'
```

| 特性 | 说明 |
|------|------|
| **PIN 加密** | 支持 DUKPT (SE/TEE) 和 WhiteBox DH-ECC 两种方案 |
| **安全检测** | 实时检测 Root、模拟器、Hook 等威胁 |
| **交易处理** | 支持消费、退款、撤销、预授权等交易类型 |
| **合规认证** | 符合 PCI-DSS、PCI PIN 安全标准 |

### 1.3 服务器信息

| 环境 | 地址 | 用途 |
|------|------|------|
| 开发环境 | `http://localhost:8080` | 本地开发测试 |
| 生产环境 | `http://softpos.sunbay.dev` | A/M-Backend 生产部署 |
| POSP | `https://<posp-host>` | 交易处理 (App 直接提交) |
| RKI HSM | `https://<rki-hsm-host>` | 密钥管理 (DUKPT 模式) |

**API Base Path**: 
- A/M-Backend: `MPoC/api`
- POSP: `/POSP/api`

---

## 2. 系统架构

### 2.1 通信关系图

```mermaid
flowchart TB
    subgraph "客户端"
        App[📱 Android App]
        SDK[🛡️ MPoC SDK<br/>AAR Library]
    end
    
    subgraph "服务端"
        Backend[🖥️ A/M-Backend]
        POSP[🏦 SUNBAY POSP]
        HSM[🔐 RKI CloudHSM]
    end
    
    subgraph "外部"
        Processor[💳 Processor<br/>TSYS/Fiserv/Elavon]
    end
    
    App -->|"① 函数调用"| SDK
    SDK -->|"② REST API<br/>(注册/证书/密钥)"| Backend
    SDK -->|"③ DUKPT 密钥下载"| HSM
    Backend -.->|HTTPS 推送| SDK
    Backend -->|CA 签发| HSM
    
    SDK -->|"④ 交易鉴证 Token"| Backend
    App -->|"⑤ 交易提交<br/>(加密PIN)"| POSP
    POSP -->|"⑥ PIN 转加密"| HSM
    POSP -->|"⑦ 交易路由"| Processor
    
    style App fill:#e3f2fd,stroke:#1976d2
    style SDK fill:#fff8e1,stroke:#e65100
    style Backend fill:#e8f5e9,stroke:#388e3c
    style POSP fill:#fce4ec,stroke:#c2185b
    style HSM fill:#fff8e1,stroke:#ffa000
    style Processor fill:#f3e5f5,stroke:#7b1fa2
```

**处理顺序说明**:
1. **① 函数调用**: App 调用 SDK 接口
2. **② 初始化**: SDK 完成设备注册、证书签发、密钥初始化
3. **③ 密钥下载**: DUKPT 模式下 SDK 直连 HSM 下载密钥
4. **④ 交易鉴证**: 交易前 SDK 向 Backend 获取 Transaction Token
5. **⑤ 交易提交**: App 携带加密 PIN Block 提交到 POSP
6. **⑥ PIN 转加密**: POSP 在 HSM 内完成 PIN 转加密
7. **⑦ 交易路由**: POSP 将交易发送到 Processor

### 2.2 API 端点总览

#### 2.2.1 MPoC SDK → A/M-Backend

| 阶段 | API | 端点 | 方法 |
|------|-----|------|------|
| 设备注册 | 注册设备 | `MPoC/api/devices/register` | POST |
| 证书签发 | CSR 签发 | `MPoC/api/certificates/sign` | POST |
| ECC密钥交换 | ECC 密钥交换 | `MPoC/api/keys/ecc/exchange` | POST |
| 安全监控 | 威胁上报 | `MPoC/api/threats/report` | POST |
| 交易处理 | 交易鉴证 | `MPoC/api/transactions/attest` | POST |
| 版本管理 | SDK 版本检查 | `MPoC/api/sdk/version/check` | POST |

#### 2.2.2 MPoC SDK → RKI CloudHSM

| 阶段 | API | 端点 | 方法 |
|------|-----|------|------|
| DUKPT密钥初始化 | DUKPT 密钥下载 | `/RKI/api/v1/keys/download` | POST |
| DUKPT密钥锁定 | DUKPT 密钥锁定 | `/RKI/api/v1/keys/confirm` | POST |

#### 2.2.3 A/M-Backend → MPoC SDK (HTTPS)

| 通知类型 | 触发时机 |
|---------|---------|
| `KEY_DOWNLOAD_REQUIRED` | 设备审批通过后 |
| `CERT_RENEWAL_REQUIRED` | 证书即将过期 |
| `THREAT_ALERT` | 检测到安全威胁 |

#### 2.2.4 A/M-Backend → RKI CloudHSM (内部)

| API | 端点 | 用途 |
|-----|------|------|
| CA 证书签发 | `/RKI/api/v1/ca/sign` | CSR 证书签发 |

#### 2.2.5 Android App → SUNBAY POSP

| API | 端点 | 方法 | 说明 |
|-----|------|------|------|
| 交易提交 | `/POSP/api/transactions` | POST | App 直接提交交易到 POSP |

---

## 3. SDK 模块职责

MPoC SDK 内部按职责划分为以下模块：

```mermaid
graph TB
    subgraph "MPoC SDK 模块架构"
        subgraph "阶段一: 设备注册"
            DM[DeviceManager<br/>设备注册/状态管理]
            SC[SecurityChecker<br/>安全环境检测]
        end
        
        subgraph "阶段二: 证书签发"
            CM[CertManager<br/>CSR生成/证书管理]
        end
        
        subgraph "阶段三: 密钥初始化"
            KM[KeyManager<br/>DUKPT密钥下载]
            WB[WhiteBoxEngine<br/>DH-ECC密钥交换]
        end
        
        subgraph "阶段四: 交易处理"
            CE[CryptoEngine<br/>PIN加密]
            TM[TokenManager<br/>交易令牌]
            TP[TransactionProcessor<br/>交易处理]
        end
        
        subgraph "基础设施"
            BA[BackendApi<br/>HTTP/HTTPS通信]
        end
    end
    
    DM --> CM
    CM --> KM
    CM --> WB
    KM --> CE
    WB --> CE
    CE --> TM
    TM --> TP
    
    style DM fill:#e3f2fd,stroke:#1976d2
    style SC fill:#e3f2fd,stroke:#1976d2
    style CM fill:#fff8e1,stroke:#e65100
    style KM fill:#e8f5e9,stroke:#388e3c
    style WB fill:#e8f5e9,stroke:#388e3c
    style CE fill:#fce4ec,stroke:#c2185b
    style TM fill:#fce4ec,stroke:#c2185b
    style TP fill:#fce4ec,stroke:#c2185b
```

### 3.1 模块职责说明

| 模块 | 职责 | 主要接口 | 调用阶段 |
|------|------|---------|---------|
| **DeviceManager** | 设备注册、状态查询、TEE 类型检测 | `registerDevice()`, `getDeviceStatus()` | 阶段一 |
| **SecurityChecker** | Root/模拟器/Hook 检测、威胁上报 | `checkSecurity()`, `reportThreat()` | 阶段一 |
| **CertManager** | ECC 密钥对生成、CSR 创建、证书存储 | `generateKeyPair()`, `submitCsr()` | 阶段二 |
| **KeyManager** | DUKPT 密钥下载、KSN 管理 | `downloadKey()`, `confirmDownload()` | 阶段三 (SE/TEE) |
| **WhiteBoxEngine** | DH-ECC 协商、会话密钥派生 | `initKeyExchange()`, `deriveSessionKey()` | 阶段三 (WhiteBox) |
| **CryptoEngine** | PIN Block 生成、加密 (支持 SE/TEE/WhiteBox) | `encryptPin()`, `getTeeType()` | 阶段四 |
| **TokenManager** | 交易令牌申请、有效期管理 | `requestToken()`, `validateToken()` | 阶段四 |
| **TransactionProcessor** | 交易鉴证、Token 管理 | `attestTransaction()` | 阶段四 |
| **BackendApi** | HTTP/TLS 1.3 通信、HTTPS 连接 | (内部模块) | 全阶段 |

---

## 4. 初始化流程总览

SDK 初始化按以下顺序执行，每个阶段必须成功完成后才能进入下一阶段：

```mermaid
flowchart TB
    subgraph "阶段一: 设备注册"
        A1[1.1 安全环境检测] --> A2[1.2 设备注册]
        A2 --> A3[1.3 建立 HTTPS 连接]
    end
    
    subgraph "阶段二: 证书签发"
        B1[2.1 生成 ECC 密钥对] --> B2[2.2 提交 CSR]
        B2 --> B3[2.3 存储证书]
    end
    
    subgraph "阶段三: 密钥初始化"
        C1{TEE 类型?}
        C1 -->|SE/TEE| C2[3.1a DUKPT 密钥下载]
        C1 -->|WhiteBox| C3[3.1b ECC 密钥交换]
        C2 --> C4[3.2a 存储到 TEE/SE]
        C3 --> C5[3.2b 派生会话密钥]
        C4 --> C6[密钥就绪]
        C5 --> C6
    end
    
    subgraph "阶段四: 交易处理"
        D1[4.1 交易鉴证] --> D2[4.2 PIN 加密]
        D2 --> D3[4.3 交易提交]
    end
    
    A3 --> B1
    B3 --> C1
    C6 --> D1
    
    style A1 fill:#e3f2fd,stroke:#1976d2
    style A2 fill:#e3f2fd,stroke:#1976d2
    style A3 fill:#e3f2fd,stroke:#1976d2
    style B1 fill:#fff8e1,stroke:#e65100
    style B2 fill:#fff8e1,stroke:#e65100
    style B3 fill:#fff8e1,stroke:#e65100
    style C1 fill:#e8f5e9,stroke:#388e3c
    style C2 fill:#e8f5e9,stroke:#388e3c
    style C3 fill:#e8f5e9,stroke:#388e3c
    style C4 fill:#e8f5e9,stroke:#388e3c
    style C5 fill:#e8f5e9,stroke:#388e3c
    style C6 fill:#e8f5e9,stroke:#388e3c
    style D1 fill:#fce4ec,stroke:#c2185b
    style D2 fill:#fce4ec,stroke:#c2185b
    style D3 fill:#fce4ec,stroke:#c2185b
```

### 4.1 初始化状态机

```mermaid
stateDiagram-v2
    [*] --> 未初始化
    未初始化 --> 安全检测中: initialize()
    安全检测中 --> 安全检测失败: 检测到威胁
    安全检测中 --> 设备注册中: 检测通过
    
    设备注册中 --> 注册失败: 网络错误/拒绝
    设备注册中 --> 等待审批: 注册成功
    
    等待审批 --> 证书签发中: 审批通过
    等待审批 --> 设备禁用: 审批拒绝
    
    证书签发中 --> 签发失败: CSR 错误
    证书签发中 --> 密钥初始化中: 证书获取成功
    
    密钥初始化中 --> 初始化失败: 密钥下载/交换失败
    密钥初始化中 --> 就绪: 密钥就绪
    
    就绪 --> 交易中: 发起交易
    交易中 --> 就绪: 交易完成
    
    就绪 --> 会话过期: WhiteBox 会话超时
    会话过期 --> 密钥初始化中: 重新交换
```

### 4.2 TEE 类型说明

SDK 根据设备硬件能力自动检测 TEE 类型，不同类型决定后续密钥初始化方式：

| TEE 类型 | 说明 | 安全级别 | 密钥初始化方式 | 密钥存储位置 |
|----------|------|---------|---------------|-------------|
| **SE** | Secure Element，独立安全芯片 | ⭐⭐⭐ 最高 | DUKPT 密钥下载 | SE 芯片内 |
| **TEE** | ARM TrustZone 可信执行环境 | ⭐⭐ 高 | DUKPT 密钥下载 | TEE 安全区 |
| **WhiteBox** | 软件白盒加密 | ⭐ 中 | DH-ECC 密钥交换 | WhiteBox 保护内存 |

> ⚠️ **重要**: 所有 TEE 类型都需要先完成证书签发，证书是后续密钥操作的身份凭证。

---

## 5. 阶段一：设备注册

### 5.1 流程说明

设备注册是 SDK 初始化的第一步，包括安全环境检测、设备信息上报和 HTTPS 连接建立。

```mermaid
sequenceDiagram
    autonumber
    participant App as 📱 Android App
    participant SDK as 🛡️ MPoC SDK
    participant Backend as 🖥️ A/M-Backend

    App->>SDK: MpocSdk.initialize(config)
    
    rect rgb(227, 242, 253)
        Note over SDK: 1.1 安全环境检测
        SDK->>SDK: SecurityChecker.checkRoot()
        SDK->>SDK: SecurityChecker.checkEmulator()
        SDK->>SDK: SecurityChecker.checkHookFramework()
        SDK->>SDK: DeviceManager.detectTeeType()
    end
    
    alt 检测到安全威胁
        SDK->>Backend: POST MPoC/api/threats/report
        SDK-->>App: callback.onInitFailed(SECURITY_THREAT)
    else 安全检测通过
        rect rgb(255, 248, 225)
            Note over SDK,Backend: 1.2 设备注册
            SDK->>Backend: POST MPoC/api/devices/register
            Backend-->>SDK: deviceId + accessToken + teeType
        end
        
        rect rgb(232, 245, 233)
            Note over SDK,Backend: 1.3 建立 HTTPS 连接
            SDK->>Backend: HTTPS 连接
            Backend-->>SDK: 连接确认
        end
        
        SDK-->>App: callback.onInitSuccess(deviceId, teeType)
    end
```

### 5.2 API: 设备注册

**端点**: `POST MPoC/api/devices/register`

**负责模块**: DeviceManager

**请求**:
```json
{
  "imei": "860000000000001",
  "model": "Samsung Galaxy S23",
  "osVersion": "Android 14",
  "sdkVersion": "1.0.0",
  "appVersion": "2.0.0",
  "securityInfo": {
    "isRooted": false,
    "isEmulator": false,
    "hasHookFramework": false,
    "isDebuggerAttached": false,
    "isAppTampered": false,
    "teeAvailable": true,
    "teeType": "TEE"
  }
}
```

**响应**:
```json
{
  "code": 200,
  "data": {
    "deviceId": "dev-550e8400-e29b-41d4-a716-446655440000",
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "tokenExpiresAt": "2024-12-31T10:00:00Z",
    "status": "PENDING_APPROVAL",
    "teeType": "TEE",
    "keyMode": "DUKPT"
  },
  "message": "Device registered successfully"
}
```

**响应字段说明**:

| 字段 | 类型 | 说明 |
|------|------|------|
| `deviceId` | string | 设备唯一标识，后续所有 API 调用需携带 |
| `accessToken` | string | JWT 访问令牌，后续 API 调用需在 Header 中携带 |
| `tokenExpiresAt` | string | 令牌过期时间 (UTC) |
| `status` | string | 设备状态: `PENDING_APPROVAL`, `APPROVED`, `REJECTED` |
| `teeType` | string | TEE 类型: `SE`, `TEE`, `WhiteBox` |
| `keyMode` | string | 密钥模式: `DUKPT` (SE/TEE) 或 `DH-ECC` (WhiteBox) |

> 📌 SDK 根据 `teeType` 和 `keyMode` 决定阶段三的密钥初始化方式。

### 5.3 accessToken 使用说明

设备注册成功后返回的 `accessToken` 是 JWT 格式的访问令牌，**后续所有调用 A/M-Backend 的 API 都需要在 HTTP Header 中携带此令牌**：

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

**Token 生命周期**:

| 事件 | 处理方式 |
|------|---------|
| Token 即将过期 | SDK 自动刷新 (过期前 5 分钟) |
| Token 已过期 | 返回 401 错误，SDK 需重新注册设备 |
| 设备被禁用 | Token 立即失效，返回 403 错误 |

**需要携带 accessToken 的 API**:

| API | 端点 |
|-----|------|
| CSR 证书签发 | `POST MPoC/api/certificates/sign` |
| ECC 密钥交换 | `POST MPoC/api/keys/ecc/exchange` |
| 威胁上报 | `POST MPoC/api/threats/report` |
| 交易鉴证 | `POST MPoC/api/transactions/attest` |

> ⚠️ **注意**: 
> - 直连 RKI HSM 的 DUKPT 密钥下载 API 不使用 accessToken，而是使用设备证书进行身份认证
> - 设备注册前检测到安全威胁时，威胁上报 API 可不携带 accessToken（此时设备尚未注册）

### 5.4 API: 威胁上报

**端点**: `POST MPoC/api/threats/report`

**负责模块**: SecurityChecker

**请求 Header**:
```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...  (设备注册后携带，注册前可省略)
Content-Type: application/json
```

**请求**:
```json
{
  "deviceId": "dev-550e8400-e29b-41d4-a716-446655440000",
  "threatType": "ROOT_DETECTED",
  "severity": "HIGH",
  "details": {
    "detectionMethod": "su_binary_check",
    "timestamp": "2024-12-30T10:00:00Z",
    "additionalInfo": "Found su binary at /system/bin/su"
  }
}
```

**响应**:
```json
{
  "code": 200,
  "data": {
    "threatId": "threat-123456",
    "action": "BLOCK_TRANSACTIONS",
    "message": "Device has been flagged for security review"
  },
  "message": "Threat reported successfully"
}
```

**威胁类型**:

| 类型 | 说明 | 严重级别 | SDK 处理 |
|------|------|---------|---------|
| `ROOT_DETECTED` | 检测到 Root | HIGH | 阻止初始化 |
| `EMULATOR_DETECTED` | 检测到模拟器 | HIGH | 阻止初始化 |
| `HOOK_FRAMEWORK_DETECTED` | 检测到 Hook 框架 | HIGH | 阻止初始化 |
| `DEBUGGER_ATTACHED` | 检测到调试器 | MEDIUM | 警告 |
| `TAMPERED_APP` | 应用被篡改 | HIGH | 阻止初始化 |
| `UNSAFE_ENVIRONMENT` | 不安全环境 | MEDIUM | 警告 |

---

## 6. 阶段二：证书签发

### 6.1 流程说明

设备注册成功后，SDK 生成 ECC 密钥对并提交 CSR，由 RKI CloudHSM CA 签发设备证书。**证书是后续 DUKPT 和 WhiteBox 两种模式的共同前提**。

```mermaid
sequenceDiagram
    autonumber
    participant App as 📱 Android App
    participant SDK as 🛡️ MPoC SDK
    participant Backend as 🖥️ A/M-Backend
    participant HSM as 🔐 RKI CloudHSM

    Note over App,HSM: 前置条件: 设备注册成功且审批通过
    
    rect rgb(227, 242, 253)
        Note over SDK: 2.1 生成 ECC 密钥对
        SDK->>SDK: CertManager.generateKeyPair(P-256)
        SDK->>SDK: 存储私钥到 Android Keystore
        SDK->>SDK: CertManager.createCsr()
    end
    
    rect rgb(255, 248, 225)
        Note over SDK,HSM: 2.2 提交 CSR
        SDK->>Backend: POST MPoC/api/certificates/sign
        Backend->>Backend: 验证设备状态
        Backend->>HSM: POST /RKI/api/v1/ca/sign
        HSM->>HSM: 验证 CSR → 签发证书
        HSM-->>Backend: certificate + chain
        Backend-->>SDK: certificate + certificateChain
    end
    
    rect rgb(232, 245, 233)
        Note over SDK: 2.3 存储证书
        SDK->>SDK: CertManager.storeCertificate()
        SDK->>SDK: 存储证书到 Android Keystore
    end
    
    SDK-->>App: callback.onCertificateReady()
```

### 6.2 证书层次结构

```mermaid
graph TB
    subgraph "证书链"
        RootCA["🔐 SUNBAY Root CA<br/>(自签名, 10年有效期)"]
        IntCA["🔐 SUNBAY MPoC Intermediate CA<br/>(5年有效期)"]
        DevCert["📱 Device Certificate<br/>(1年有效期, 可续期)"]
    end
    
    RootCA --> IntCA
    IntCA --> DevCert
    
    style RootCA fill:#fff8e1,stroke:#ffa000
    style IntCA fill:#fff8e1,stroke:#ffa000
    style DevCert fill:#e3f2fd,stroke:#1976d2
```

### 6.3 API: CSR 证书签发

**端点**: `POST MPoC/api/certificates/sign`

**负责模块**: CertManager

**请求 Header**:
```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
Content-Type: application/json
```

**请求**:
```json
{
  "deviceId": "dev-550e8400-e29b-41d4-a716-446655440000",
  "csr": "-----BEGIN CERTIFICATE REQUEST-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA...\n-----END CERTIFICATE REQUEST-----",
  "csrFormat": "PEM",
  "keyAlgorithm": "EC",
  "keyParams": {
    "curve": "P-256"
  },
  "requestedValidity": 365,
  "certificateProfile": "MPOC_DEVICE"
}
```

**请求参数说明**:

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `deviceId` | string | 是 | 设备唯一标识 |
| `csr` | string | 是 | PKCS#10 格式的 CSR (PEM 编码) |
| `csrFormat` | string | 是 | CSR 格式: `PEM` 或 `DER` |
| `keyAlgorithm` | string | 是 | 密钥算法: `EC` |
| `keyParams.curve` | string | 是 | ECC 曲线: `P-256` |
| `requestedValidity` | number | 否 | 请求的证书有效期 (天), 默认 365 |
| `certificateProfile` | string | 是 | 证书配置文件: `MPOC_DEVICE` |

**响应**:
```json
{
  "code": 200,
  "data": {
    "certificate": "-----BEGIN CERTIFICATE-----\nMIIDXTCCAkWgAwIBAgIJAJC1HiIAZAiU...\n-----END CERTIFICATE-----",
    "certificateChain": [
      "-----BEGIN CERTIFICATE-----\n...(Intermediate CA)...\n-----END CERTIFICATE-----",
      "-----BEGIN CERTIFICATE-----\n...(Root CA)...\n-----END CERTIFICATE-----"
    ],
    "serialNumber": "01:23:45:67:89:AB:CD:EF",
    "issuer": "CN=SUNBAY MPoC Intermediate CA, O=SUNBAY, C=US",
    "subject": "CN=dev-550e8400-e29b-41d4-a716-446655440000, O=SUNBAY, C=US",
    "notBefore": "2024-12-30T00:00:00Z",
    "notAfter": "2025-12-30T23:59:59Z",
    "fingerprint": {
      "sha256": "A1:B2:C3:D4:E5:F6:..."
    }
  },
  "message": "Certificate signed successfully"
}
```

**证书配置文件 (Certificate Profile)**:

| Profile | 用途 | 有效期 | Key Usage |
|---------|------|--------|-----------|
| `MPOC_DEVICE` | 设备身份认证 | 1 年 | digitalSignature, clientAuth |

**错误响应**:

| 错误码 | 错误类型 | 说明 |
|--------|---------|------|
| 400 | `INVALID_CSR` | CSR 格式无效或签名验证失败 |
| 403 | `DEVICE_NOT_APPROVED` | 设备未审批，无法签发证书 |
| 409 | `CERTIFICATE_EXISTS` | 设备已有有效证书 |
| 500 | `HSM_ERROR` | HSM 签发失败 |

---

## 7. 阶段三：密钥初始化

证书签发完成后，根据 TEE 类型进入不同的密钥初始化流程：

- **SE/TEE 设备**: 使用 DUKPT 密钥下载 (7.1)
- **WhiteBox 设备**: 使用 DH-ECC 密钥交换 (7.2)

```mermaid
flowchart TB
    A[证书签发完成] --> B{TEE 类型?}
    
    B -->|SE| C[DUKPT 模式]
    B -->|TEE| C
    B -->|WhiteBox| D[DH-ECC 模式]
    
    subgraph "DUKPT 模式 (SE/TEE)"
        C --> C1[等待 HTTPS 通知]
        C1 --> C2[直连 HSM 下载密钥]
        C2 --> C3[存储到 TEE/SE]
        C3 --> C4[确认下载完成]
    end
    
    subgraph "DH-ECC 模式 (WhiteBox)"
        D --> D1[生成临时 ECDH 密钥对]
        D1 --> D2[发起密钥交换]
        D2 --> D3[派生 AES-256 会话密钥]
        D3 --> D4[存储到 WhiteBox 保护内存]
    end
    
    C4 --> E[密钥就绪]
    D4 --> E
    
    style C fill:#e8f5e9,stroke:#388e3c
    style D fill:#fff8e1,stroke:#e65100
```

### 7.1 DUKPT 密钥下载 (SE/TEE 模式)

#### 7.1.1 流程说明

适用于 TEE 类型为 `SE` 或 `TEE` 的设备。SDK 直接调用 RKI CloudHSM API 下载密钥，使用设备证书进行身份认证。

```mermaid
sequenceDiagram
    autonumber
    participant App as 📱 Android App
    participant SDK as 🛡️ MPoC SDK
    participant Backend as 🖥️ A/M-Backend
    participant HSM as 🔐 RKI CloudHSM

    Note over App,HSM: 前置条件: 设备证书已签发
    
    Backend->>SDK: HTTPS: KEY_DOWNLOAD_REQUIRED
    Note right of Backend: 包含 HSM 访问凭证
    
    rect rgb(227, 242, 253)
        Note over SDK: 准备下载请求
        SDK->>SDK: KeyManager.prepareDownloadRequest()
        SDK->>SDK: 使用设备私钥签名请求
    end
    
    SDK->>HSM: POST /RKI/api/v1/keys/download
    Note right of SDK: deviceCertificate + signature
    
    rect rgb(255, 248, 225)
        Note over HSM: HSM 安全边界内
        HSM->>HSM: 验证设备证书
        HSM->>HSM: 验证请求签名
        HSM->>HSM: 生成 DUKPT IPEK
        HSM->>HSM: 使用设备公钥加密
    end
    
    HSM-->>SDK: 加密的 DUKPT 密钥 + KSN
    
    rect rgb(232, 245, 233)
        Note over SDK: 安全处理 (TEE/SE 内)
        SDK->>SDK: 使用设备私钥解密
        SDK->>SDK: 存储 DUKPT 密钥到 TEE/SE
    end
    
    SDK->>HSM: POST /RKI/api/v1/keys/confirm
    HSM-->>SDK: 确认成功
    
    SDK-->>App: callback.onKeyReady(ksn)
```

> ⚠️ **存储要求**: DUKPT 密钥必须存储在 TEE/SE 安全环境内，**不能**存储到 Android Keystore。

#### 7.1.2 API: DUKPT 密钥下载 (RKI HSM)

**端点**: `POST https://<rki-hsm-host>/RKI/api/v1/keys/download`

**负责模块**: KeyManager

**请求**:
```json
{
  "deviceId": "dev-550e8400-e29b-41d4-a716-446655440000",
  "deviceCertificate": "-----BEGIN CERTIFICATE-----\nMIIDXTCCAkWgAwIBAgIJAJC1HiIAZAiU...\n-----END CERTIFICATE-----",
  "keyType": "DUKPT",
  "timestamp": "2024-12-30T10:00:00Z",
  "signature": "MEUCIQD...",
  "requestId": "req-20241230-001"
}
```

**签名计算方式**:
```
signatureData = deviceId + keyType + timestamp + requestId
signature = ECDSA_Sign(devicePrivateKey, SHA256(signatureData))
```

**响应**:
```json
{
  "code": 200,
  "data": {
    "encryptedKey": "base64_encrypted_ipek",
    "ksn": "FFFF9876543210E00001",
    "keyCheckValue": "A1B2C3",
    "algorithm": "3DES",
    "expiresAt": "2025-12-30T00:00:00Z",
    "encryptionMethod": "ECIES-P256"
  },
  "message": "Key downloaded successfully"
}
```

**响应字段说明**:

| 字段 | 说明 |
|------|------|
| `encryptedKey` | 使用设备证书公钥加密的 DUKPT IPEK |
| `ksn` | Key Serial Number (21 位十六进制) |
| `keyCheckValue` | 密钥校验值 (KCV) |
| `algorithm` | 密钥算法: `3DES` 或 `AES` |
| `encryptionMethod` | 密钥加密方式: `ECIES-P256` |

#### 7.1.3 API: DUKPT 密钥锁定

**端点**: `POST /RKI/api/v1/keys/confirm`

**负责模块**: KeyManager

**请求 Header**:
```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
Content-Type: application/json
```

**请求**:
```json
{
  "deviceId": "dev-550e8400-e29b-41d4-a716-446655440000",
  "ksn": "FFFF9876543210E00001",
  "keyCheckValue": "A1B2C3",
  "downloadedAt": "2024-12-30T10:00:00Z"
}
```

**响应**:
```json
{
  "code": 200,
  "data": {
    "confirmed": true,
    "keyStatus": "ACTIVE"
  },
  "message": "Key download confirmed"
}
```

### 7.2 DH-ECC 密钥交换 (WhiteBox 模式)

#### 7.2.1 流程说明

适用于 TEE 类型为 `WhiteBox` 的设备。使用设备证书私钥签名认证，派生会话密钥用于 PIN 加密。

```mermaid
sequenceDiagram
    autonumber
    participant App as 📱 Android App
    participant SDK as 🛡️ MPoC SDK
    participant Backend as 🖥️ A/M-Backend

    Note over App,Backend: 前置条件: 设备证书已签发
    
    App->>SDK: MpocSdk.initKeyExchange()
    
    rect rgb(227, 242, 253)
        Note over SDK: 准备密钥交换
        SDK->>SDK: WhiteBoxEngine.generateEphemeralKeyPair()
        SDK->>SDK: 使用设备私钥签名请求
    end
    
    SDK->>Backend: POST MPoC/api/keys/ecc/exchange
    Note right of SDK: deviceCertificate + ephemeralPublicKey + signature
    
    rect rgb(255, 248, 225)
        Note over Backend: 验证与响应
        Backend->>Backend: 验证设备证书有效性
        Backend->>Backend: 验证请求签名
        Backend->>Backend: 生成服务端临时 ECDH 公钥
    end
    
    Backend-->>SDK: serverEphemeralPublicKey + sessionId + kdfParams
    
    rect rgb(232, 245, 233)
        Note over SDK: 会话密钥派生
        SDK->>SDK: ECDH 计算共享密钥
        SDK->>SDK: HKDF-SHA256 派生 AES-256 会话密钥
        SDK->>SDK: 存储会话密钥到 WhiteBox 保护内存
    end
    
    SDK-->>App: callback.onKeyExchangeSuccess(sessionId)
```

#### 7.2.2 密钥层次结构

WhiteBox 模式包含两层密钥：

```mermaid
graph TB
    subgraph "设备级密钥 (长期)"
        DevKey["🔐 设备 ECC 密钥对<br/>(P-256, 存储在 Keystore)"]
        DevCert["📜 设备证书<br/>(CA 签发, 1年有效期)"]
    end
    
    subgraph "会话级密钥 (短期)"
        EphKey["🔑 临时 ECDH 密钥对<br/>(每次交换生成)"]
        SessionKey["🔒 AES-256 会话密钥<br/>(HKDF 派生, 30分钟有效)"]
    end
    
    DevKey --> DevCert
    DevKey -->|签名认证| EphKey
    EphKey -->|ECDH + HKDF| SessionKey
    
    style DevKey fill:#e3f2fd,stroke:#1976d2
    style DevCert fill:#e3f2fd,stroke:#1976d2
    style EphKey fill:#fff8e1,stroke:#e65100
    style SessionKey fill:#fff8e1,stroke:#e65100
```

| 密钥类型 | 生命周期 | 用途 | 存储位置 |
|---------|---------|------|---------|
| 设备密钥对 | 1 年 (随证书) | 身份认证、请求签名 | Android Keystore |
| 设备证书 | 1 年 (可续期) | 身份验证、公钥分发 | Android Keystore |
| 临时 ECDH 密钥对 | 单次使用 | 会话密钥协商 | 内存 (用后销毁) |
| AES-256 会话密钥 | 30 分钟 | PIN 加密 | WhiteBox 保护内存 |

#### 7.2.3 会话密钥生命周期

| 参数 | 值 | 说明 |
|------|-----|------|
| **会话有效期** | 30 分钟 | 从密钥交换成功开始计算 |
| **最大交易数** | 100 笔 | 单个会话内允许的最大交易数 |
| **自动续期** | 支持 | 会话过期前 5 分钟自动发起新的密钥交换 |

```mermaid
stateDiagram-v2
    [*] --> 检查证书: SDK 启动
    检查证书 --> 证书有效: 证书未过期
    检查证书 --> 需要续期: 证书已过期
    
    需要续期 --> 证书有效: CSR 续期成功
    
    证书有效 --> 密钥交换中: 发起 ECDH 交换
    密钥交换中 --> 会话有效: 交换成功
    密钥交换中 --> 证书有效: 交换失败 (重试)
    
    会话有效 --> 会话有效: PIN 加密 (计数+1)
    会话有效 --> 续期中: 剩余 < 5分钟 或 计数 > 90
    会话有效 --> 已过期: 超时 或 计数 >= 100
    
    续期中 --> 会话有效: 新会话建立
    续期中 --> 已过期: 续期失败
    
    已过期 --> 密钥交换中: 重新交换
```

#### 7.2.4 API: ECC 密钥交换

**端点**: `POST MPoC/api/keys/ecc/exchange`

**负责模块**: WhiteBoxEngine

**请求 Header**:
```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
Content-Type: application/json
```

**请求**:
```json
{
  "deviceId": "dev-550e8400-e29b-41d4-a716-446655440000",
  "deviceCertificate": "-----BEGIN CERTIFICATE-----\nMIIDXTCCAkWgAwIBAgIJAJC1HiIAZAiU...\n-----END CERTIFICATE-----",
  "ephemeralPublicKey": "04a1b2c3d4e5f6...",
  "curve": "P-256",
  "timestamp": "2024-12-30T10:00:00Z",
  "signature": "MEUCIQD..."
}
```

**签名计算方式**:
```
signatureData = deviceId + ephemeralPublicKey + timestamp
signature = ECDSA_Sign(devicePrivateKey, SHA256(signatureData))
```

**响应**:
```json
{
  "code": 200,
  "data": {
    "serverEphemeralPublicKey": "04f1e2d3c4b5a6...",
    "sessionId": "sess-20241230-abc123",
    "expiresAt": "2024-12-30T10:30:00Z",
    "maxTransactions": 100,
    "curve": "P-256",
    "kdfParams": {
      "algorithm": "HKDF-SHA256",
      "info": "PIN_ENCRYPTION_V1",
      "keyLength": 256
    }
  },
  "message": "Key exchange successful"
}
```

### 7.3 密钥存储位置总结

| 密钥/证书类型 | SE 模式 | TEE 模式 | WhiteBox 模式 |
|--------------|---------|---------|--------------|
| 设备证书 | Android Keystore | Android Keystore | Android Keystore |
| 设备私钥 | Android Keystore | Android Keystore | Android Keystore |
| DUKPT IPEK | SE 芯片内 | TEE 安全区 | ❌ 不适用 |
| 会话密钥 | ❌ 不适用 | ❌ 不适用 | WhiteBox 保护内存 |

> ⚠️ **重要**: DUKPT 密钥**不能**存储到 Android Keystore，必须存储在 TEE/SE 安全环境内。

---

## 8. 阶段四：交易处理

### 8.1 流程说明

密钥初始化完成后，SDK 进入就绪状态，可以处理交易。交易处理流程如下：

1. **MPoC SDK** 负责：交易鉴证 Token 获取、PIN 加密
2. **Android App** 负责：将加密 PIN Block 提交到 SUNBAY POSP
3. **SUNBAY POSP** 负责：PIN 转加密、路由到 Processor

```mermaid
sequenceDiagram
    autonumber
    participant App as 📱 Android App
    participant SDK as 🛡️ MPoC SDK
    participant Backend as 🖥️ A/M-Backend
    participant POSP as 🏦 SUNBAY POSP
    participant Processor as 💳 Processor

    Note over App,Processor: 前置条件: 密钥已就绪
    
    App->>SDK: MpocSdk.requestTransactionToken(amount, transactionId)
    
    rect rgb(227, 242, 253)
        Note over SDK,Backend: 4.1 交易鉴证
        SDK->>SDK: TokenManager.checkTokenValidity()
        SDK->>Backend: POST MPoC/api/transactions/attest
        Backend-->>SDK: transactionToken
    end
    
    SDK-->>App: transactionToken + tokenExpiresAt
    
    rect rgb(255, 248, 225)
        Note over App,SDK: 4.2 PIN 加密
        App->>SDK: MpocSdk.encryptPin(pin, pan)
        SDK->>SDK: 显示安全 PIN 输入界面
        SDK->>SDK: CryptoEngine.encryptPin(pin, pan)
        Note right of SDK: DUKPT 或 WhiteBox 加密
        SDK-->>App: encryptedPinBlock + ksn (DUKPT) 或 sessionId (WhiteBox)
    end
    
    rect rgb(232, 245, 233)
        Note over App,Processor: 4.3 交易提交 (App 直接提交到 POSP)
        App->>POSP: 提交交易请求
        Note right of App: encryptedPinBlock + 交易数据
        
        POSP->>POSP: PIN 转加密 (HSM)
        Note right of POSP: ECC/DUKPT → Processor ZPK
        POSP->>Processor: 发送交易
        Processor-->>POSP: 交易结果
        POSP-->>App: 交易成功/失败
    end
    
    App-->>App: 显示交易结果
```

### 8.2 职责划分

| 组件 | 职责 | 说明 |
|------|------|------|
| **MPoC SDK** | 交易鉴证 Token 获取 | 调用 A/M-Backend 获取 transactionToken |
| **MPoC SDK** | PIN 加密 | 使用 DUKPT 或 WhiteBox 加密 PIN |
| **Android App** | 交易提交 | 将加密 PIN Block 提交到 POSP |
| **SUNBAY POSP** | PIN 转加密 | 在 HSM 内将 PIN 转加密为 Processor ZPK 格式 |
| **SUNBAY POSP** | 交易路由 | 将交易发送到对应的 Processor |
| **A/M-Backend** | Token 管理 | 签发 transactionToken |

### 8.3 API: 交易鉴证 Token 获取

**端点**: `POST MPoC/api/transactions/attest`

**负责模块**: TokenManager, TransactionProcessor

**请求 Header**:
```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
Content-Type: application/json
```

**请求**:
```json
{
  "deviceId": "dev-550e8400-e29b-41d4-a716-446655440000",
  "transactionId": "txn-20241230-001",
  "transactionType": "PAYMENT",
  "amount": 10000,
  "currency": "USD",
  "securityInfo": {
    "isRooted": false,
    "isEmulator": false,
    "hasHookFramework": false,
    "isDebuggerAttached": false,
    "isAppTampered": false,
    "timestamp": "2024-12-30T10:00:00Z"
  }
}
```

**请求参数说明**:

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `deviceId` | string | 是 | 设备唯一标识 |
| `transactionId` | string | 是 | 交易流水号 (由 App 生成，全局唯一) |
| `transactionType` | string | 是 | 交易类型: `PAYMENT`, `REFUND`, `VOID`, `PRE_AUTH` |
| `amount` | number | 是 | 交易金额 (最小单位，如分) |
| `currency` | string | 是 | 货币代码 (ISO 4217)，如 `USD`, `CNY` |
| `securityInfo.isRooted` | boolean | 是 | 是否检测到 Root |
| `securityInfo.isEmulator` | boolean | 是 | 是否检测到模拟器 |
| `securityInfo.hasHookFramework` | boolean | 是 | 是否检测到 Hook 框架 |
| `securityInfo.isDebuggerAttached` | boolean | 是 | 是否检测到调试器 |
| `securityInfo.isAppTampered` | boolean | 是 | 应用是否被篡改 |
| `securityInfo.timestamp` | string | 是 | 检测时间戳 (UTC) |

**响应**:
```json
{
  "code": 200,
  "data": {
    "transactionId": "txn-20241230-001",
    "transactionToken": "eyJhbGciOiJIUzI1NiIs...",
    "tokenExpiresAt": "2024-12-30T10:05:00Z",
    "maxAmount": 10000,
    "allowedTransactionTypes": ["PAYMENT"]
  },
  "message": "Transaction token issued"
}
```

**响应字段说明**:

| 字段 | 类型 | 说明 |
|------|------|------|
| `transactionId` | string | 交易流水号 (与请求一致) |
| `transactionToken` | string | 交易令牌 (JWT 格式)，用于后续交易提交 |
| `tokenExpiresAt` | string | 令牌过期时间 (UTC)，默认 5 分钟 |
| `maxAmount` | number | 令牌允许的最大交易金额 |
| `allowedTransactionTypes` | array | 令牌允许的交易类型列表 |

**交易类型说明**:

| 类型 | 说明 |
|------|------|
| `PAYMENT` | 消费交易 |
| `REFUND` | 退款交易 |
| `VOID` | 撤销交易 |
| `PRE_AUTH` | 预授权交易 |

**错误响应**:

| 错误码 | 错误类型 | 说明 |
|--------|---------|------|
| 400 | `INVALID_AMOUNT` | 交易金额无效 |
| 403 | `DEVICE_BLOCKED` | 设备已被阻止交易 |
| 403 | `SECURITY_CHECK_FAILED` | 安全检测失败 (Root/模拟器/Hook 等) |
| 422 | `KEY_NOT_READY` | 密钥未就绪，无法进行交易 |

> 📌 **说明**: `securityInfo` 字段与设备注册接口保持一致，SDK 在每次交易前重新执行安全检测并上报结果。

### 8.4 App 提交交易到 POSP

PIN 加密完成后，**Android App** (而非 SDK) 负责将交易提交到 SUNBAY POSP。

**POSP 端点**: `POST https://<posp-host>/POSP/api/transactions`

**请求**:
```json
{
  "transactionId": "txn-20241230-001",
  "transactionType": "PAYMENT",
  "amount": 10000,
  "currency": "USD",
  "cardData": {
    "pan": "4111111111111111",
    "expiryDate": "1225",
    "encryptedPinBlock": "A1B2C3D4E5F6...",
    "pinBlockFormat": "ISO_9564_FORMAT_0",
    "ksn": "FFFF9876543210E00001",
    "encryptionMode": "DUKPT"
  },
  "merchantId": "merchant-001",
  "terminalId": "term-001"
}
```

**POSP 处理流程**:

```mermaid
flowchart TB
    A[接收交易请求] --> B{加密模式?}
    
    B -->|DUKPT| C[HSM: DUKPT 解密]
    B -->|WhiteBox| D[HSM: AES-GCM 解密]
    
    C --> E[HSM: 使用 Processor ZPK 重加密]
    D --> E
    
    E --> F[路由到 Processor]
    F --> G[返回交易结果]
    
    style B fill:#fff8e1,stroke:#e65100
    style E fill:#e8f5e9,stroke:#388e3c
```

---

## 9. PIN 加密方案

### 9.1 加密模式对比

| 特性 | DUKPT (SE/TEE) | WhiteBox DH-ECC |
|------|----------------|-----------------|
| **适用 TEE 类型** | SE, TEE | WhiteBox |
| **密钥来源** | HSM 下载 | ECDH 协商 |
| **密钥生命周期** | 长期 (直到 KSN 耗尽) | 会话级 (30 分钟) |
| **每笔交易密钥** | 自动派生唯一密钥 | 复用会话密钥 |
| **网络依赖** | 仅初始下载 | 每 30 分钟需重新交换 |
| **离线支持** | 支持 | 有限支持 (会话有效期内) |
| **前向安全性** | 每笔交易独立 | 会话内共享 |
| **安全级别** | ⭐⭐⭐ 最高 | ⭐⭐ 中等 |

### 9.2 DUKPT 模式详解

DUKPT (Derived Unique Key Per Transaction) 每笔交易使用唯一派生密钥：

| 参数 | 说明 |
|------|------|
| **BDK** | Base Derivation Key，由 HSM 管理 |
| **KSN** | Key Serial Number，21 位十六进制 |
| **IPEK** | Initial PIN Encryption Key |
| **PIN Block** | ISO 9564 Format 0 |

**KSN 格式**:
```
FFFF 9876543210 E00001
│    │          │
│    │          └── 交易计数器 (21 bits)
│    └────────────── 设备标识 (59 bits)
└───────────────────── 密钥集 ID (4 bits)
```

### 9.3 WhiteBox DH-ECC 模式详解

| 组件 | 说明 |
|------|------|
| **ECC 曲线** | P-256 (secp256r1) |
| **密钥派生** | HKDF-SHA256 |
| **加密算法** | AES-256-GCM |
| **认证标签** | 128-bit |

**加密流程**:
1. 客户端生成 ECC 临时密钥对
2. 与服务端交换公钥
3. ECDH 计算共享密钥
4. HKDF 派生 AES-256 会话密钥
5. AES-GCM 加密 PIN

### 9.4 PIN Block 格式

采用 ISO 9564 Format 0：

```
PIN Block = PIN Field XOR PAN Field

PIN Field:  0 | N | P P P P P P P P P P P P P P
            (N=PIN长度, P=PIN数字, 填充F)

PAN Field:  0 0 0 0 | PAN[3..14] | 0
            (PAN 右起第2位到第13位)
```

---

## 10. SDK 版本管理

### 10.1 功能说明

SDK 版本管理用于确保设备上运行的 MPoC SDK 版本符合安全要求，主要功能包括：

| 功能 | 说明 |
|------|------|
| **版本检查** | SDK 启动时检查是否有新版本可用 |
| **版本上报** | 向后端上报当前 SDK 版本信息 |
| **强制更新** | 当检测到安全漏洞时，强制要求更新 SDK |
| **版本兼容性** | 检查当前版本与后端 API 的兼容性 |

### 10.2 版本检查流程

```mermaid
sequenceDiagram
    autonumber
    participant App as 📱 Android App
    participant SDK as 🛡️ MPoC SDK
    participant Backend as 🖥️ A/M-Backend

    App->>SDK: MpocSdk.initialize(config)
    
    rect rgb(227, 242, 253)
        Note over SDK,Backend: 版本检查
        SDK->>Backend: POST MPoC/api/sdk/version/check
        Note right of SDK: 上报当前 SDK 版本
        Backend->>Backend: 检查版本兼容性
        Backend-->>SDK: 版本检查结果
    end
    
    alt 需要强制更新
        SDK-->>App: callback.onUpdateRequired(latestVersion, downloadUrl)
        Note over App: 阻止继续使用，提示更新
    else 有可选更新
        SDK-->>App: callback.onUpdateAvailable(latestVersion, downloadUrl)
        Note over App: 提示更新，可继续使用
    else 版本正常
        SDK->>SDK: 继续初始化流程
    end
```

### 10.3 API: SDK 版本检查

**端点**: `POST MPoC/api/sdk/version/check`

**负责模块**: VersionManager

**请求 Header**:
```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...  (设备注册后携带，首次可省略)
Content-Type: application/json
```

**请求**:
```json
{
  "deviceId": "dev-550e8400-e29b-41d4-a716-446655440000",
  "sdkVersion": "1.0.0",
  "sdkBuildNumber": 100,
  "appVersion": "2.0.0",
  "appPackageName": "com.example.softpos",
  "osVersion": "Android 14",
  "deviceModel": "Samsung Galaxy S23"
}
```

**请求参数说明**:

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `deviceId` | string | 否 | 设备唯一标识 (首次注册前可为空) |
| `sdkVersion` | string | 是 | 当前 SDK 版本号 (语义化版本) |
| `sdkBuildNumber` | number | 是 | SDK 构建号 |
| `appVersion` | string | 是 | 宿主 App 版本号 |
| `appPackageName` | string | 是 | 宿主 App 包名 |
| `osVersion` | string | 是 | Android 系统版本 |
| `deviceModel` | string | 是 | 设备型号 |

**响应**:
```json
{
  "code": 200,
  "data": {
    "currentVersion": "1.0.0",
    "latestVersion": "1.2.0",
    "minRequiredVersion": "1.0.0",
    "updateRequired": false,
    "updateAvailable": true,
    "updateType": "OPTIONAL",
    "releaseNotes": "1. 修复安全漏洞\n2. 性能优化\n3. 新增功能支持",
    "downloadUrl": "https://sdk.sunbay.dev/mpoc-sdk-1.2.0.aar",
    "releaseDate": "2024-12-30",
    "deprecationDate": null,
    "compatibilityStatus": "COMPATIBLE"
  },
  "message": "Version check completed"
}
```

**响应字段说明**:

| 字段 | 类型 | 说明 |
|------|------|------|
| `currentVersion` | string | 当前上报的 SDK 版本 |
| `latestVersion` | string | 最新可用 SDK 版本 |
| `minRequiredVersion` | string | 最低要求版本 (低于此版本必须更新) |
| `updateRequired` | boolean | 是否需要强制更新 |
| `updateAvailable` | boolean | 是否有可用更新 |
| `updateType` | string | 更新类型: `MANDATORY`, `OPTIONAL`, `NONE` |
| `releaseNotes` | string | 版本更新说明 |
| `downloadUrl` | string | SDK 下载地址 |
| `releaseDate` | string | 发布日期 |
| `deprecationDate` | string | 当前版本废弃日期 (null 表示未废弃) |
| `compatibilityStatus` | string | 兼容性状态: `COMPATIBLE`, `DEPRECATED`, `INCOMPATIBLE` |

**更新类型说明**:

| 类型 | 说明 | SDK 处理 |
|------|------|---------|
| `MANDATORY` | 强制更新 | 阻止 SDK 初始化，必须更新后才能使用 |
| `OPTIONAL` | 可选更新 | 提示用户更新，可继续使用当前版本 |
| `NONE` | 无需更新 | 当前已是最新版本 |

**兼容性状态说明**:

| 状态 | 说明 | SDK 处理 |
|------|------|---------|
| `COMPATIBLE` | 完全兼容 | 正常使用 |
| `DEPRECATED` | 已废弃 | 警告提示，建议更新 |
| `INCOMPATIBLE` | 不兼容 | 阻止使用，必须更新 |

**错误响应**:

| 错误码 | 错误类型 | 说明 |
|--------|---------|------|
| 400 | `INVALID_VERSION` | 版本号格式无效 |
| 403 | `SDK_BLOCKED` | SDK 版本已被禁用 |
| 404 | `APP_NOT_REGISTERED` | App 包名未注册 |

### 10.4 版本管理策略

| 策略 | 说明 |
|------|------|
| **安全漏洞修复** | 发现安全漏洞时，将受影响版本标记为 `INCOMPATIBLE`，强制更新 |
| **API 变更** | 后端 API 重大变更时，旧版本 SDK 标记为 `DEPRECATED` |
| **功能废弃** | 功能废弃前提前通知，设置 `deprecationDate` |
| **灰度发布** | 新版本可按设备比例灰度推送 |

---

## 11. 错误处理

### 11.1 通用错误码

| 错误码 | 说明 | 处理建议 |
|--------|------|---------|
| `400` | 请求参数错误 | 检查请求参数格式 |
| `401` | 认证失败 | 重新获取 token |
| `403` | 权限不足 | 检查设备状态 |
| `404` | 资源不存在 | 检查 deviceId 等 |
| `409` | 资源冲突 | 设备已注册等 |
| `422` | 业务逻辑错误 | 查看具体错误信息 |
| `429` | 请求过于频繁 | 降低请求频率 |
| `500` | 服务器内部错误 | 稍后重试 |
| `503` | 服务不可用 | 稍后重试 |

### 11.2 阶段相关错误

| 阶段 | 错误类型 | 说明 | SDK 处理 |
|------|---------|------|---------|
| 设备注册 | `DEVICE_REJECTED` | 设备被拒绝 | 提示用户联系管理员 |
| 证书签发 | `INVALID_CSR` | CSR 格式无效 | 重新生成 CSR |
| 证书签发 | `DEVICE_NOT_APPROVED` | 设备未审批 | 等待审批 |
| 密钥下载 | `HSM_UNAVAILABLE` | HSM 不可用 | 稍后重试 |
| 密钥交换 | `CERTIFICATE_EXPIRED` | 设备证书已过期 | 发起 CSR 续期 |
| 密钥交换 | `SIGNATURE_INVALID` | 请求签名验证失败 | 检查设备私钥 |
| 交易处理 | `SESSION_EXPIRED` | 会话已过期 | 重新进行密钥交换 |
| 交易处理 | `SESSION_LIMIT_EXCEEDED` | 会话交易数已达上限 | 重新进行密钥交换 |

### 11.3 错误响应格式

```json
{
  "code": 422,
  "error": {
    "type": "VALIDATION_ERROR",
    "message": "Invalid device ID format",
    "details": {
      "field": "deviceId",
      "reason": "Must be a valid UUID"
    }
  },
  "timestamp": "2024-12-30T10:00:00Z",
  "requestId": "req-abc123"
}
```

### 11.4 重试策略

| 错误类型 | 重试策略 |
|---------|---------|
| 网络超时 | 指数退避，最多 3 次 |
| 5xx 错误 | 指数退避，最多 3 次 |
| 401 错误 | 刷新 token 后重试 1 次 |
| 4xx 其他 | 不重试，返回错误 |

---

## 12. 安全规范

### 12.1 传输安全

| 措施 | 说明 |
|------|------|
| **TLS 1.3** | 所有 API 通信强制使用 TLS 1.3 |
| **证书固定** | 客户端验证服务器证书 |
| **请求签名** | 关键 API 使用 ECDSA 签名 |

### 12.2 数据安全

| 数据类型 | 存储位置 | 保护措施 |
|---------|---------|---------|
| 设备证书 | Android Keystore | 硬件保护 |
| 设备私钥 | Android Keystore | 硬件保护，不可导出 |
| DUKPT 密钥 | TEE/SE | 硬件隔离 |
| WhiteBox 会话密钥 | WhiteBox 保护内存 | 白盒加密 |
| PIN | 仅内存 | 不持久化，用后清除 |
| PAN | 日志脱敏 | 仅显示后 4 位 |

### 12.3 设备安全检测

| 检测项 | 处理方式 |
|--------|---------|
| Root 检测 | 阻止初始化，上报威胁 |
| 模拟器检测 | 阻止初始化，上报威胁 |
| Hook 框架检测 | 阻止初始化，上报威胁 |
| 调试器检测 | 警告，可配置阻止 |
| 应用完整性 | 签名校验，阻止篡改版本 |

### 12.4 合规要求

| 标准 | 要求 |
|------|------|
| **PCI-DSS** | 数据安全标准 |
| **PCI PIN** | PIN 安全标准 |
| **PCI P2PE** | 点对点加密 |

---

## 13. 附录

### A. 术语表

| 术语 | 全称 | 说明 |
|------|------|------|
| MPoC | Mobile Point of Contact | 移动接触点 |
| DUKPT | Derived Unique Key Per Transaction | 每笔交易派生唯一密钥 |
| KSN | Key Serial Number | 密钥序列号 |
| BDK | Base Derivation Key | 基础派生密钥 |
| IPEK | Initial PIN Encryption Key | 初始 PIN 加密密钥 |
| HSM | Hardware Security Module | 硬件安全模块 |
| SE | Secure Element | 安全元件，独立安全芯片 |
| TEE | Trusted Execution Environment | 可信执行环境 (ARM TrustZone) |
| WhiteBox | White-Box Cryptography | 白盒加密，软件实现的安全方案 |
| ECC | Elliptic Curve Cryptography | 椭圆曲线加密 |
| ECDH | Elliptic Curve Diffie-Hellman | 椭圆曲线密钥交换 |
| CSR | Certificate Signing Request | 证书签名请求 |
| CA | Certificate Authority | 证书颁发机构 |
| X.509 | - | 公钥证书标准格式 |
| PKCS#10 | Public Key Cryptography Standards #10 | CSR 标准格式 |
| HKDF | HMAC-based Key Derivation Function | 基于 HMAC 的密钥派生函数 |

### B. SDK 接口速查

```java
// 阶段一: 设备注册
MpocSdk.initialize(config, callback)
  → callback.onInitSuccess(deviceId, teeType)
  → callback.onInitFailed(error)

// 阶段二: 证书签发 (SDK 内部自动执行)
  → callback.onCertificateReady()

// 阶段三: 密钥初始化
// DUKPT 模式 (SDK 内部自动执行)
  → callback.onKeyReady(ksn)

// WhiteBox 模式
MpocSdk.initKeyExchange()
  → callback.onKeyExchangeSuccess(sessionId)
  → callback.onKeyExchangeFailed(error)

// 阶段四: 交易处理
// 4.1 获取交易鉴证 Token (SDK 负责)
MpocSdk.requestTransactionToken(amount, transactionId, callback)
  → callback.onTokenReady(transactionToken, expiresAt)
  → callback.onTokenFailed(error)

// 4.2 PIN 加密 (SDK 负责)
MpocSdk.encryptPin(pin, pan, callback)
  → callback.onPinEncrypted(encryptedPinBlock, ksn/sessionId)
  → callback.onPinEncryptFailed(error)

// 4.3 交易提交 (App 负责，直接调用 POSP API)
// App 使用 HTTP Client 提交到 POSP:
// POST https://<posp-host>/POSP/api/transactions
// Body: { encryptedPinBlock, transactionId, cardData, ... }

// 工具方法
MpocSdk.getDeviceStatus() → DeviceStatus
MpocSdk.getTeeType() → TeeType
MpocSdk.forceKeyRefresh() → void
```

> ⚠️ **重要**: MPoC SDK 只负责 Token 获取和 PIN 加密，**交易提交由 Android App 直接调用 POSP API**。

### C. 版本历史

| 版本 | 日期 | 变更说明 |
|------|------|---------|
| v1.0 | 2024-12-30 | 初始版本 |
| v1.1 | 2024-12-30 | 增加 CSR 证书签发 API |
| v1.2 | 2024-12-31 | 明确 TEE 类型与密钥模式对应关系 |
| v2.0 | 2024-12-31 | 按 SDK 初始化调用顺序重构文档结构，明确模块职责划分 |
| v2.1 | 2024-12-31 | 统一 securityInfo 字段；交易鉴证增加 transactionId；RKI API 前缀改为 /RKI/api/v1；补充 accessToken 使用说明和 API Header |
| v2.2 | 2024-12-31 | 明确交易处理职责划分：SDK 负责 Token 获取和 PIN 加密，App 直接提交交易到 POSP |
| v2.3 | 2024-12-31 | A/M-Backend API 路径从 /MPoC/api/v1 修改为 MPoC/api |
| v2.4 | 2024-12-31 | 移除 POSP Token 验证流程；通信关系图增加处理顺序号；密钥下载确认改为 DUKPT 密钥锁定 |
| v2.5 | 2024-12-31 | 增加 SDK 版本管理 API |
| v2.6 | 2024-12-31 | WebSocket 修改为 HTTPS；Futurex 修改为 RKI |
| v2.7 | 2024-12-31 | 移除 POSP 验证 transactionToken 流程 |
| v2.8 | 2024-12-31 | 修复章节编号错误；更新通信关系图描述 |
