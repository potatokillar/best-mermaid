cmake_minimum_required(VERSION 3.15)
project(mermaid-extractor VERSION 1.0.0 LANGUAGES CXX)

# 设置 C++ 标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# 编译选项
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# 查找依赖
find_package(Boost 1.74 REQUIRED COMPONENTS filesystem regex)

# 如果找不到 spdlog 和 fmt,使用 FetchContent
include(FetchContent)

# spdlog
FetchContent_Declare(
    spdlog
    GIT_REPOSITORY https://github.com/gabime/spdlog.git
    GIT_TAG v1.13.0
)
FetchContent_MakeAvailable(spdlog)

# fmt
FetchContent_Declare(
    fmt
    GIT_REPOSITORY https://github.com/fmtlib/fmt.git
    GIT_TAG 10.2.1
)
FetchContent_MakeAvailable(fmt)

# 源文件
set(SOURCES
    src/main.cpp
    src/cli/cli_parser.cpp
    src/markdown/markdown_parser.cpp
    src/mermaid/mermaid_extractor.cpp
    src/renderer/renderer.cpp
    src/fileutils/file_handler.cpp
    src/config/config.cpp
)

# 头文件
set(HEADERS
    src/cli/cli_parser.h
    src/markdown/markdown_parser.h
    src/mermaid/mermaid_extractor.h
    src/renderer/renderer.h
    src/fileutils/file_handler.h
    src/config/config.h
)

# 创建可执行文件
add_executable(mermaid-extractor ${SOURCES} ${HEADERS})

# 链接库
target_link_libraries(mermaid-extractor
    PRIVATE
    Boost::filesystem
    Boost::regex
    spdlog::spdlog
    fmt::fmt
)

# 包含目录
target_include_directories(mermaid-extractor
    PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

# 安装规则
install(TARGETS mermaid-extractor
    RUNTIME DESTINATION bin
)

# 可选: 构建测试
option(BUILD_TESTS "Build unit tests" OFF)
if(BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()

# 可选: 覆盖率
option(COVERAGE "Enable coverage reporting" OFF)
if(COVERAGE)
    target_compile_options(mermaid-extractor PRIVATE --coverage)
    target_link_options(mermaid-extractor PRIVATE --coverage)
endif()
