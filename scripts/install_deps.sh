#!/bin/bash
# 安装 Mermaid Extractor 的依赖

set -e

echo "=========================================="
echo "Mermaid Extractor - 依赖安装脚本"
echo "=========================================="
echo ""

# 检查操作系统
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
else
    echo "不支持的操作系统: $OSTYPE"
    exit 1
fi

echo "检测到操作系统: $OS"
echo ""

# 安装系统依赖
if [ "$OS" == "linux" ]; then
    echo "安装 Linux 系统依赖..."

    # 检查是否为 Ubuntu/Debian
    if command -v apt-get &> /dev/null; then
        echo "使用 apt-get 安装..."

        sudo apt-get update
        sudo apt-get install -y \
            build-essential \
            cmake \
            libboost-all-dev

        echo "✓ 系统依赖安装完成"
    else
        echo "错误: 未找到 apt-get，请手动安装以下依赖:"
        echo "  - build-essential"
        echo "  - cmake"
        echo "  - Boost (libboost-all-dev)"
        exit 1
    fi
elif [ "$OS" == "macos" ]; then
    echo "安装 macOS 系统依赖..."

    if command -v brew &> /dev/null; then
        echo "使用 Homebrew 安装..."

        brew install cmake boost

        echo "✓ 系统依赖安装完成"
    else
        echo "错误: 未找到 Homebrew"
        echo "请访问 https://brew.sh/ 安装 Homebrew"
        exit 1
    fi
fi

echo ""
echo "=========================================="
echo "安装 mermaid-cli"
echo "=========================================="
echo ""

# 检查 Node.js
if ! command -v node &> /dev/null; then
    echo "错误: 未安装 Node.js"
    echo "请访问 https://nodejs.org/ 下载安装"
    exit 1
fi

echo "Node.js 版本: $(node --version)"
echo "npm 版本: $(npm --version)"
echo ""

# 安装 mermaid-cli
echo "安装 mermaid-cli..."
npm install -g @mermaid-js/mermaid-cli

# 验证安装
echo ""
echo "验证安装..."
if command -v mmdc &> /dev/null; then
    echo "✓ mmdc 版本: $(mmdc --version)"
else
    echo "⚠ 警告: mmdc 未在 PATH 中找到"
    echo "可能需要重启终端或手动添加 npm 全局路径到 PATH"
fi

echo ""
echo "=========================================="
echo "依赖安装完成!"
echo "=========================================="
echo ""
echo "下一步:"
echo "  1. 运行: mkdir build && cd build"
echo "  2. 运行: cmake .."
echo "  3. 运行: make -j\$(nproc)"
echo "  4. 运行: sudo make install  (可选)"
echo ""
