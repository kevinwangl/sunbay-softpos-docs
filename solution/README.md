# SUNBAY SoftPOS 整体方案文档

## 文档导航

本目录包含 SUNBAY SoftPOS 系统的完整方案文档，面向不同受众提供系统的全方位说明。

### 📋 核心文档（所有人）

1. **[整体方案概述](./01-SOLUTION-OVERVIEW.md)** ⭐ 推荐首先阅读
   - 系统简介和核心价值
   - 整体架构设计
   - 技术栈总览
   - 适用场景

### 🏗️ 技术文档（开发团队）

2. **[系统架构设计](./02-ARCHITECTURE.md)**
   - 三端架构详解（Android/Frontend/Backend）
   - 数据流设计
   - 安全架构
   - 通信协议

3. **[API 完整参考](./03-API-REFERENCE.md)**
   - RESTful API 规范
   - WebSocket 通知
   - 请求/响应示例
   - 错误处理

4. **[客户端 API 使用指南](./CLIENT_API_USAGE_GUIDE.md)** 🆕
   - Android App 使用的 API
   - WebKernel Demo 使用的 API
   - 完整调用流程
   - 代码示例 (Kotlin/TypeScript)

5. **[MPoC SDK API 交互指南](./MPOC_SDK_API_GUIDE.md)** 🆕
   - Android MPoC SDK 专用文档
   - SDK 模块结构
   - 完整初始化和交易流程
   - PIN 加密方案 (DUKPT/ECC)

5. **[安全设计文档](./04-SECURITY-DESIGN.md)**
   - 密钥管理（KSN、DUKPT）
   - 设备认证（Attestation）
   - 威胁检测机制
   - 交易令牌流程

6. **[PIN 加密安全处理方案](./PIN_ENCRYPTION_SECURITY_DESIGN.md)** 🆕
   - WhiteBox DH-ECC 加密方案
   - Futurex CloudHSM 集成
   - PIN 转加密流程 (ECC → ZPK)
   - 多 Processor 对接 (TSYS/Fiserv/Elavon)
   - PCI PIN 合规要求

### 🚀 部署运维文档（运维团队）

7. **[部署指南](./05-DEPLOYMENT-GUIDE.md)**
   - 环境要求
   - 部署步骤
   - 配置说明
   - 监控和日志

8. **[运维手册](./06-OPERATIONS-MANUAL.md)**
   - 日常运维流程
   - 故障排查
   - 性能优化
   - 备份恢复

### 📱 用户文档（使用者）

9. **[用户指南](./07-USER-GUIDE.md)**
   - 管理后台使用说明
   - Android 应用使用说明
   - 常见问题解答

### 👨‍💻 开发文档（新开发者）

10. **[开发者入门](./08-DEVELOPER-ONBOARDING.md)**
   - 快速开始
   - 开发环境搭建
   - 代码结构说明
   - 开发规范

### 📊 附录

11. **[术语表](./09-GLOSSARY.md)**
    - 技术术语解释
    - 缩写说明

12. **[更新日志](./10-CHANGELOG.md)**
    - 版本历史
    - 功能更新记录

---

## 快速导航

### 我是...

- **产品经理/管理层** → 从 [整体方案概述](./01-SOLUTION-OVERVIEW.md) 开始
- **架构师** → 查看 [系统架构设计](./02-ARCHITECTURE.md)
- **后端开发** → 参考 [API 完整参考](./03-API-REFERENCE.md) 和 [客户端 API 使用指南](./CLIENT_API_USAGE_GUIDE.md)
- **安全工程师** → 阅读 [安全设计文档](./04-SECURITY-DESIGN.md) 和 [PIN 加密安全方案](./PIN_ENCRYPTION_SECURITY_DESIGN.md)
- **运维工程师** → 查看 [部署指南](./05-DEPLOYMENT-GUIDE.md) 和 [运维手册](./06-OPERATIONS-MANUAL.md)
- **Android 开发** → 参考 [客户端 API 使用指南](./CLIENT_API_USAGE_GUIDE.md) 和 [开发者入门](./08-DEVELOPER-ONBOARDING.md)
- **前端开发** → 参考 [客户端 API 使用指南](./CLIENT_API_USAGE_GUIDE.md) 和 [开发者入门](./08-DEVELOPER-ONBOARDING.md)
- **新加入团队** → 从 [开发者入门](./08-DEVELOPER-ONBOARDING.md) 开始

---

## 项目状态

**当前版本**: v2.1  
**完成度**: 88%  
**状态**: ✅ 生产就绪

| 模块 | 完成度 | 状态 |
|------|--------|------|
| Backend | 100% | ✅ 完成 |
| Frontend | 83% | ✅ 完成 |
| Android | 95% | ✅ 完成 |
| Kernel Service | 100% | ✅ 完成 |
| WebKernel Demo | 100% | ✅ 完成 |

---

## 技术栈概览

### Backend
- **语言**: Rust
- **框架**: Axum
- **数据库**: SQLite + Redis
- **安全**: JWT, DUKPT, HSM

### Frontend
- **语言**: TypeScript
- **框架**: React + Vite
- **UI**: Ant Design
- **图表**: ECharts

### Android
- **语言**: Kotlin
- **架构**: MVVM + Jetpack Compose
- **安全**: TEE, Hardware Attestation
- **支付**: EMV L2 Kernel

---

## 联系方式

- **技术支持**: [待定]
- **问题反馈**: [GitHub Issues]
- **文档更新**: 2024年12月

---

## 文档版本

- **版本**: 2.1
- **最后更新**: 2024-12-30
- **维护者**: SUNBAY 技术团队
