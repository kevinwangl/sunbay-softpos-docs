# SUNBAY SoftPOS 开发者入门

## 概述

本文档帮助新开发者快速了解项目结构、开发环境搭建和开发规范。

---

## 1. 快速开始

### 1.1 克隆项目

```bash
git clone <repository-url>
cd SoftPOS
```

### 1.2 项目结构

```
SoftPOS/
├── sunbay-softpos-backend/    # Backend (Rust)
├── sunbay-softpos-frontend/   # Frontend (React)
├── sunbay-softpos-android/    # Android (Kotlin)
└── docs/                      # 文档
    └── solution/              # 方案文档
```

---

## 2. Backend 开发

### 2.1 环境搭建

```bash
# 安装 Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# 进入项目
cd sunbay-softpos-backend

# 构建
cargo build

# 运行
cargo run
```

### 2.2 代码结构

详细说明请参考：[Backend README](../../sunbay-softpos-backend/README.md)

### 2.3 开发规范

- 使用 `cargo fmt` 格式化代码
- 使用 `cargo clippy` 检查代码
- 编写单元测试和集成测试

---

## 3. Frontend 开发

### 3.1 环境搭建

```bash
cd sunbay-softpos-frontend
npm install
npm run dev
```

### 3.2 代码结构

详细说明请参考：[Frontend README](../../sunbay-softpos-frontend/README.md)

### 3.3 开发规范

- 使用 TypeScript
- 遵循 ESLint 规则
- 组件化开发

---

## 4. Android 开发

### 4.1 环境搭建

1. 安装 Android Studio
2. 打开项目 `sunbay-softpos-android`
3. 同步 Gradle
4. 运行应用

### 4.2 代码结构

详细说明请参考：[Android BUILD_GUIDE](../../sunbay-softpos-android/BUILD_GUIDE.md)

### 4.3 开发规范

- 使用 Kotlin
- MVVM 架构
- Jetpack Compose UI

---

## 5. 开发流程

### 5.1 分支管理

- `main`: 主分支
- `develop`: 开发分支
- `feature/*`: 功能分支
- `bugfix/*`: 修复分支

### 5.2 提交规范

```
feat: 新功能
fix: 修复
docs: 文档
style: 格式
refactor: 重构
test: 测试
chore: 构建
```

---

## 6. 测试

### 6.1 Backend 测试

```bash
cd sunbay-softpos-backend
cargo test
```

### 6.2 Frontend 测试

```bash
cd sunbay-softpos-frontend
npm test
```

---

## 7. 调试

### 7.1 Backend 调试

使用 VS Code 或 IntelliJ IDEA 的 Rust 插件。

### 7.2 Frontend 调试

使用浏览器开发者工具。

### 7.3 Android 调试

使用 Android Studio 调试器。

---

## 8. 相关资源

- [Backend 完整文档](../../sunbay-softpos-backend/)
- [Frontend 完整文档](../../sunbay-softpos-frontend/)
- [Android 完整文档](../../sunbay-softpos-android/)
- [项目总结](../../PROJECT_FINAL_SUMMARY.md)

---

**下一步**: 查看 [术语表](./09-GLOSSARY.md)
