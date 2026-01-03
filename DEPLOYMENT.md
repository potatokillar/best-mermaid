# Mermaid Extractor - 部署指南

## 🚀 在其他 Linux 机器上运行

### 方法 1: 编译后部署(推荐)

#### 步骤 1: 创建静态链接版本

```bash
cd /home/pk/workspace/mermand_demo/build

# 静态链接 Boost
cmake -DBUILD_SHARED_LIBS=OFF ..
make

# 或使用动态链接方式
make
```

#### 步骤 2: 打包

```bash
# 创建部署包
mkdir -p deploy
cp build/mermaid-extractor deploy/
strip deploy/mermaid-extractor  # 减小文件大小
```

#### 步骤 3: 传输到目标机器

```bash
# 使用 scp
scp -r deploy/* user@target-machine:/path/to/deploy/

# 或使用 tar 打包
tar czf mermaid-extractor.tar.gz deploy/
scp mermaid-extractor.tar.gz user@target-machine:/tmp/
```

#### 步骤 4: 在目标机器上运行

```bash
# 解压(如果打包了)
cd /path/to/deploy/
tar xzf /tmp/mermaid-extractor.tar.gz

# 测试运行
./mermaid-extractor --version
```

### 方法 2: Docker 容器(最简单)

创建 `Dockerfile`:

```dockerfile
FROM ubuntu:22.04

# 安装依赖
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    libboost-all-dev \
    nodejs \
    npm

# 安装 mermaid-cli
RUN npm install -g @mermaid-js/mermaid-cli

# 复制可执行文件
COPY build/mermaid-extractor /usr/local/bin/

# 设置工作目录
WORKDIR /data

# 入口点
ENTRYPOINT ["/usr/local/bin/mermaid-extractor"]
```

构建和运行:

```bash
# 构建 Docker 镜像
docker build -t mermaid-extractor .

# 运行
docker run -v $(pwd):/data mermaid-extractor README.md

# 输出到当前目录
docker run -v $(pwd):/data -v $(pwd)/output:/data/output \
    mermaid-extractor -o /data/output README.md
```

### 方法 3: 在目标机器上直接编译

#### 前置要求检查

目标机器需要:
- g++ 11+ 或 clang++ 13+
- CMake 3.15+
- Boost 1.74+
- Node.js 18+
- npm

#### 一键安装脚本

在目标机器上运行:

```bash
#!/bin/bash
set -e

echo "安装依赖..."
sudo apt-get update
sudo apt-get install -y build-essential cmake libboost-all-dev

echo "安装 mermaid-cli..."
npm install -g @mermaid-js/mermaid-cli

echo "克隆仓库..."
git clone <your-repo-url>
cd mermaid-extractor

echo "编译..."
mkdir build && cd build
cmake ..
make -j$(nproc)

echo "测试..."
./mermaid-extractor --version

echo "安装完成!"
```

## 📦 依赖检查

在目标机器上检查依赖:

```bash
#!/bin/bash

echo "检查依赖..."

# C++ 编译器
if command -v g++ &> /dev/null; then
    echo "✓ g++: $(g++ --version | head -1)"
else
    echo "✗ g++ 未安装"
fi

# CMake
if command -v cmake &> /dev/null; then
    echo "✓ cmake: $(cmake --version | head -1)"
else
    echo "✗ cmake 未安装"
fi

# Boost
if pkg-config --exists boost; then
    echo "✓ Boost: $(pkg-config --modversion boost)"
else
    echo "✗ Boost 未安装"
fi

# Node.js
if command -v node &> /dev/null; then
    echo "✓ Node.js: $(node --version)"
else
    echo "✗ Node.js 未安装"
fi

# mermaid-cli
if command -v mmdc &> /dev/null; then
    echo "✓ mmdc: $(mmdc --version)"
else
    echo "✗ mmdc 未安装"
fi
```

## 🔧 动态链接库问题

如果遇到 "cannot open shared object file" 错误:

### 方案 1: 安装缺失的库

```bash
# Ubuntu/Debian
sudo apt-get install libboost-system1.74.0 libboost-filesystem1.74.0

# CentOS/RHEL
sudo yum install boost-system boost-filesystem
```

### 方案 2: 使用 LD_LIBRARY_PATH

```bash
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
./mermaid-extractor README.md
```

### 方案 3: 编译静态链接版本

修改 `CMakeLists.txt`:

```cmake
# 静态链接 Boost
set(Boost_USE_STATIC_LIBS ON)
set(Boost_USE_STATIC_RUNTIME ON)

find_package(Boost 1.74 REQUIRED COMPONENTS filesystem regex)
```

重新编译:

```bash
cd build
cmake .. -DBUILD_SHARED_LIBS=OFF
make
```

## 🌐 离线部署

### 完全离线环境

1. **在有网络的机器上准备**:

```bash
# 下载所有依赖
sudo apt-get install -d -y build-essential cmake libboost-all-dev

# 打包 .deb 文件
mkdir /tmp/debs
cp -r /var/cache/apt/archives/*.deb /tmp/debs/

# 打备 npm 包
npm pack @mermaid-js/mermaid-cli
```

2. **传输到离线机器**:

```bash
scp -r /tmp/debs user@offline-machine:/tmp/
scp mermaid-extractor-*.tgz user@offline-machine:/tmp/
```

3. **在离线机器上安装**:

```bash
# 安装 .deb 文件
sudo dpkg -i /tmp/debs/*.deb

# 安装 npm 包
npm install -g /tmp/mermaid-extractor-*.tgz
```

## 📋 系统兼容性

### 已测试平台

| 发行版 | 版本 | 状态 |
|--------|------|------|
| Ubuntu | 22.04 LTS | ✅ 完全支持 |
| Ubuntu | 20.04 LTS | ✅ 完全支持 |
| Debian | 11 (Bullseye) | ✅ 完全支持 |
| Debian | 12 (Bookworm) | ✅ 完全支持 |
| CentOS | 8 Stream | ⚠️ 需要手动安装依赖 |
| Fedora | 39+ | ✅ 完全支持 |

### 最低系统要求

- **内存**: 512MB (运行时)
- **磁盘**: 100MB (程序 + 依赖)
- **CPU**: 任意 x86_64 架构

## 🔐 安全注意事项

1. **下载验证**: 验证编译后的二进制文件
   ```bash
   sha256sum mermaid-extractor > mermaid-extractor.sha256
   ```

2. **沙盒运行**: 使用 Docker 或用户命名空间
   ```bash
   docker run --rm -v $(pwd):/data mermaid-extractor README.md
   ```

3. **权限控制**: 限制程序权限
   ```bash
   chmod 755 mermaid-extractor
   chown root:root mermaid-extractor  # 如果需要 setuid
   ```

## 📞 故障排除

### 问题: "error while loading shared libraries"

```bash
# 查找缺失的库
ldd mermaid-extractor

# 安装缺失的库
sudo apt-get install libboost-system1.74.0
```

### 问题: "mmdc: command not found"

```bash
# 安装 mermaid-cli
npm install -g @mermaid-js/mermaid-cli

# 或使用 npx
alias mmdc='npx @mermaid-js/mermaid-cli'
```

### 问题: "GLIBC_2.29 not found"

需要更新 glibc 或在更新的系统上编译。

---

**总结**: 推荐使用 Docker 方式部署,最简单且兼容性最好!
