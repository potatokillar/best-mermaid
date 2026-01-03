#!/bin/bash
# Best Mermaid Extractor - 一键安装脚本
# 支持 Ubuntu/Debian 和 macOS

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║          Best Mermaid Extractor - 安装向导                 ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# 检测操作系统
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
else
    echo "❌ 错误: 不支持的操作系统: $OSTYPE"
    echo "支持的系统: Linux, macOS"
    exit 1
fi

echo "📟 检测到操作系统: $OS"
echo ""

# 检查必需命令
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo "❌ 未找到: $1"
        return 1
    else
        echo "✅ 找到: $1 ($(command -v $1))"
        return 0
    fi
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 第 1 步: 检查系统依赖"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

MISSING_DEPS=0

# 检查编译器
if ! check_command "g++"; then
    echo "   需要: build-essential (Ubuntu/Debian)"
    MISSING_DEPS=1
fi

# 检查 CMake
if ! check_command "cmake"; then
    echo "   需要: cmake"
    MISSING_DEPS=1
fi

# 检查 Node.js
if ! check_command "node"; then
    echo "   需要: Node.js 18+"
    MISSING_DEPS=1
fi

# 检查 npm
if ! check_command "npm"; then
    echo "   需要: npm"
    MISSING_DEPS=1
fi

echo ""

if [ $MISSING_DEPS -eq 1 ]; then
    echo "⚠️  检测到缺失的依赖，开始安装..."
    echo ""

    if [ "$OS" == "linux" ]; then
        echo "📦 安装 Linux 系统依赖..."

        # 检查是否有 sudo 权限
        if ! command -v sudo &> /dev/null; then
            echo "❌ 需要 sudo 权限来安装系统包"
            exit 1
        fi

        # 更新包列表
        echo "更新包列表..."
        sudo apt-get update -qq

        # 安装依赖
        echo "安装 build-essential, cmake, Boost..."
        sudo apt-get install -y \
            build-essential \
            cmake \
            libboost-all-dev

        echo "✅ 系统依赖安装完成"
    elif [ "$OS" == "macos" ]; then
        echo "📦 安装 macOS 系统依赖..."

        if ! command -v brew &> /dev/null; then
            echo "❌ 未找到 Homebrew"
            echo "请访问 https://brew.sh/ 安装 Homebrew"
            exit 1
        fi

        brew install cmake boost
        echo "✅ 系统依赖安装完成"
    fi
else
    echo "✅ 所有系统依赖已满足"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 第 2 步: 安装 mermaid-cli"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if command -v mmdc &> /dev/null; then
    echo "✅ mermaid-cli 已安装: $(mmdc --version 2>&1 | head -1)"
else
    echo "📦 安装 mermaid-cli..."
    echo "提示: 这可能需要几分钟时间..."

    # 跳过 Puppeteer Chrome 下载（减少安装时间）
    PUPPETEER_SKIP_DOWNLOAD=true npm install -g @mermaid-js/mermaid-cli

    if command -v mmdc &> /dev/null; then
        echo "✅ mermaid-cli 安装成功: $(mmdc --version 2>&1 | head -1)"
    else
        echo "⚠️  警告: mmdc 未在 PATH 中找到"
        echo "可能需要重启终端或手动添加 npm 全局路径到 PATH"
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 第 3 步: 编译 Best Mermaid Extractor"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 检查是否在项目目录中
if [ ! -f "CMakeLists.txt" ]; then
    echo "❌ 错误: 未找到 CMakeLists.txt"
    echo "请确保在项目根目录中运行此脚本"
    exit 1
fi

# 创建构建目录
echo "🔨 创建构建目录..."
mkdir -p build
cd build

# 运行 CMake
echo "⚙️  配置项目..."
cmake .. -DCMAKE_BUILD_TYPE=Release

# 编译
echo "🔧 编译项目..."
NPROC=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)
make -j$NPROC

if [ -f "mermaid-extractor" ]; then
    echo "✅ 编译成功!"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🎉 安装完成!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "可执行文件位置: $(pwd)/mermaid-extractor"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📖 快速开始"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "运行程序:"
    echo "  ./build/mermaid-extractor --help"
    echo ""
    echo "处理 Markdown 文件:"
    echo "  ./build/mermaid-extractor README.md"
    echo ""
    echo "批量处理目录:"
    echo "  ./build/mermaid-extractor -r docs/"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔧 可选: 安装到系统"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "要将程序安装到系统路径 (/usr/local/bin):"
    echo "  cd build"
    echo "  sudo make install"
    echo ""
    echo "然后就可以在任何地方使用:"
    echo "  mermaid-extractor README.md"
    echo ""
else
    echo "❌ 编译失败!"
    echo "请检查错误信息并重试"
    exit 1
fi
