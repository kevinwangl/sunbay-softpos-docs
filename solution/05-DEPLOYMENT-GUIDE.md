# SUNBAY SoftPOS 部署指南

## 概述

本文档提供 SUNBAY SoftPOS 系统的完整部署指南，包括环境要求、部署步骤和配置说明。

---

## 1. 环境要求

### 1.1 Backend

- **操作系统**: Linux (Ubuntu 20.04+ / CentOS 8+)
- **Rust**: 1.75+
- **SQLite**: 3.40+
- **Redis**: 7+ (可选)
- **内存**: 最低 2GB，推荐 4GB+
- **磁盘**: 最低 10GB

### 1.2 Frontend

- **Node.js**: 18+
- **npm**: 9+
- **Web 服务器**: Nginx / Apache

### 1.3 Android

- **Android Studio**: 2023.1+
- **Kotlin**: 1.9+
- **Android SDK**: API 26+ (Android 8.0+)
- **设备要求**: 支持 NFC 和 TEE

---

## 2. Backend 部署

### 2.1 构建

```bash
cd sunbay-softpos-backend
cargo build --release
```

### 2.2 配置

```bash
cp .env.example .env
# 编辑 .env 文件
```

### 2.3 运行

```bash
# 直接运行
./target/release/sunbay-softpos-backend

# 使用 systemd
sudo cp deploy/sunbay-softpos-backend.service /etc/systemd/system/
sudo systemctl enable sunbay-softpos-backend
sudo systemctl start sunbay-softpos-backend
```

详细部署脚本请参考：[deploy.sh](../../sunbay-softpos-backend/deploy.sh)

---

## 3. Frontend 部署

### 3.1 构建

```bash
cd sunbay-softpos-frontend
npm install
npm run build
```

### 3.2 部署到 Nginx

```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    root /var/www/sunbay-frontend/dist;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    location /api {
        proxy_pass http://localhost:8080;
    }
}
```

---

## 4. Android 部署

### 4.1 构建

```bash
cd sunbay-softpos-android
./gradlew assembleRelease
```

### 4.2 签名和发布

详细指南请参考：[BUILD_GUIDE.md](../../sunbay-softpos-android/BUILD_GUIDE.md)

---

## 5. 监控和日志

### 5.1 日志位置

- Backend: `/var/log/sunbay/backend.log`
- Systemd: `journalctl -u sunbay-softpos-backend`

### 5.2 健康检查

```bash
curl http://localhost:8080/health/check
```

---

**下一步**: 查看 [运维手册](./06-OPERATIONS-MANUAL.md)
