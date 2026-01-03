#!/bin/bash
# 创建自包含版本的 Mermaid Extractor

set -e

echo "=========================================="
echo "创建 Mermaid Extractor 自包含版本"
echo "=========================================="
echo ""

VERSION="1.0.0"
PACKAGE_NAME="mermaid-extractor-${VERSION}-standalone"
BUILD_DIR="$(pwd)/build"
PACKAGE_DIR="$(pwd)/${PACKAGE_NAME}"

# 检查是否已编译
if [ ! -f "${BUILD_DIR}/mermaid-extractor" ]; then
    echo "错误: 未找到编译好的可执行文件"
    echo "请先运行: mkdir build && cd build && cmake .. && make"
    exit 1
fi

echo "步骤 1: 创建包结构..."
rm -rf "${PACKAGE_DIR}"
mkdir -p "${PACKAGE_DIR}"/{bin,lib,share}

echo "步骤 2: 复制可执行文件..."
cp "${BUILD_DIR}/mermaid-extractor" "${PACKAGE_DIR}/bin/"
strip "${PACKAGE_DIR}/bin/mermaid-extractor"

echo "步骤 3: 检查 Node.js..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo "✓ 系统已安装 Node.js ${NODE_VERSION}"

    # 使用系统的 node 和 npm
    NODE_PATH=$(which node)
    NPM_PATH=$(which npm)

    # 复制到包中(如果系统安装方式允许)
    if [ -f "${NODE_PATH}" ]; then
        echo "步骤 4: 复制 Node.js 运行时..."
        cp "${NODE_PATH}" "${PACKAGE_DIR}/bin/"
        cp "${NPM_PATH}" "${PACKAGE_DIR}/bin/"

        # 查找并复制 Node.js 库
        NODE_LIBS=$(ldd "${NODE_PATH}" | grep "=> *" | cut -d'>' -f2 | awk '{print $1}')
        for lib in $NODE_LIBS; do
            if [ -f "$lib" ]; then
                cp "$lib" "${PACKAGE_DIR}/lib/" 2>/dev/null || true
            fi
        done
    fi
else
    echo "⚠ 未找到 Node.js,将创建需要外部依赖的包"
fi

echo "步骤 5: 安装 mermaid-cli 到包内..."
if [ -f "${PACKAGE_DIR}/bin/node" ]; then
    export PATH="${PACKAGE_DIR}/bin:$PATH"
    export npm_config_prefix="${PACKAGE_DIR}"

    # 安装 mermaid-cli
    npm install -g @mermaid-js/mermaid-cli --no-fund --no-audit --silent

    # 清理不必要的文件
    rm -rf "${PACKAGE_DIR}/lib/node_modules/@mermaid-js/mermaid-cli/node_modules/puppeteer/.local-chromium"
fi

echo "步骤 6: 创建包装脚本..."
cat > "${PACKAGE_DIR}/mermaid-extractor" << 'WRAPPER'
#!/bin/bash
# Mermaid Extractor - 自包含版本

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 设置环境变量
export PATH="${SCRIPT_DIR}/bin:${PATH}"
export LD_LIBRARY_PATH="${SCRIPT_DIR}/lib:${LD_LIBRARY_PATH}"
export NODE_PATH="${SCRIPT_DIR}/lib/node_modules:${NODE_PATH}"

# 检查 mmdc
if ! command -v mmdc &> /dev/null; then
    echo "错误: 未找到 mermaid-cli (mmdc)"
    echo ""
    echo "请选择以下方案之一:"
    echo "  1. 安装 Node.js 和 mermaid-cli:"
    echo "     npm install -g @mermaid-js/mermaid-cli"
    echo ""
    echo "  2. 使用 Docker 镜像"
    exit 1
fi

# 运行程序
exec "${SCRIPT_DIR}/bin/mermaid-extractor" "$@"
WRAPPER

chmod +x "${PACKAGE_DIR}/mermaid-extractor"

echo "步骤 7: 创建 README..."
cat > "${PACKAGE_DIR}/README.txt" << 'README'
Mermaid Extractor v1.0.0 - 自包含版本
========================================

使用方法:
  ./mermaid-extractor [options] <input>

示例:
  ./mermaid-extractor README.md
  ./mermaid-extractor -o ./images README.md
  ./mermaid-extractor -f png -w 3000 README.md

选项:
  -o, --output <dir>     输出目录
  -f, --format <fmt>     格式 (svg/png)
  -r, --recursive        递归处理
  --verbose              详细输出
  --help                 显示帮助

注意:
  1. 此包包含 Node.js 运行时
  2. 如果 mermaid-cli 未包含,需要安装:
     npm install -g @mermaid-js/mermaid-cli

更多信息:
  https://github.com/your-repo/mermaid-extractor
README

echo "步骤 8: 打包..."
echo ""

# 选择打包格式
echo "选择打包格式:"
echo "  1) tar.gz (推荐,最小)"
echo "  2) tar.xz (更小)"
echo "  3) zip (Windows 兼容)"
echo "  4) 全部"
read -p "请选择 [1-4]: " choice

case $choice in
    1| "")
        tar czf "${PACKAGE_NAME}.tar.gz" -C "${PACKAGE_DIR}" .
        echo "✓ 创建: ${PACKAGE_NAME}.tar.gz"
        ;;
    2)
        tar cJf "${PACKAGE_NAME}.tar.xz" -C "${PACKAGE_DIR}" .
        echo "✓ 创建: ${PACKAGE_NAME}.tar.xz"
        ;;
    3)
        cd "${PACKAGE_DIR}"
        zip -r "../${PACKAGE_NAME}.zip" .
        cd ..
        echo "✓ 创建: ${PACKAGE_NAME}.zip"
        ;;
    4)
        tar czf "${PACKAGE_NAME}.tar.gz" -C "${PACKAGE_DIR}" .
        tar cJf "${PACKAGE_NAME}.tar.xz" -C "${PACKAGE_DIR}" .
        cd "${PACKAGE_DIR}"
        zip -r "../${PACKAGE_NAME}.zip" .
        cd ..
        echo "✓ 创建所有格式"
        ;;
esac

echo ""
echo "=========================================="
echo "完成!"
echo "=========================================="
echo ""
echo "包内容:"
ls -lh "${PACKAGE_NAME}".tar.gz 2>/dev/null || true
echo ""
echo "在目标机器上使用:"
echo ""
echo "  1. 解压:"
echo "     tar xzf ${PACKAGE_NAME}.tar.gz"
echo "     cd ${PACKAGE_NAME}"
echo ""
echo "  2. 运行:"
echo "     ./mermaid-extractor README.md"
echo ""
echo "  3. (可选) 安装到系统:"
echo "     sudo cp mermaid-extractor /usr/local/bin/"
echo ""
