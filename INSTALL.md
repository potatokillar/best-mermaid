# Mermaid Extractor - 安装指南

## 快速开始

### 前置要求

- C++17 编译器 (g++ 11+ 或 clang++ 13+)
- CMake 3.15+
- Boost 1.74+
- Node.js 18+ (用于 mermaid-cli)
- npm

### Ubuntu/Debian 安装

```bash
# 1. 安装系统依赖
sudo apt-get update
sudo apt-get install -y build-essential cmake libboost-all-dev

# 2. 克隆仓库
git clone <repository-url>
cd mermaid-extractor

# 3. 构建项目
mkdir build && cd build
cmake ..
make -j$(nproc)

# 4. (可选) 安装到系统
sudo make install
```

### macOS 安装

```bash
# 1. 安装 Homebrew (如果未安装)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. 安装依赖
brew install cmake boost

# 3. 构建项目
git clone <repository-url>
cd mermaid-extractor
mkdir build && cd build
cmake ..
make -j$(sysctl -n hw.ncpu)

# 4. (可选) 安装到系统
sudo make install
```

## 安装 mermaid-cli

### 方法 1: 使用 npm (推荐)

```bash
# 安装 mermaid-cli
npm install -g @mermaid-js/mermaid-cli

# 验证安装
mmdc --version
```

### 方法 2: 跳过 Puppeteer (减少安装大小)

```bash
# 跳过 Chrome 下载
PUPPETEER_SKIP_DOWNLOAD=true npm install -g @mermaid-js/mermaid-cli
```

### 方法 3: 安装 Chrome (完整功能)

```bash
# 安装 mermaid-cli
npm install -g @mermaid-js/mermaid-cli

# 安装 Chrome (如果跳过了)
npx puppeteer browsers install chrome-headless-shell
```

## 验证安装

```bash
# 检查编译
mermaid-extractor --version

# 检查 mmdc
mmdc --version

# 测试运行
mermaid-extractor test.md
```

## 故障排除

### 问题: 未找到 Boost

```bash
# Ubuntu/Debian
sudo apt-get install libboost-all-dev

# macOS
brew install boost
```

### 问题: 未找到 mermaid-cli

```bash
npm install -g @mermaid-js/mermaid-cli

# 验证 PATH
which mmdc
```

### 问题: Puppeteer Chrome 错误

```bash
# 方案 1: 安装 Chrome
npx puppeteer browsers install chrome-headless-shell

# 方案 2: 使用系统 Chrome
export PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
```

### 问题: CMake 找不到 Boost

```bash
# 设置 Boost 路径
export Boost_DIR=/usr/lib/x86_64-linux-gnu/cmake/Boost-1.74

# 或指定 CMAKE_PREFIX_PATH
cmake -DCMAKE_PREFIX_PATH=/usr ..
```

## 卸载

```bash
# 卸载程序
sudo make uninstall  (从 build 目录)

# 卸载 mermaid-cli
npm uninstall -g @mermaid-js/mermaid-cli
```

## 开发环境

### 启用测试

```bash
mkdir build && cd build
cmake -DBUILD_TESTS=ON ..
make
ctest --verbose
```

### 启用覆盖率

```bash
cmake -DCOVERAGE=ON ..
make
./mermaid-extractor test.md
```

### Debug 模式

```bash
cmake -DCMAKE_BUILD_TYPE=Debug ..
make
```
