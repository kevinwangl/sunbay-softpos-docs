# SUNBAY SoftPOS 运维手册

## 概述

本文档提供日常运维操作指南、故障排查和性能优化建议。

---

## 1. 日常运维

### 1.1 服务管理

```bash
# 启动服务
sudo systemctl start sunbay-softpos-backend

# 停止服务
sudo systemctl stop sunbay-softpos-backend

# 重启服务
sudo systemctl restart sunbay-softpos-backend

# 查看状态
sudo systemctl status sunbay-softpos-backend
```

### 1.2 日志查看

```bash
# 查看实时日志
sudo journalctl -u sunbay-softpos-backend -f

# 查看最近日志
sudo journalctl -u sunbay-softpos-backend -n 100
```

---

## 2. 故障排查

### 2.1 服务无法启动

1. 检查配置文件
2. 检查数据库连接
3. 检查端口占用
4. 查看错误日志

### 2.2 性能问题

1. 检查 CPU 和内存使用
2. 检查数据库查询性能
3. 检查 Redis 连接
4. 查看 Prometheus 指标

---

## 3. 备份和恢复

### 3.1 数据库备份

```bash
# 备份 SQLite 数据库
cp /var/lib/sunbay/sunbay.db /backup/sunbay-$(date +%Y%m%d).db
```

### 3.2 恢复

```bash
# 恢复数据库
cp /backup/sunbay-20240101.db /var/lib/sunbay/sunbay.db
sudo systemctl restart sunbay-softpos-backend
```

---

## 4. 性能优化

### 4.1 数据库优化

- 定期 VACUUM
- 添加索引
- 查询优化

### 4.2 缓存优化

- 调整 Redis 配置
- 优化缓存策略
- 监控缓存命中率

---

**下一步**: 查看 [用户指南](./07-USER-GUIDE.md)
