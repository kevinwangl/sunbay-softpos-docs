#!/bin/bash

# SUNBAY SoftPOS 演示文稿生成脚本

echo "🎨 SUNBAY SoftPOS 演示文稿生成工具"
echo "=================================="
echo ""

# 检查 Node.js
if ! command -v node &> /dev/null; then
    echo "❌ 错误: 未安装 Node.js"
    echo "请先安装 Node.js: https://nodejs.org/"
    exit 1
fi

echo "✅ Node.js 版本: $(node -v)"

# 检查 npm
if ! command -v npm &> /dev/null; then
    echo "❌ 错误: 未安装 npm"
    exit 1
fi

echo "✅ npm 版本: $(npm -v)"
echo ""

# 检查 Marp CLI
if ! command -v marp &> /dev/null; then
    echo "📦 Marp CLI 未安装，正在安装..."
    npm install -g @marp-team/marp-cli
    
    if [ $? -ne 0 ]; then
        echo "❌ Marp CLI 安装失败"
        echo ""
        echo "请手动安装:"
        echo "  npm install -g @marp-team/marp-cli"
        echo ""
        echo "或使用其他方式查看演示文稿:"
        echo "  1. 直接在 Markdown 编辑器中查看 PRESENTATION.md"
        echo "  2. 使用在线工具: https://marp.app/"
        echo "  3. 手动制作 PowerPoint"
        exit 1
    fi
fi

echo "✅ Marp CLI 已安装"
echo ""

# 进入文档目录
cd "$(dirname "$0")"

# 生成选项
echo "请选择生成格式:"
echo "  1) HTML (推荐，可在浏览器中查看)"
echo "  2) PDF"
echo "  3) PowerPoint (PPTX)"
echo "  4) 全部生成"
echo "  5) 实时预览"
echo ""
read -p "请输入选项 (1-5): " choice

case $choice in
    1)
        echo ""
        echo "📄 正在生成 HTML..."
        marp PRESENTATION.md -o PRESENTATION.html --html
        echo "✅ 生成完成: PRESENTATION.html"
        echo ""
        echo "在浏览器中打开:"
        echo "  open PRESENTATION.html"
        ;;
    2)
        echo ""
        echo "📄 正在生成 PDF..."
        marp PRESENTATION.md -o PRESENTATION.pdf --allow-local-files
        echo "✅ 生成完成: PRESENTATION.pdf"
        ;;
    3)
        echo ""
        echo "📄 正在生成 PowerPoint..."
        marp PRESENTATION.md -o PRESENTATION.pptx
        echo "✅ 生成完成: PRESENTATION.pptx"
        ;;
    4)
        echo ""
        echo "📄 正在生成所有格式..."
        marp PRESENTATION.md -o PRESENTATION.html --html
        marp PRESENTATION.md -o PRESENTATION.pdf --allow-local-files
        marp PRESENTATION.md -o PRESENTATION.pptx
        echo "✅ 全部生成完成!"
        echo "  - PRESENTATION.html"
        echo "  - PRESENTATION.pdf"
        echo "  - PRESENTATION.pptx"
        ;;
    5)
        echo ""
        echo "🔄 启动实时预览服务器..."
        echo "在浏览器中打开: http://localhost:8080"
        echo "按 Ctrl+C 停止服务器"
        echo ""
        marp -s PRESENTATION.md
        ;;
    *)
        echo "❌ 无效选项"
        exit 1
        ;;
esac

echo ""
echo "🎉 完成!"
