# SUNBAY SoftPOS 系统架构设计

## 1. 架构概览

SUNBAY SoftPOS 采用五端分离的现代化架构设计，包括 Android 终端、Web 管理后台、云端服务、内核服务和 Web 演示。各端通过 RESTful API 和 WebSocket 进行通信，实现设备管理、密钥管理、健康监控、交易处理和内核托管的完整业务流程。

### 1.1 架构原则

- **分层架构**: 清晰的职责分离，便于维护和扩展
- **高内聚低耦合**: 模块化设计，减少依赖
- **安全优先**: 多层安全防护，符合金融标准
- **高可用性**: 容错设计，支持水平扩展
- **可观测性**: 完整的日志、指标和追踪

### 1.2 技术选型理由

| 技术 | 选型理由 |
|------|---------|
| **Rust** | 内存安全、高性能、零成本抽象 |
| **React** | 组件化、生态丰富、开发效率高 |
| **Kotlin** | 现代语言特性、Android 官方推荐 |
| **SQLite** | 轻量级、零配置、高可靠性 |
| **Redis** | 高性能缓存、支持多种数据结构 |
| **WebAssembly** | 跨平台、高性能、安全沙箱 |
| **Vite** | 快速构建、热更新、现代化工具链 |

---

## 2. Backend 架构

### 2.1 分层架构

```
┌─────────────────────────────────────────────────────────┐
│                    API Layer (Axum)                      │
│  - Routes (路由定义)                                     │
│  - Handlers (请求处理)                                   │
│  - Middleware (中间件)                                   │
│    • Auth (认证)                                         │
│    • Rate Limit (速率限制)                               │
│    • Logging (日志)                                      │
│    • Metrics (指标)                                      │
│    • Tracing (追踪)                                      │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│                  Business Logic Layer                    │
│  - Device Service (设备服务)                             │
│  - Key Management Service (密钥管理服务)                 │
│  - Health Check Service (健康检查服务)                   │
│  - Threat Detection Service (威胁检测服务)               │
│  - Transaction Service (交易服务)                        │
│  - Version Service (版本服务)                            │
│  - Audit Service (审计服务)                              │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│                  Data Access Layer                       │
│  - Device Repository                                     │
│  - Health Check Repository                               │
│  - Threat Repository                                     │
│  - Transaction Repository                                │
│  - Version Repository                                    │
│  - Audit Repository                                      │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│                 Infrastructure Layer                     │
│  - Database (SQLite + SQLx)                              │
│  - Cache (Redis)                                         │
│  - HSM Client (FutureX)                                  │
│  - Config (YAML + Env)                                   │
└─────────────────────────────────────────────────────────┘
```

### 2.2 核心模块

#### 2.2.1 API Layer

**职责**: 处理 HTTP 请求，路由分发，中间件处理

**主要组件**:
- `routes.rs`: 路由定义（60+ 端点）
- `handlers/`: 请求处理器
  - `auth.rs`: 认证相关
  - `device.rs`: 设备管理
  - `key.rs`: 密钥管理
  - `health.rs`: 健康检查
  - `threat.rs`: 威胁管理
  - `transaction.rs`: 交易处理
  - `pinpad.rs`: PINPad 模式
  - `version.rs`: 版本管理
  - `audit.rs`: 审计日志
- `middleware/`: 中间件
  - `auth.rs`: JWT 认证
  - `rate_limit.rs`: 速率限制（令牌桶算法）
  - `logging.rs`: 结构化日志
  - `metrics.rs`: 性能指标
  - `tracing.rs`: 分布式追踪

**关键特性**:
- 统一的错误处理
- 请求/响应日志
- 性能指标收集
- 分布式追踪支持

#### 2.2.2 Business Logic Layer

**职责**: 实现核心业务逻辑，协调各个服务

**主要服务**:

1. **Device Service** (`services/device.rs`)
   - 设备注册和审批
   - 生命周期管理
   - 状态查询和统计

2. **Key Management Service** (`services/key_management.rs`)
   - DUKPT 密钥派生
   - 密钥注入和更新
   - 密钥状态管理

3. **Health Check Service** (`services/health_check.rs`)
   - 健康检查验证
   - 安全评分计算
   - 健康趋势分析

4. **Threat Detection Service** (`services/threat_detection.rs`)
   - 威胁自动检测
   - 严重性评估
   - 自动响应处理

5. **Transaction Service** (`services/transaction.rs`)
   - 交易鉴证
   - 交易处理
   - 交易令牌管理

6. **Version Service** (`services/version.rs`)
   - 版本创建和管理
   - 分发策略
   - 更新推送

7. **Audit Service** (`services/audit.rs`)
   - 操作日志记录
   - 日志查询和导出
   - 审计统计

#### 2.2.3 Data Access Layer

**职责**: 数据持久化和缓存管理

**Repository 模式**:
- 抽象数据访问逻辑
- 支持事务处理
- 缓存策略实现

**主要 Repository**:
- `DeviceRepository`: 设备数据访问
- `HealthCheckRepository`: 健康检查数据
- `ThreatRepository`: 威胁事件数据
- `TransactionRepository`: 交易数据
- `VersionRepository`: 版本数据
- `AuditRepository`: 审计日志数据

#### 2.2.4 Infrastructure Layer

**职责**: 提供基础设施支持

**主要组件**:
- `database.rs`: SQLite 连接池管理
- `redis.rs`: Redis 客户端封装
- `hsm_client.rs`: HSM 集成（FutureX）
- `config.rs`: 配置管理（YAML + 环境变量）

### 2.3 数据库设计

#### 核心表结构

```sql
-- 设备表
CREATE TABLE devices (
    device_id TEXT PRIMARY KEY,
    imei TEXT UNIQUE NOT NULL,
    model TEXT NOT NULL,
    os_version TEXT NOT NULL,
    app_version TEXT NOT NULL,
    tee_type TEXT NOT NULL,
    device_mode TEXT NOT NULL,  -- SOFTPOS | PINPAD
    status TEXT NOT NULL,       -- PENDING_APPROVAL | ACTIVE | SUSPENDED | REVOKED
    security_score INTEGER NOT NULL,
    public_key TEXT NOT NULL,
    ksn TEXT,
    key_remaining_count INTEGER,
    registered_at TIMESTAMP NOT NULL,
    approved_at TIMESTAMP,
    last_seen TIMESTAMP,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

-- 健康检查表
CREATE TABLE health_checks (
    check_id TEXT PRIMARY KEY,
    device_id TEXT NOT NULL,
    root_status BOOLEAN NOT NULL,
    debug_status BOOLEAN NOT NULL,
    hook_status BOOLEAN NOT NULL,
    emulator_status BOOLEAN NOT NULL,
    tee_status BOOLEAN NOT NULL,
    system_integrity BOOLEAN NOT NULL,
    app_integrity BOOLEAN NOT NULL,
    security_score INTEGER NOT NULL,
    result TEXT NOT NULL,
    checked_at TIMESTAMP NOT NULL,
    FOREIGN KEY (device_id) REFERENCES devices(device_id)
);

-- 威胁事件表
CREATE TABLE threat_events (
    threat_id TEXT PRIMARY KEY,
    device_id TEXT NOT NULL,
    threat_type TEXT NOT NULL,
    severity TEXT NOT NULL,
    status TEXT NOT NULL,
    description TEXT NOT NULL,
    detected_at TIMESTAMP NOT NULL,
    resolved_at TIMESTAMP,
    resolution TEXT,
    FOREIGN KEY (device_id) REFERENCES devices(device_id)
);

-- 交易表
CREATE TABLE transactions (
    transaction_id TEXT PRIMARY KEY,
    device_id TEXT NOT NULL,
    amount INTEGER NOT NULL,
    currency TEXT NOT NULL,
    status TEXT NOT NULL,
    processed_at TIMESTAMP NOT NULL,
    FOREIGN KEY (device_id) REFERENCES devices(device_id)
);
```

---

## 3. Frontend 架构

### 3.1 技术架构

```
┌─────────────────────────────────────────────────────────┐
│                   Presentation Layer                     │
│  - Pages (页面组件)                                      │
│  - Components (UI组件)                                   │
│  - Layouts (布局组件)                                    │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│                   Business Logic Layer                   │
│  - Hooks (自定义Hooks)                                   │
│  - Utils (工具函数)                                      │
│  - Types (类型定义)                                      │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│                   Data Access Layer                      │
│  - API Client (Axios)                                    │
│  - React Query (数据获取和缓存)                          │
│  - Zustand (状态管理)                                    │
└─────────────────────────────────────────────────────────┘
```

### 3.2 目录结构

```
src/
├── api/                    # API 调用
│   ├── client.ts          # Axios 配置
│   ├── auth.ts            # 认证 API
│   ├── devices.ts         # 设备 API
│   ├── threats.ts         # 威胁 API
│   ├── transactions.ts    # 交易 API
│   └── versions.ts        # 版本 API
├── components/            # 组件
│   ├── common/           # 通用组件
│   ├── layout/           # 布局组件
│   ├── charts/           # 图表组件
│   ├── devices/          # 设备相关组件
│   └── versions/         # 版本相关组件
├── hooks/                # 自定义 Hooks
│   ├── useDevices.ts
│   ├── useThreats.ts
│   └── useSDKVersions.ts
├── pages/                # 页面
│   ├── Dashboard/        # 仪表板
│   ├── Devices/          # 设备管理
│   ├── Threats/          # 威胁管理
│   ├── Transactions/     # 交易查询
│   ├── Logs/             # 日志查看
│   └── SDKVersions/      # 版本管理
├── types/                # 类型定义
├── utils/                # 工具函数
└── App.tsx               # 应用入口
```

### 3.3 状态管理

#### React Query
- 服务端状态管理
- 自动缓存和重新验证
- 乐观更新
- 分页和无限滚动

#### Zustand
- 客户端状态管理
- 用户认证状态
- UI 状态（主题、语言等）

### 3.4 路由设计

```typescript
/                          # 根路径，重定向到 /dashboard
/login                     # 登录页面
/dashboard                 # 仪表板
/devices                   # 设备列表
/devices/:id               # 设备详情
/devices/approval          # 设备审批
/threats                   # 威胁管理
/transactions              # 交易查询
/transactions/:id          # 交易详情
/logs                      # 系统日志
/sdk-versions              # SDK 版本列表
/sdk-versions/:id          # 版本详情
```

---

## 4. Android 架构

### 4.1 MVVM 架构

```
┌─────────────────────────────────────────────────────────┐
│                      View Layer                          │
│  - Jetpack Compose UI                                    │
│  - Screens (屏幕组件)                                    │
│  - Navigation (导航)                                     │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│                    ViewModel Layer                       │
│  - State Management (状态管理)                           │
│  - Business Logic (业务逻辑)                             │
│  - Event Handling (事件处理)                             │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│                     Model Layer                          │
│  - Data Models (数据模型)                                │
│  - Repositories (数据仓库)                               │
│  - Data Sources (数据源)                                 │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│                  Infrastructure Layer                    │
│  - Network (网络)                                        │
│  - TEE (安全环境)                                        │
│  - NFC (非接触式通信)                                    │
│  - Storage (本地存储)                                    │
└─────────────────────────────────────────────────────────┘
```

### 4.2 核心模块

#### 4.2.1 设备管理 (DeviceManager)
- 设备注册
- 设备信息管理
- 健康检查
- 状态同步

#### 4.2.2 密钥管理 (KeyManager)
- TEE 密钥对生成
- 密钥注入
- DUKPT 密钥派生
- 密钥更新

#### 4.2.3 交易处理 (TransactionManager)
- 交易鉴证
- NFC 读卡
- PIN 输入和加密
- 交易提交

#### 4.2.4 安全模块 (SecurityManager)
- Root 检测
- Hook 检测
- 调试检测
- TEE 完整性验证

---

## 5. 通信协议

### 5.1 RESTful API

#### 请求格式
```http
POST /api/v1/devices/register
Authorization: Bearer <token>
Content-Type: application/json

{
  "imei": "123456789012345",
  "model": "SUNMI P2",
  ...
}
```

#### 响应格式
```json
{
  "device_id": "dev-123",
  "status": "PENDING_APPROVAL",
  "ksn": "FFFF9876543210E00000"
}
```

#### 错误响应
```json
{
  "error_code": "DEVICE_NOT_FOUND",
  "error_message": "Device not found",
  "details": null
}
```

### 5.2 WebSocket 通知

#### 连接
```javascript
const ws = new WebSocket('ws://localhost:8080/ws');
```

#### 订阅主题
```json
{
  "type": "Subscribe",
  "topics": ["device.status", "threat.detected"]
}
```

#### 接收通知
```json
{
  "type": "Notification",
  "id": "notif-123",
  "topic": "device.status",
  "data": {
    "device_id": "dev-123",
    "old_status": "ACTIVE",
    "new_status": "SUSPENDED"
  },
  "timestamp": 1704110400
}
```

---

## 6. 安全架构

### 6.1 认证和授权

#### JWT Token 机制
```
Client → POST /auth/login → Server
       ← Access Token (2h)
       ← Refresh Token (7d)

Client → API Request + Access Token → Server
       ← Response

Access Token 过期 →
Client → POST /auth/refresh + Refresh Token → Server
       ← New Access Token
```

#### 角色权限
- **Admin**: 完全权限
- **Operator**: 操作权限（审批、管理）
- **Viewer**: 只读权限

### 6.2 数据加密

#### 传输加密
- TLS 1.3
- Certificate Pinning
- 请求签名验证

#### 存储加密
- 密钥 TEE 存储
- 敏感数据加密
- 数据库加密（可选）

### 6.3 密钥管理

#### DUKPT 密钥派生
```
BDK (Base Derivation Key)
  ↓
IPEK = DUKPT_Derive(BDK, Device_ID)
  ↓
Working Key = DUKPT_Derive(IPEK, KSN)
  ↓
PIN Block = Encrypt(PIN, Working Key)
```

---

## 7. 部署架构

### 7.1 单机部署

```
┌─────────────────────────────────────────┐
│           Server (Linux)                 │
│                                          │
│  ┌────────────────────────────────────┐ │
│  │  Nginx (Reverse Proxy)             │ │
│  │  - Frontend Static Files           │ │
│  │  - Backend API Proxy               │ │
│  └────────────────────────────────────┘ │
│                 ↓                        │
│  ┌────────────────────────────────────┐ │
│  │  Backend Service                   │ │
│  │  - Systemd Service                 │ │
│  │  - Port 8080                       │ │
│  └────────────────────────────────────┘ │
│                 ↓                        │
│  ┌────────────────────────────────────┐ │
│  │  SQLite Database                   │ │
│  │  - /var/lib/sunbay/sunbay.db       │ │
│  └────────────────────────────────────┘ │
│                                          │
│  ┌────────────────────────────────────┐ │
│  │  Redis (Optional)                  │ │
│  │  - Port 6379                       │ │
│  └────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

### 7.2 分布式部署

```
┌─────────────────────────────────────────┐
│         Load Balancer (Nginx)            │
└─────────────────────────────────────────┘
                    ↓
    ┌───────────────┴───────────────┐
    ↓                               ↓
┌─────────┐                   ┌─────────┐
│ Backend │                   │ Backend │
│ Node 1  │                   │ Node 2  │
└─────────┘                   └─────────┘
    ↓                               ↓
    └───────────────┬───────────────┘
                    ↓
        ┌───────────────────────┐
        │  Shared Database      │
        │  (PostgreSQL/MySQL)   │
        └───────────────────────┘
                    ↓
        ┌───────────────────────┐
        │  Redis Cluster        │
        └───────────────────────┘
```

---

## 8. 可观测性

### 8.1 日志

#### 结构化日志
```json
{
  "timestamp": "2024-01-01T12:00:00Z",
  "level": "INFO",
  "target": "sunbay_softpos_backend::api::handlers::device",
  "message": "Device registered successfully",
  "device_id": "dev-123",
  "request_id": "req-456"
}
```

#### 日志级别
- **ERROR**: 错误信息
- **WARN**: 警告信息
- **INFO**: 一般信息
- **DEBUG**: 调试信息
- **TRACE**: 详细追踪

### 8.2 指标

#### Prometheus 指标
- `http_requests_total`: 请求总数
- `http_request_duration_seconds`: 请求耗时
- `active_connections`: 活跃连接数
- `database_query_duration_seconds`: 数据库查询耗时
- `cache_hit_rate`: 缓存命中率

### 8.3 追踪

#### 分布式追踪
- Trace ID 传播
- Span 记录
- 调用链分析

---

## 9. 性能优化

### 9.1 Backend 优化

- **连接池**: 数据库连接池复用
- **缓存策略**: Redis 缓存热点数据
- **异步处理**: Tokio 异步运行时
- **批量操作**: 批量数据库操作
- **索引优化**: 数据库索引优化

### 9.2 Frontend 优化

- **代码分割**: 路由级别懒加载
- **缓存策略**: React Query 智能缓存
- **虚拟滚动**: 大列表虚拟化
- **图片优化**: 图片懒加载和压缩
- **CDN 加速**: 静态资源 CDN 分发

### 9.3 Android 优化

- **内存管理**: 及时释放资源
- **网络优化**: 请求合并和缓存
- **UI 优化**: Compose 性能优化
- **电池优化**: 后台任务优化

---

## 10. 扩展性设计

### 10.1 水平扩展

- **无状态设计**: Backend 服务无状态
- **负载均衡**: Nginx/HAProxy 负载均衡
- **数据库分片**: 按设备 ID 分片
- **缓存集群**: Redis 集群

### 10.2 功能扩展

- **插件机制**: 支持功能插件
- **配置驱动**: 配置化功能开关
- **版本兼容**: API 版本控制
- **数据迁移**: 平滑数据迁移

---

**下一步**: 查看 [API 完整参考](./03-API-REFERENCE.md) 了解详细的 API 规范
