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
echo "📋 第 2 步: 安装 Chrome 和 mermaid-cli"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 检查 Chrome 是否已安装
check_chrome() {
    if [ "$OS" == "linux" ]; then
        command -v google-chrome &> /dev/null || \
        command -v chromium-browser &> /dev/null || \
        command -v chromium &> /dev/null
    elif [ "$OS" == "macos" ]; then
        [ -d "/Applications/Google Chrome.app" ]
    else
        false
    fi
}

# 安装 Chrome
install_chrome() {
    if [ "$OS" == "linux" ]; then
        echo "📦 安装 Chromium..."
        sudo apt-get install -y chromium-browser
    elif [ "$OS" == "macos" ]; then
        echo "📦 提示: macOS 通常已预装 Chrome"
        echo "如果没有，请访问 https://www.google.com/chrome/ 下载"
    fi
}

echo "🔍 检查 Chrome..."
if check_chrome; then
    echo "✅ Chrome 已安装"
    INSTALL_CHROME=false
else
    echo "⚠️  未找到 Chrome"
    echo ""
    echo "⚠️  重要提示:"
    echo "  mermaid-cli 需要 Chrome/Chromium 才能渲染图表"
    echo "  如果不安装，渲染将会失败并显示错误:"
    echo "  'Could not find Chrome'"
    echo ""
    read -p "是否现在安装 Chromium? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_chrome
        INSTALL_CHROME=true
    else
        INSTALL_CHROME=false
        echo "⚠️  跳过 Chrome 安装"
        echo "  注意: 程序将无法渲染图表，直到安装 Chrome"
    fi
fi

echo ""
echo "📦 安装 mermaid-cli..."
echo "提示: 这可能需要几分钟时间..."

if [ "$INSTALL_CHROME" = true ]; then
    # 安装完整的 mermaid-cli（包含 Chrome）
    npm install -g @mermaid-js/mermaid-cli
else
    # 跳过 Puppeteer Chrome 下载
    echo "⚠️  跳过 Chrome 下载（PUPPETEER_SKIP_DOWNLOAD）"
    PUPPETEER_SKIP_DOWNLOAD=true npm install -g @mermaid-js/mermaid-cli
fi

if command -v mmdc &> /dev/null; then
    echo "✅ mermaid-cli 安装成功: $(mmdc --version 2>&1 | head -1)"
else
    echo "⚠️  警告: mmdc 未在 PATH 中找到"
    echo "可能需要重启终端或手动添加 npm 全局路径到 PATH"
fi

echo ""
if ! check_chrome; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚠️  警告: Chrome 未安装"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "程序已安装，但无法渲染图表，直到安装 Chrome/Chromium。"
    echo ""
    echo "安装 Chrome 后，需要安装 chrome-headless-shell:"
    echo "  npx puppeteer browsers install chrome-headless-shell"
    echo ""
    echo "或者使用系统 Chrome (设置环境变量):"
    if [ "$OS" == "linux" ]; then
        echo "  export PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser"
    elif [ "$OS" == "macos" ]; then
        echo "  export PUPPETEER_EXECUTABLE_PATH=/Applications/Google\\ Chrome.app/Contents/MacOS/Google\\ Chrome"
    fi
    echo ""
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
