#!/bin/bash
# 简单的编译脚本(不使用 CMake)

echo "编译 Mermaid Extractor..."

# 检查 Boost 是否安装
if ! pkg-config --exists boost_filesystem boost_system; then
    echo "错误: 未找到 Boost 库"
    echo "请运行: sudo apt-get install libboost-all-dev"
    exit 1
fi

# 编译选项
CXXFLAGS="-std=c++17 -Wall -Wextra -O2"
INCLUDES="-I/usr/include -Isrc"
LIBS="-lboost_filesystem -lboost_system -lpthread"

# 获取 Boost 版本相关的标志
BOOST_FLAGS=$(pkg-config --cflags --libs boost_filesystem boost_system)

# 源文件
SOURCES="
    src/main.cpp
    src/config/config.cpp
    src/cli/cli_parser.cpp
    src/markdown/markdown_parser.cpp
    src/mermaid/mermaid_extractor.cpp
    src/renderer/renderer.cpp
    src/fileutils/file_handler.cpp
"

# 编译
echo "编译中..."
g++ $CXXFLAGS $INCLUDES $SOURCES -o mermaid-extractor $BOOST_FLAGS $LIBS

if [ $? -eq 0 ]; then
    echo "编译成功! 可执行文件: ./mermaid-extractor"
    echo ""
    echo "使用方法:"
    echo "  ./mermaid-extractor --help"
    echo "  ./mermaid-extractor README.md"
else
    echo "编译失败!"
    exit 1
fi
