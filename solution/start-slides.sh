#!/bin/bash

echo "🎯 SUNBAY SoftPOS Slidev 演示文稿"
echo "================================"
echo ""

# 检查是否在正确的目录
if [ ! -f "slides.md" ]; then
    echo "❌ 错误: 请在 docs/solution 目录下运行此脚本"
    exit 1
fi

# 检查 Node.js
if ! command -v node &> /dev/null; then
    echo "❌ 错误: 未安装 Node.js"
    echo "请访问 https://nodejs.org/ 安装 Node.js"
    exit 1
fi

# 检查 npm
if ! command -v npm &> /dev/null; then
    echo "❌ 错误: 未安装 npm"
    exit 1
fi

echo "✅ Node.js 版本: $(node --version)"
echo "✅ npm 版本: $(npm --version)"
echo ""

# 检查是否已安装依赖
if [ ! -d "node_modules" ]; then
    echo "📦 正在安装依赖..."
    npm install
    echo ""
fi

# 启动 Slidev
echo "🚀 启动 Slidev 开发服务器..."
echo ""
echo "📖 使用说明:"
echo "  - 浏览器会自动打开 http://localhost:3030"
echo "  - 按空格键或→键翻页"
echo "  - 按 o 键显示概览"
echo "  - 按 s 键进入演讲者模式"
echo "  - 按 ? 键查看所有快捷键"
echo ""
echo "按 Ctrl+C 停止服务器"
echo ""

npm run dev
