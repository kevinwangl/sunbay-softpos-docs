#!/bin/bash

echo "🚀 SUNBAY SoftPOS 科技版演示文稿"
echo "================================"
echo ""

# 检查是否在正确的目录
if [ ! -f "slides-tech.md" ]; then
    echo "❌ 错误: 请在 docs/solution 目录下运行此脚本"
    exit 1
fi

# 检查 Node.js
if ! command -v node &> /dev/null; then
    echo "❌ 错误: 未安装 Node.js"
    echo "请访问 https://nodejs.org/ 安装 Node.js"
    exit 1
fi

echo "✅ Node.js 版本: $(node --version)"
echo ""

# 检查是否已安装依赖
if [ ! -d "node_modules" ]; then
    echo "📦 正在安装依赖..."
    npm install
    echo ""
fi

# 启动 Slidev
echo "🚀 启动科技版 Slidev..."
echo ""
echo "✨ 特点:"
echo "  - 暗色主题，科技感十足"
echo "  - 精简内容，聚焦核心架构"
echo "  - 渐变效果和发光边框"
echo "  - 流畅的动画过渡"
echo ""
echo "📖 快捷键:"
echo "  - 空格/→ 翻页"
echo "  - o 概览模式"
echo "  - d 切换暗色模式"
echo "  - f 全屏"
echo ""
echo "按 Ctrl+C 停止服务器"
echo ""

npm run dev:tech
