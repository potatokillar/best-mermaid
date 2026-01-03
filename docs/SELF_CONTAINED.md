# 创建自包含版本的 Mermaid Extractor

## 方案对比

| 方案 | 优点 | 缺点 | 文件大小 |
|------|------|------|----------|
| 1. 嵌入 Node.js | 完全独立,无需依赖 | 较大 (~50MB) | ⭐⭐⭐ |
| 2. AppImage | 通用 Linux 格式 | 需要额外工具 | ~50MB |
| 3. Docker | 最简单 | 需要 Docker | ~200MB |
| 4. 纯 C++ 渲染器 | 最小 | 功能有限 | ~1MB |

---

## 方案 1: 嵌入 Node.js 运行时(推荐)

### 步骤 1: 下载 Node.js 静态二进制

```bash
# 下载 Node.js 二进制
cd /home/pk/workspace/mermand_demo
mkdir -p third_party/node
cd third_party/node

wget https://nodejs.org/dist/v20.19.6/node-v20.19.6-linux-x64.tar.xz
tar xf node-v20.19.6-linux-x64.tar.xz
```

### 步骤 2: 创建自包含包

```bash
cd /home/pk/workspace/mermand_demo

# 创建包结构
mkdir -p package/bin package/lib package/node_modules

# 复制 Node.js 运行时
cp third_party/node/node-v20.19.6-linux-x64/bin/node package/bin/
cp third_party/node/node-v20.19.6-linux-x64/bin/npm package/bin/

# 复制 Node.js 库
cp -r third_party/node/node-v20.19.6-linux-x64/lib/* package/lib/

# 安装 mermaid-cli 到包内
export PATH=$(pwd)/package/bin:$PATH
export npm_config_prefix=$(pwd)/package
npm install -g @mermaid-js/mermaid-cli

# 复制我们的可执行文件
cp build/mermaid-extractor package/bin/

# 创建启动脚本
cat > package/mermaid-extractor-wrapper << 'SCRIPT'
#!/bin/bash
# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 设置 PATH
export PATH="$SCRIPT_DIR/bin:$PATH"
export LD_LIBRARY_PATH="$SCRIPT_DIR/lib:$LD_LIBRARY_PATH"
export NODE_PATH="$SCRIPT_DIR/lib/node_modules"

# 运行程序
exec "$SCRIPT_DIR/bin/mermaid-extractor" "$@"
SCRIPT

chmod +x package/mermaid-extractor-wrapper
```

### 步骤 3: 打包

```bash
# 创建 tar 包
tar czf mermaid-extractor-standalone.tar.gz -C package .

# 或创建 zip
cd package
zip -r ../mermaid-extractor-standalone.zip .
```

### 步骤 4: 在目标机器上使用

```bash
# 解压
tar xzf mermaid-extractor-standalone.tar.gz
cd package

# 直接运行
./mermaid-extractor-wrapper README.md
```

---

## 方案 2: AppImage (最通用)

### 创建 AppImage

```bash
# 安装 appimage-builder
pip3 install appimage-builder

# 创建 AppImage 配置
cat > AppImageBuilder.yml << 'YAML'
version: 1
AppDir:
  path: ./AppDir
  files:
    include: []
    exclude:
    - usr/share/man
    - usr/share/doc
  app_info:
    id: com.mermaid.extractor
    name: mermaid-extractor
    icon: utilities-terminal
    version: 1.0.0
    exec: usr/bin/mermaid-extractor
    exec_args: $@
  runtime:
    env:
      PATH: ${APPDIR}/usr/bin:${APPDIR}/usr/local/bin:${PATH}
  apt:
    arch: amd64
    sources:
      - sourceline: deb http://archive.ubuntu.com/ubuntu/ jammy main restricted
    include:
      - libstdc++6
      - libgcc-s1
      - nodejs
      - npm
    test:
      debian:
        image: ubuntu:22.04

AppImage:
  update-information: None
  sign-key: None
  arch: x86_64
  scene: null
YAML

# 构建
appimage-builder --skip-test
```

---

## 方案 3: 纯 C++ 渲染(实验性)

使用 C++ 库直接渲染 Mermaid:

```bash
# 安装 mermaid-cpp (实验性)
git clone https://github.com/some-user/mermaid-cpp.git
cd mermaid-cpp
mkdir build && cd build
cmake ..
make && sudo make install
```

修改 CMakeLists.txt:

```cmake
# 使用 mermaid-cpp 替代 mermaid-cli
find_package(mermaid-cpp REQUIRED)
target_link_libraries(mermaid-extractor
    mermaid-cpp
    Boost::filesystem
    Boost::regex
)
```

**注意**: 此方案功能有限,仅支持基本图表类型。

---

## 方案 4: Docker 单文件

使用 `docker2single` 创建独立可执行文件:

```bash
# 安装 docker2single
go install github.com/docker2single/docker2single@latest

# 转换 Docker 镜像为单文件
docker2single convert \
  --image mermaid-extractor:latest \
  --output mermaid-extractor.bin

# 运行
./mermaid-extractor.bin run README.md
```

---

## 推荐部署方案对比

### 开发/测试环境
```bash
# 使用现有可执行文件 + npm
./build/mermaid-extractor README.md
```

### 生产环境 - 无 npm
```bash
# 使用自包含包
tar xzf mermaid-extractor-standalone.tar.gz
./package/mermaid-extractor-wrapper README.md
```

### 生产环境 - 多服务器
```bash
# 使用 Docker
docker run -v $(pwd):/data mermaid-extractor README.md
```

### 生产环境 - 大规模部署
```bash
# 使用 AppImage (最通用)
./Mermaid-Extractor-1.0.0-x86_64.AppImage README.md
```

---

## 实际操作脚本

让我创建一个自动化脚本:
