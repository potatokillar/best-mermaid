# Mermaid Extractor

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

🚧 **正在开发中**

当前实现进度:
- [x] 项目结构搭建
- [ ] CLI 参数解析器
- [ ] Markdown 解析器
- [ ] 文件处理模块
- [ ] 渲染引擎集成
- [ ] 主流程集成
- [ ] 单元测试
- [ ] 文档完善

## 安装

### 前置要求

- C++17 编译器 (g++ 11+ 或 clang++ 13+)
- CMake 3.15+
- Boost 1.74+
- Node.js 18+ (用于 mermaid-cli)
- npm

### Ubuntu/Debian

```bash
# 安装依赖
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    cmake \
    libboost-all-dev

# 安装 mermaid-cli
npm install -g @mermaid-js/mermaid-cli

# 构建项目
git clone <repository-url>
cd mermaid-extractor
mkdir build && cd build
cmake ..
make -j$(nproc)

# 安装到系统
sudo make install
```

## 使用方法

### 基本用法

```bash
# 处理单个文件
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

# 输出 PNG 格式
mermaid-extractor -f png README.md

# 自定义 PNG 宽度和 DPI
mermaid-extractor -f png -w 3000 -d 600 README.md

# 保持原目录结构
mermaid-extractor -r --keep-structure docs/
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
