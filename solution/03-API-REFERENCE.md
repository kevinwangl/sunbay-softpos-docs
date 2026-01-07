# SUNBAY SoftPOS API 完整参考

## 概述

本文档提供 SUNBAY SoftPOS Backend API 的完整参考。所有 API 遵循 RESTful 设计原则，使用 JSON 格式进行数据交换。

**完整 API 文档**: 请参考 [`sunbay-softpos-backend/API_DOCUMENTATION.md`](../../sunbay-softpos-backend/API_DOCUMENTATION.md)

---

## 基础信息

- **Base URL**: `http://localhost:8080/api/v1`
- **Content-Type**: `application/json`
- **认证方式**: JWT Bearer Token
- **API 版本**: v1

---

## 快速导航

### 核心 API 模块

1. [认证 API](#1-认证-api) - 用户登录、Token 管理
2. [设备管理 API](#2-设备管理-api) - 设备注册、审批、生命周期管理
3. [密钥管理 API](#3-密钥管理-api) - 密钥注入、更新、状态查询
4. [健康检查 API](#4-健康检查-api) - 健康检查提交和查询
5. [威胁管理 API](#5-威胁管理-api) - 威胁检测和处理
6. [交易处理 API](#6-交易处理-api) - 交易鉴证和处理
7. [PINPad 模式 API](#7-pinpad-模式-api) - PIN 加密服务
8. [版本管理 API](#8-版本管理-api) - SDK 版本管理
9. [审计日志 API](#9-审计日志-api) - 操作日志查询
10. [系统 API](#10-系统-api) - 健康检查、指标、WebSocket

---

## 1. 认证 API

### 1.1 用户登录

```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "username": "admin",
  "password": "password123"
}
```

**响应**:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "Bearer",
  "expires_in": 7200
}
```

### 1.2 刷新 Token

```http
POST /api/v1/auth/refresh
Authorization: Bearer <refresh_token>
```

### 1.3 用户登出

```http
POST /api/v1/auth/logout
Authorization: Bearer <access_token>
```

---

## 2. 设备管理 API

### 2.1 注册设备

```http
POST /api/v1/devices/register
Content-Type: application/json

{
  "imei": "123456789012345",
  "model": "SUNMI P2",
  "os_version": "Android 11",
  "app_version": "1.0.0",
  "tee_type": "TEE",
  "device_mode": "SOFTPOS",
  "public_key": "-----BEGIN PUBLIC KEY-----\n...",
  "health_check": {
    "root_status": false,
    "debug_status": false,
    "hook_status": false,
    "emulator_status": false,
    "tee_status": true,
    "system_integrity": true,
    "app_integrity": true
  }
}
```

**响应**:
```json
{
  "device_id": "dev-550e8400-e29b-41d4-a716-446655440000",
  "status": "PENDING_APPROVAL",
  "ksn": "FFFF9876543210E00000",
  "security_score": 95,
  "registered_at": "2024-01-01T12:00:00Z"
}
```

### 2.2 查询设备列表

```http
GET /api/v1/devices?status=ACTIVE&page=1&page_size=20
Authorization: Bearer <access_token>
```

### 2.3 获取设备详情

```http
GET /api/v1/devices/:device_id
Authorization: Bearer <access_token>
```

### 2.4 审批设备

```http
POST /api/v1/devices/:device_id/approve
Authorization: Bearer <access_token>
```

### 2.5 设备生命周期管理

- `POST /api/v1/devices/:device_id/reject` - 拒绝设备
- `POST /api/v1/devices/:device_id/suspend` - 暂停设备
- `POST /api/v1/devices/:device_id/resume` - 恢复设备
- `POST /api/v1/devices/:device_id/revoke` - 吊销设备

### 2.6 设备统计

```http
GET /api/v1/devices/statistics
Authorization: Bearer <access_token>
```

---

## 3. 密钥管理 API

### 3.1 密钥注入

```http
POST /api/v1/keys/inject
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "device_id": "dev-550e8400-e29b-41d4-a716-446655440000",
  "key_type": "IPEK",
  "bdk": "0123456789ABCDEFFEDCBA9876543210"
}
```

### 3.2 查询密钥状态

```http
GET /api/v1/keys/:device_id/status
Authorization: Bearer <access_token>
```

### 3.3 更新密钥

```http
POST /api/v1/keys/:device_id/update
Authorization: Bearer <access_token>
```

---

## 4. 健康检查 API

### 4.1 提交健康检查

```http
POST /api/v1/health-checks
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "device_id": "dev-550e8400-e29b-41d4-a716-446655440000",
  "root_status": false,
  "debug_status": false,
  "hook_status": false,
  "emulator_status": false,
  "tee_status": true,
  "system_integrity": true,
  "app_integrity": true,
  "signature": "base64_encoded_signature"
}
```

### 4.2 查询健康检查记录

```http
GET /api/v1/health-checks?device_id=dev-123&start_date=2024-01-01
Authorization: Bearer <access_token>
```

### 4.3 获取健康概览

```http
GET /api/v1/health-checks/overview
Authorization: Bearer <access_token>
```

---

## 5. 威胁管理 API

### 5.1 查询威胁列表

```http
GET /api/v1/threats?severity=HIGH&status=ACTIVE
Authorization: Bearer <access_token>
```

### 5.2 获取威胁详情

```http
GET /api/v1/threats/:threat_id
Authorization: Bearer <access_token>
```

### 5.3 解决威胁

```http
POST /api/v1/threats/:threat_id/resolve
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "resolution": "Device has been re-secured and verified"
}
```

### 5.4 威胁统计

```http
GET /api/v1/threats/statistics
Authorization: Bearer <access_token>
```

---

## 6. 交易处理 API

### 6.1 交易鉴证

```http
POST /api/v1/transactions/attest
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "device_id": "dev-550e8400-e29b-41d4-a716-446655440000",
  "amount": 10000,
  "currency": "CNY"
}
```

**响应**:
```json
{
  "transaction_token": "eyJhbGciOiJIUzI1NiIs...",
  "expires_at": "2024-01-01T14:05:00Z",
  "device_status": "ACTIVE",
  "security_score": 95
}
```

### 6.2 处理交易

```http
POST /api/v1/transactions/process
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "transaction_token": "eyJhbGciOiJIUzI1NiIs...",
  "encrypted_pin_block": "base64_encoded_pin_block",
  "ksn": "FFFF9876543210E00001",
  "card_number": "6222021234567890",
  "amount": 10000,
  "currency": "CNY"
}
```

### 6.3 查询交易记录

```http
GET /api/v1/transactions?device_id=dev-123&start_date=2024-01-01
Authorization: Bearer <access_token>
```

---

## 7. PINPad 模式 API

### 7.1 PINPad 设备鉴证

```http
POST /api/v1/pinpad/attest
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "device_id": "dev-550e8400-e29b-41d4-a716-446655440000"
}
```

### 7.2 PIN 加密

```http
POST /api/v1/pinpad/encrypt-pin
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "device_id": "dev-550e8400-e29b-41d4-a716-446655440000",
  "pin": "1234",
  "card_number": "6222021234567890"
}
```

### 7.3 查询 PIN 加密日志

```http
GET /api/v1/pinpad/logs?device_id=dev-123
Authorization: Bearer <access_token>
```

---

## 8. 版本管理 API

### 8.1 创建版本

```http
POST /api/v1/versions
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "version_number": "1.2.0",
  "update_type": "MINOR",
  "description": "Bug fixes and performance improvements",
  "download_url": "https://cdn.example.com/app-1.2.0.apk",
  "file_size": 52428800,
  "checksum": "sha256:abc123...",
  "min_os_version": "Android 8.0",
  "release_notes": "- Fixed crash on startup\n- Improved performance"
}
```

### 8.2 查询版本列表

```http
GET /api/v1/versions?status=ACTIVE
Authorization: Bearer <access_token>
```

### 8.3 推送版本更新

```http
POST /api/v1/versions/push
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "version_id": "ver-123",
  "target_devices": ["dev-123", "dev-456"],
  "force_update": false
}
```

---

## 9. 审计日志 API

### 9.1 查询审计日志

```http
GET /api/v1/audit-logs?operation=DEVICE_APPROVAL&start_date=2024-01-01
Authorization: Bearer <access_token>
```

**查询参数**:
- `operation`: 操作类型
- `user_id`: 用户 ID
- `device_id`: 设备 ID
- `start_date`: 开始日期
- `end_date`: 结束日期

---

## 10. 系统 API

### 10.1 健康检查

```http
GET /health/check
```

**响应**:
```json
{
  "status": "healthy",
  "version": "0.1.0",
  "uptime": 3600,
  "database": "connected",
  "redis": "connected"
}
```

### 10.2 Prometheus 指标

```http
GET /metrics
```

### 10.3 WebSocket 连接

```http
GET /ws
Upgrade: websocket
```

---

## WebSocket 通知

### 连接示例

```javascript
const ws = new WebSocket('ws://localhost:8080/ws');

ws.onopen = () => {
  // 订阅主题
  ws.send(JSON.stringify({
    type: 'Subscribe',
    topics: ['device.status', 'threat.detected']
  }));
};

ws.onmessage = (event) => {
  const notification = JSON.parse(event.data);
  console.log('Received:', notification);
};
```

### 可用主题

- `device.status` - 设备状态变更
- `device.registered` - 设备注册
- `device.approved` - 设备审批
- `threat.detected` - 威胁检测
- `threat.resolved` - 威胁解决
- `health.failed` - 健康检查失败
- `key.injected` - 密钥注入
- `transaction.processed` - 交易处理
- `version.pushed` - 版本推送
- `system.alert` - 系统告警

---

## 错误处理

### 错误响应格式

```json
{
  "error_code": "ERROR_CODE",
  "error_message": "Human readable error message",
  "details": "Optional additional details"
}
```

### 常见错误码

| 错误码 | HTTP 状态码 | 说明 |
|--------|------------|------|
| `UNAUTHORIZED` | 401 | 未认证或 Token 无效 |
| `FORBIDDEN` | 403 | 权限不足 |
| `NOT_FOUND` | 404 | 资源不存在 |
| `VALIDATION_ERROR` | 400 | 请求参数验证失败 |
| `DEVICE_NOT_FOUND` | 404 | 设备不存在 |
| `DEVICE_ALREADY_EXISTS` | 409 | 设备已存在 |
| `INVALID_DEVICE_STATUS` | 400 | 设备状态无效 |
| `KEY_NOT_FOUND` | 404 | 密钥不存在 |
| `TRANSACTION_TOKEN_EXPIRED` | 401 | 交易令牌过期 |
| `INTERNAL_ERROR` | 500 | 服务器内部错误 |

---

## 速率限制

API 实施速率限制以防止滥用：

- **默认限制**: 每秒 100 请求
- **突发限制**: 200 请求
- **超出限制**: 返回 `429 Too Many Requests`

响应头包含速率限制信息：
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1704110400
```

---

## 分页

支持分页的端点使用以下参数：

- `page`: 页码（从 1 开始）
- `page_size`: 每页数量（默认 20，最大 100）

响应包含分页信息：
```json
{
  "data": [...],
  "total": 1000,
  "page": 1,
  "page_size": 20,
  "total_pages": 50
}
```

---

## API 测试

### 使用 curl

```bash
# 登录
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"password123"}'

# 查询设备列表
curl -X GET http://localhost:8080/api/v1/devices \
  -H "Authorization: Bearer <token>"
```

### 使用 Postman

1. 导入 API 集合
2. 设置环境变量（base_url, token）
3. 执行请求

---

## 更多信息

- **完整 API 文档**: [`sunbay-softpos-backend/API_DOCUMENTATION.md`](../../sunbay-softpos-backend/API_DOCUMENTATION.md)
- **Backend README**: [`sunbay-softpos-backend/README.md`](../../sunbay-softpos-backend/README.md)
- **开发指南**: [开发者入门](./08-DEVELOPER-ONBOARDING.md)

---

**下一步**: 查看 [安全设计文档](./04-SECURITY-DESIGN.md) 了解安全机制
