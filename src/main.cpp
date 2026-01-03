#include <iostream>
#include <exception>
#include <filesystem>

#include "cli/cli_parser.h"
#include "fileutils/file_handler.h"
#include "renderer/renderer.h"
#include <spdlog/spdlog.h>

namespace fs = std::filesystem;

void setupLogging(bool verbose) {
    if (verbose) {
        spdlog::set_level(spdlog::level::debug);
        spdlog::set_pattern("[%Y-%m-%d %H:%M:%S] [%^%l%$] %v");
    } else {
        spdlog::set_level(spdlog::level::info);
        spdlog::set_pattern("[%l] %v");
    }
}

int main(int argc, char* argv[]) {
    try {
        // 解析 CLI 参数
        CLI::Parser parser(argc, argv);
        Config config = parser.getConfig();

        // 初始化日志
        setupLogging(config.verbose);

        spdlog::info("Mermaid Extractor v1.0.0");

        // 检查 mmdc 可用性
        Renderer::Renderer renderer(config);
        if (!renderer.checkMmdcAvailable()) {
            std::cerr << "错误: 未找到 mermaid-cli (mmdc)\n";
            std::cerr << "请运行: npm install -g @mermaid-js/mermaid-cli\n";
            return 1;
        }

        // 创建输出目录
        fs::create_directories(config.outputDir);

        // 处理输入文件/目录
        FileUtils::FileHandler handler(config);
        FileUtils::ProcessingStats stats = handler.processAll();

        // 显示摘要
        stats.printSummary();

        return 0;
    }
    catch (const std::exception& e) {
        std::cerr << "错误: " << e.what() << "\n";
        return 1;
    }
}
