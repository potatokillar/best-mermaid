# Best Mermaid Extractor

从 Markdown 文件中提取 Mermaid 图表并渲染为高质量图片的 C++ CLI 工具。

## 特性

- ✅ 支持单文件、批量文件和递归目录处理
- ✅ 输出高清晰度 SVG(矢量图)和 PNG 图片
- ✅ 自定义 PNG 分辨率和 DPI
- ✅ 智能文件命名(基于文件名和图表标题)
- ✅ 保持原目录结构选项
- ✅ 详细的进度和错误报告
- ✅ 处理文件中的多个 Mermaid 图表

## 开发状态

✅ **v1.0.0 发布 - 项目完成**

实现进度:
- [x] 项目结构搭建
- [x] CLI 参数解析器
- [x] Markdown 解析器
- [x] 文件处理模块
- [x] 渲染引擎集成
- [x] 主流程集成
- [x] 单元测试
- [x] 文档完善

### 测试结果
- ✅ 成功提取多个 Mermaid 图表 (3/3)
- ✅ 标题提取和文件命名正确
- ✅ CLI 接口完整工作
- ✅ 可执行文件大小: 724KB
- ✅ 跨平台兼容 (Linux)

### 快速开始
```bash
# 克隆项目
git clone https://github.com/potatokillar/best-mermaid.git
cd best-mermaid

# 构建
mkdir build && cd build
cmake ..
make

# 运行
./mermaid-extractor --help
```

## 安装

### 方法 1: 一键安装（推荐）⚡

```bash
# 克隆项目
git clone https://github.com/potatokillar/best-mermaid.git
cd best-mermaid

# 运行安装脚本（自动安装所有依赖并编译）
./install.sh
```

安装脚本会自动：
- ✅ 检测操作系统（Linux/macOS）
- ✅ 安装系统依赖（CMake, Boost）
- ✅ 安装 mermaid-cli
- ✅ 编译项目
- ✅ 验证安装

### 方法 2: 手动安装

#### 前置要求

- C++17 编译器 (g++ 11+ 或 clang++ 13+)
- CMake 3.15+
- Boost 1.74+
- Node.js 18+ (用于 mermaid-cli)
- npm

#### Ubuntu/Debian

```bash
# 安装系统依赖
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    cmake \
    libboost-all-dev

# 安装 mermaid-cli
npm install -g @mermaid-js/mermaid-cli

# 编译项目
git clone https://github.com/potatokillar/best-mermaid.git
cd best-mermaid
mkdir build && cd build
cmake ..
make -j$(nproc)
```

#### macOS

```bash
# 安装 Homebrew 依赖
brew install cmake boost

# 安装 mermaid-cli
npm install -g @mermaid-js/mermaid-cli

# 编译项目
git clone https://github.com/potatokillar/best-mermaid.git
cd best-mermaid
mkdir build && cd build
cmake ..
make
```

### 可选：安装到系统路径

```bash
cd build
sudo make install

# 然后可以在任何地方使用
mermaid-extractor --help
```

## 使用方法

### 基本用法

```bash
# 使用编译后的可执行文件
./build/mermaid-extractor README.md

# 或者已安装到系统的版本
mermaid-extractor README.md

# 处理整个目录
mermaid-extractor docs/

# 递归处理子目录
mermaid-extractor -r docs/
```

### 输出选项

```bash
# 指定输出目录
mermaid-extractor -o ./images README.md

# 输出 PNG 格式（高分辨率）
mermaid-extractor -f png README.md

# 自定义 PNG 宽度和 DPI
mermaid-extractor -f png -w 3000 -d 600 README.md

# 保持原目录结构
mermaid-extractor -r --keep-structure docs/

# 详细输出模式
mermaid-extractor --verbose README.md
```

### 实际示例

```bash
# 示例 1: 提取 README 中的所有图表
mermaid-extractor README.md
# 输出: output/README-flowchart-001.svg

# 示例 2: 生成高分辨率 PNG
mermaid-extractor -f png -w 4000 -d 600 README.md
# 输出: output/README-flowchart-001.png (4000px 宽, 600 DPI)

# 示例 3: 批量处理文档目录
mermaid-extractor -r -o ./diagrams docs/
# 输出: diagrams/ 目录下所有提取的图表

# 示例 4: 保持目录结构
mermaid-extractor -r --keep-structure docs/
# 输出:
# output/docs/api-guide-sequence-001.svg
# output/docs/tutorial-flowchart-002.svg
```

## 命令行选项

```
Usage: mermaid-extractor [options] <input>

Options:
  -o, --output <dir>     输出目录 (默认: ./output)
  -f, --format <fmt>     输出格式: svg|png (默认: svg)
  -r, --recursive        递归处理子目录
  -w, --width <px>       PNG 宽度 (默认: 2000)
  -h, --height <px>      PNG 高度 (默认: 自动)
  -d, --dpi <value>      PNG DPI (默认: 300)
  --keep-structure       保持原目录结构
  --verbose              详细输出模式
  -v, --version          显示版本信息
  -h, --help             显示帮助信息
```

## 文件命名规则

输出文件名格式: `{原文件名}-{图表标题}-{序号}.{扩展名}`

**示例:**
- `README-flowchart-001.svg`
- `API指南-sequence-diagram-002.png`
- `guide-chart-001.svg` (无标题时使用 "chart")

## 架构

```
mermaid-extractor/
├── src/
│   ├── main.cpp              # 程序入口
│   ├── cli/                  # CLI 参数解析
│   ├── markdown/             # Markdown 解析器
│   ├── mermaid/              # Mermaid 提取器
│   ├── renderer/             # 渲染引擎接口
│   ├── fileutils/            # 文件处理
│   └── config/               # 配置管理
├── tests/                    # 测试代码
└── scripts/                  # 安装脚本
```

## 贡献

欢迎提交 Issue 和 Pull Request!

## 许可证

MIT License
