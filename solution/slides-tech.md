---
theme: default
background: https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=1920
class: text-center
highlighter: shiki
lineNumbers: false
drawings:
  persist: false
transition: slide-left
title: SUNBAY SoftPOS - 企业级移动支付终端管理平台
mdc: true
colorSchema: dark
fonts:
  sans: 'Inter'
  mono: 'Fira Code'
---

<div class="flex flex-col items-center justify-center h-full">
  <div class="text-8xl font-bold mb-8 bg-gradient-to-r from-orange-500 via-red-500 to-pink-500 bg-clip-text text-transparent">
    SUNBAY
  </div>
  <div class="text-4xl font-light mb-4 text-gray-300">
    SoftPOS
  </div>
  <div class="text-xl text-gray-400 mb-12">
    企业级移动支付终端管理平台
  </div>
  <div class="flex gap-8 text-sm text-gray-500">
    <div class="flex items-center gap-2">
      <carbon-security class="text-orange-500" />
      <span>金融级安全</span>
    </div>
    <div class="flex items-center gap-2">
      <carbon-chip class="text-blue-500" />
      <span>现代化技术</span>
    </div>
    <div class="flex items-center gap-2">
      <carbon-cloud class="text-green-500" />
      <span>云端管理</span>
    </div>
  </div>
</div>

---
layout: center
class: text-center
---

# 核心数据

<div class="grid grid-cols-4 gap-8 mt-16">
  <div v-click class="relative">
    <div class="absolute inset-0 bg-gradient-to-br from-orange-500/20 to-transparent rounded-lg blur-xl"></div>
    <div class="relative bg-gray-900/50 backdrop-blur p-8 rounded-lg border border-orange-500/30">
      <div class="text-6xl font-bold text-orange-500 mb-2">3</div>
      <div class="text-sm text-gray-400">平台</div>
    </div>
  </div>
  
  <div v-click class="relative">
    <div class="absolute inset-0 bg-gradient-to-br from-blue-500/20 to-transparent rounded-lg blur-xl"></div>
    <div class="relative bg-gray-900/50 backdrop-blur p-8 rounded-lg border border-blue-500/30">
      <div class="text-6xl font-bold text-blue-500 mb-2">60+</div>
      <div class="text-sm text-gray-400">API</div>
    </div>
  </div>
  
  <div v-click class="relative">
    <div class="absolute inset-0 bg-gradient-to-br from-green-500/20 to-transparent rounded-lg blur-xl"></div>
    <div class="relative bg-gray-900/50 backdrop-blur p-8 rounded-lg border border-green-500/30">
      <div class="text-6xl font-bold text-green-500 mb-2">18K+</div>
      <div class="text-sm text-gray-400">代码行</div>
    </div>
  </div>
  
  <div v-click class="relative">
    <div class="absolute inset-0 bg-gradient-to-br from-purple-500/20 to-transparent rounded-lg blur-xl"></div>
    <div class="relative bg-gray-900/50 backdrop-blur p-8 rounded-lg border border-purple-500/30">
      <div class="text-6xl font-bold text-purple-500 mb-2">91%</div>
      <div class="text-sm text-gray-400">完成度</div>
    </div>
  </div>
</div>

---
layout: center
---

# 系统架构

<div class="flex items-center justify-center h-full">

```mermaid {theme: 'dark', scale: 1.2}
graph TB
    subgraph "终端层"
        A[Android 终端<br/>NFC • EMV • TEE]
    end
    
    subgraph "服务层"
        B[Backend 服务<br/>Rust • Axum • 60+ API]
    end
    
    subgraph "管理层"
        C[Web 管理后台<br/>React • TypeScript]
    end
    
    subgraph "数据层"
        D[(SQLite)]
        E[(Redis)]
    end
    
    A <-->|REST API<br/>WebSocket| B
    B <-->|REST API| C
    B --> D
    B --> E
    
    style A fill:#ff6000,stroke:#ff6000,color:#fff
    style B fill:#1890ff,stroke:#1890ff,color:#fff
    style C fill:#52c41a,stroke:#52c41a,color:#fff
    style D fill:#faad14,stroke:#faad14,color:#fff
    style E fill:#f5222d,stroke:#f5222d,color:#fff
```

</div>

---
layout: two-cols
class: px-8
---

# Backend 架构

<div class="space-y-4 mt-8">

<div v-click class="relative group">
  <div class="absolute inset-0 bg-gradient-to-r from-orange-500/10 to-transparent rounded-lg"></div>
  <div class="relative p-4 border-l-4 border-orange-500">
    <div class="font-bold text-orange-500 mb-1">API Layer</div>
    <div class="text-sm text-gray-400">60+ RESTful API • WebSocket</div>
  </div>
</div>

<div v-click class="relative group">
  <div class="absolute inset-0 bg-gradient-to-r from-blue-500/10 to-transparent rounded-lg"></div>
  <div class="relative p-4 border-l-4 border-blue-500">
    <div class="font-bold text-blue-500 mb-1">Business Logic</div>
    <div class="text-sm text-gray-400">7 个核心服务</div>
  </div>
</div>

<div v-click class="relative group">
  <div class="absolute inset-0 bg-gradient-to-r from-green-500/10 to-transparent rounded-lg"></div>
  <div class="relative p-4 border-l-4 border-green-500">
    <div class="font-bold text-green-500 mb-1">Data Access</div>
    <div class="text-sm text-gray-400">6 个 Repository</div>
  </div>
</div>

<div v-click class="relative group">
  <div class="absolute inset-0 bg-gradient-to-r from-purple-500/10 to-transparent rounded-lg"></div>
  <div class="relative p-4 border-l-4 border-purple-500">
    <div class="font-bold text-purple-500 mb-1">Infrastructure</div>
    <div class="text-sm text-gray-400">SQLite • Redis • HSM</div>
  </div>
</div>

</div>

::right::

<div class="pl-8 mt-8">

## 核心服务

<div class="space-y-3 mt-8 text-sm">

<div v-click class="flex items-center gap-3 p-3 bg-gray-900/30 rounded-lg border border-gray-700/50">
  <carbon-security class="text-orange-500 text-xl" />
  <div>
    <div class="font-semibold">设备服务</div>
    <div class="text-xs text-gray-500">注册 • 审批 • 生命周期</div>
  </div>
</div>

<div v-click class="flex items-center gap-3 p-3 bg-gray-900/30 rounded-lg border border-gray-700/50">
  <carbon-password class="text-blue-500 text-xl" />
  <div>
    <div class="font-semibold">密钥管理</div>
    <div class="text-xs text-gray-500">DUKPT • 注入 • 更新</div>
  </div>
</div>

<div v-click class="flex items-center gap-3 p-3 bg-gray-900/30 rounded-lg border border-gray-700/50">
  <carbon-health-cross class="text-green-500 text-xl" />
  <div>
    <div class="font-semibold">健康检查</div>
    <div class="text-xs text-gray-500">评分 • 监控 • 分析</div>
  </div>
</div>

<div v-click class="flex items-center gap-3 p-3 bg-gray-900/30 rounded-lg border border-gray-700/50">
  <carbon-warning class="text-red-500 text-xl" />
  <div>
    <div class="font-semibold">威胁检测</div>
    <div class="text-xs text-gray-500">检测 • 评估 • 响应</div>
  </div>
</div>

<div v-click class="flex items-center gap-3 p-3 bg-gray-900/30 rounded-lg border border-gray-700/50">
  <carbon-purchase class="text-purple-500 text-xl" />
  <div>
    <div class="font-semibold">交易服务</div>
    <div class="text-xs text-gray-500">鉴证 • 处理 • 令牌</div>
  </div>
</div>

</div>

</div>

---
layout: center
---

# 密钥管理 - DUKPT

<div class="flex items-center justify-center h-full">

```mermaid {theme: 'dark', scale: 1.3}
graph LR
    A[BDK<br/>基础派生密钥] -->|派生| B[IPEK<br/>初始加密密钥]
    B -->|派生| C[Working Key<br/>工作密钥]
    C -->|加密| D[PIN Block<br/>加密PIN]
    
    style A fill:#ff6000,stroke:#ff6000,color:#fff
    style B fill:#1890ff,stroke:#1890ff,color:#fff
    style C fill:#52c41a,stroke:#52c41a,color:#fff
    style D fill:#faad14,stroke:#faad14,color:#fff
```

</div>

<div class="absolute bottom-8 left-0 right-0 text-center">
  <div class="inline-flex items-center gap-4 text-sm text-gray-500">
    <div class="flex items-center gap-2">
      <carbon-locked class="text-orange-500" />
      <span>TEE 安全存储</span>
    </div>
    <div class="flex items-center gap-2">
      <carbon-encryption class="text-blue-500" />
      <span>RSA-2048 加密</span>
    </div>
    <div class="flex items-center gap-2">
      <carbon-certificate-check class="text-green-500" />
      <span>ANSI X9.24 标准</span>
    </div>
  </div>
</div>

---
layout: center
---

# 交易处理流程

```mermaid {theme: 'dark', scale: 0.9}
sequenceDiagram
    participant A as Android
    participant B as Backend
    participant C as 银行
    
    A->>B: 1️⃣ 交易鉴证
    activate B
    B->>B: 2️⃣ 健康检查
    B-->>A: 3️⃣ 返回令牌
    deactivate B
    
    activate A
    A->>A: 4️⃣ NFC 读卡
    A->>A: 5️⃣ PIN 加密
    A->>B: 6️⃣ 交易提交
    deactivate A
    
    activate B
    B->>C: 7️⃣ 授权请求
    activate C
    C-->>B: 8️⃣ 授权结果
    deactivate C
    B-->>A: 9️⃣ 返回结果
    deactivate B
```

---
layout: center
class: text-center
---

# 安全保障

<div class="grid grid-cols-2 gap-8 mt-16 px-16">

<div v-click class="relative">
  <div class="absolute inset-0 bg-gradient-to-br from-orange-500/20 to-transparent rounded-xl blur-2xl"></div>
  <div class="relative bg-gray-900/50 backdrop-blur p-8 rounded-xl border border-orange-500/30">
    <carbon-security class="text-5xl text-orange-500 mb-4 mx-auto" />
    <div class="text-2xl font-bold mb-2">多层防护</div>
    <div class="text-sm text-gray-400 space-y-1">
      <div>应用层 • 传输层</div>
      <div>数据层 • 设备层</div>
    </div>
  </div>
</div>

<div v-click class="relative">
  <div class="absolute inset-0 bg-gradient-to-br from-blue-500/20 to-transparent rounded-xl blur-2xl"></div>
  <div class="relative bg-gray-900/50 backdrop-blur p-8 rounded-xl border border-blue-500/30">
    <carbon-certificate-check class="text-5xl text-blue-500 mb-4 mx-auto" />
    <div class="text-2xl font-bold mb-2">国际标准</div>
    <div class="text-sm text-gray-400 space-y-1">
      <div>PCI MPoC</div>
      <div>ISO 9564 • ANSI X9.24</div>
    </div>
  </div>
</div>

<div v-click class="relative">
  <div class="absolute inset-0 bg-gradient-to-br from-green-500/20 to-transparent rounded-xl blur-2xl"></div>
  <div class="relative bg-gray-900/50 backdrop-blur p-8 rounded-xl border border-green-500/30">
    <carbon-chip class="text-5xl text-green-500 mb-4 mx-auto" />
    <div class="text-2xl font-bold mb-2">TEE 安全</div>
    <div class="text-sm text-gray-400 space-y-1">
      <div>可信执行环境</div>
      <div>Hardware Attestation</div>
    </div>
  </div>
</div>

<div v-click class="relative">
  <div class="absolute inset-0 bg-gradient-to-br from-purple-500/20 to-transparent rounded-xl blur-2xl"></div>
  <div class="relative bg-gray-900/50 backdrop-blur p-8 rounded-xl border border-purple-500/30">
    <carbon-encryption class="text-5xl text-purple-500 mb-4 mx-auto" />
    <div class="text-2xl font-bold mb-2">端到端加密</div>
    <div class="text-sm text-gray-400 space-y-1">
      <div>TLS 1.3</div>
      <div>DUKPT 密钥派生</div>
    </div>
  </div>
</div>

</div>

---
layout: two-cols
class: px-8
---

# 技术栈

<div class="space-y-6 mt-8">

<div v-click class="relative group">
  <div class="absolute inset-0 bg-gradient-to-r from-orange-500/10 to-transparent rounded-lg"></div>
  <div class="relative p-6 border border-orange-500/30 rounded-lg">
    <div class="flex items-center gap-4 mb-3">
      <carbon-logo-rust class="text-3xl text-orange-500" />
      <div>
        <div class="text-xl font-bold">Rust</div>
        <div class="text-xs text-gray-500">Backend</div>
      </div>
    </div>
    <div class="text-sm text-gray-400">
      高性能 • 内存安全 • 并发安全
    </div>
  </div>
</div>

<div v-click class="relative group">
  <div class="absolute inset-0 bg-gradient-to-r from-blue-500/10 to-transparent rounded-lg"></div>
  <div class="relative p-6 border border-blue-500/30 rounded-lg">
    <div class="flex items-center gap-4 mb-3">
      <carbon-logo-react class="text-3xl text-blue-500" />
      <div>
        <div class="text-xl font-bold">React</div>
        <div class="text-xs text-gray-500">Frontend</div>
      </div>
    </div>
    <div class="text-sm text-gray-400">
      组件化 • TypeScript • 现代化
    </div>
  </div>
</div>

<div v-click class="relative group">
  <div class="absolute inset-0 bg-gradient-to-r from-green-500/10 to-transparent rounded-lg"></div>
  <div class="relative p-6 border border-green-500/30 rounded-lg">
    <div class="flex items-center gap-4 mb-3">
      <carbon-mobile class="text-3xl text-green-500" />
      <div>
        <div class="text-xl font-bold">Kotlin</div>
        <div class="text-xs text-gray-500">Android</div>
      </div>
    </div>
    <div class="text-sm text-gray-400">
      现代语言 • Jetpack Compose • MVVM
    </div>
  </div>
</div>

</div>

::right::

<div class="pl-8 mt-8">

## 项目成果

<div class="space-y-4 mt-8">

<div v-click class="relative">
  <div class="flex items-center justify-between mb-2">
    <span class="text-sm font-semibold">Backend</span>
    <span class="text-2xl font-bold text-orange-500">100%</span>
  </div>
  <div class="h-3 bg-gray-800 rounded-full overflow-hidden">
    <div class="h-full bg-gradient-to-r from-orange-500 to-red-500 rounded-full" style="width: 100%"></div>
  </div>
  <div class="text-xs text-gray-500 mt-1">7,500 行代码 • 50+ 文件</div>
</div>

<div v-click class="relative">
  <div class="flex items-center justify-between mb-2">
    <span class="text-sm font-semibold">Frontend</span>
    <span class="text-2xl font-bold text-blue-500">72%</span>
  </div>
  <div class="h-3 bg-gray-800 rounded-full overflow-hidden">
    <div class="h-full bg-gradient-to-r from-blue-500 to-cyan-500 rounded-full" style="width: 72%"></div>
  </div>
  <div class="text-xs text-gray-500 mt-1">5,000 行代码 • 80+ 文件</div>
</div>

<div v-click class="relative">
  <div class="flex items-center justify-between mb-2">
    <span class="text-sm font-semibold">Android</span>
    <span class="text-2xl font-bold text-green-500">100%</span>
  </div>
  <div class="h-3 bg-gray-800 rounded-full overflow-hidden">
    <div class="h-full bg-gradient-to-r from-green-500 to-emerald-500 rounded-full" style="width: 100%"></div>
  </div>
  <div class="text-xs text-gray-500 mt-1">6,000 行代码 • 60+ 文件</div>
</div>

<div v-click class="mt-8 p-6 bg-gradient-to-br from-purple-500/20 to-pink-500/20 rounded-lg border border-purple-500/30">
  <div class="text-center">
    <div class="text-5xl font-bold bg-gradient-to-r from-purple-500 to-pink-500 bg-clip-text text-transparent mb-2">
      91%
    </div>
    <div class="text-sm text-gray-400">总体完成度</div>
    <div class="text-xs text-gray-500 mt-2">🚀 生产就绪</div>
  </div>
</div>

</div>

</div>

---
layout: center
class: text-center
---

# 核心优势

<div class="grid grid-cols-3 gap-6 mt-16 px-12">

<div v-click class="relative group">
  <div class="absolute inset-0 bg-gradient-to-br from-orange-500/20 via-red-500/20 to-pink-500/20 rounded-xl blur-2xl group-hover:blur-3xl transition-all"></div>
  <div class="relative bg-gray-900/50 backdrop-blur p-8 rounded-xl border border-orange-500/30 h-full">
    <carbon-rocket class="text-5xl text-orange-500 mb-4 mx-auto" />
    <div class="text-xl font-bold mb-3">技术领先</div>
    <div class="text-sm text-gray-400 space-y-1">
      <div>• 现代化技术栈</div>
      <div>• 企业级架构</div>
      <div>• 高性能可扩展</div>
    </div>
  </div>
</div>

<div v-click class="relative group">
  <div class="absolute inset-0 bg-gradient-to-br from-blue-500/20 via-cyan-500/20 to-teal-500/20 rounded-xl blur-2xl group-hover:blur-3xl transition-all"></div>
  <div class="relative bg-gray-900/50 backdrop-blur p-8 rounded-xl border border-blue-500/30 h-full">
    <carbon-security class="text-5xl text-blue-500 mb-4 mx-auto" />
    <div class="text-xl font-bold mb-3">安全可靠</div>
    <div class="text-sm text-gray-400 space-y-1">
      <div>• 金融级安全</div>
      <div>• 多层防护</div>
      <div>• 符合国际标准</div>
    </div>
  </div>
</div>

<div v-click class="relative group">
  <div class="absolute inset-0 bg-gradient-to-br from-green-500/20 via-emerald-500/20 to-teal-500/20 rounded-xl blur-2xl group-hover:blur-3xl transition-all"></div>
  <div class="relative bg-gray-900/50 backdrop-blur p-8 rounded-xl border border-green-500/30 h-full">
    <carbon-chart-line class="text-5xl text-green-500 mb-4 mx-auto" />
    <div class="text-xl font-bold mb-3">完整功能</div>
    <div class="text-sm text-gray-400 space-y-1">
      <div>• 设备全生命周期</div>
      <div>• 实时监控检测</div>
      <div>• 灵活密钥管理</div>
    </div>
  </div>
</div>

</div>

---
layout: center
class: text-center
---

<div class="flex flex-col items-center justify-center h-full">
  <div class="text-7xl font-bold mb-8 bg-gradient-to-r from-orange-500 via-red-500 to-pink-500 bg-clip-text text-transparent">
    SUNBAY SoftPOS
  </div>
  <div class="text-2xl text-gray-400 mb-12">
    让移动支付更安全、更简单、更高效
  </div>
  
  <div class="grid grid-cols-2 gap-8 text-left max-w-2xl">
    <div v-click class="space-y-2">
      <div class="text-sm text-gray-500">核心优势</div>
      <div class="space-y-1 text-sm">
        <div class="flex items-center gap-2">
          <carbon-checkmark class="text-green-500" />
          <span>金融级安全保障</span>
        </div>
        <div class="flex items-center gap-2">
          <carbon-checkmark class="text-green-500" />
          <span>完整设备管理</span>
        </div>
        <div class="flex items-center gap-2">
          <carbon-checkmark class="text-green-500" />
          <span>现代化技术栈</span>
        </div>
      </div>
    </div>
    
    <div v-click class="space-y-2">
      <div class="text-sm text-gray-500">项目状态</div>
      <div class="space-y-1 text-sm">
        <div class="flex items-center gap-2">
          <carbon-checkmark-filled class="text-orange-500" />
          <span>Backend 100%</span>
        </div>
        <div class="flex items-center gap-2">
          <carbon-checkmark-filled class="text-orange-500" />
          <span>Android 100%</span>
        </div>
        <div class="flex items-center gap-2">
          <carbon-in-progress class="text-blue-500" />
          <span>Frontend 72%</span>
        </div>
      </div>
    </div>
  </div>
  
  <div v-click class="mt-12 text-sm text-gray-500">
    <div class="mb-2">联系方式</div>
    <div class="flex gap-6">
      <a href="https://github.com/sunbay" class="flex items-center gap-2 hover:text-orange-500 transition-colors">
        <carbon-logo-github />
        <span>GitHub</span>
      </a>
      <div class="flex items-center gap-2">
        <carbon-email />
        <span>技术支持</span>
      </div>
      <div class="flex items-center gap-2">
        <carbon-document />
        <span>docs/solution/</span>
      </div>
    </div>
  </div>
</div>
