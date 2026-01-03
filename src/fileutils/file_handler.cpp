#include "file_handler.h"
#include "markdown/markdown_parser.h"
#include "renderer/renderer.h"
#include <iostream>
#include <filesystem>
#include <spdlog/spdlog.h>

namespace fs = std::filesystem;

namespace FileUtils {

void ProcessingStats::printSummary() const {
    std::cout << "\n========================================\n";
    std::cout << "处理摘要\n";
    std::cout << "========================================\n";
    std::cout << "处理文件数:   " << filesProcessed << "\n";
    std::cout << "提取图表数:   " << chartsExtracted << "\n";
    std::cout << "渲染成功数:   " << chartsRendered << "\n";
    std::cout << "渲染失败数:   " << errors << "\n";

    if (chartsExtracted > 0) {
        double successRate = (double)chartsRendered / chartsExtracted * 100.0;
        std::cout << std::fixed;
        std::cout.precision(1);
        std::cout << "成功率:       " << successRate << "%\n";
    }

    std::cout << "========================================\n";
}

std::vector<std::string> FileHandler::scanDirectory(const std::string& dirPath) {
    std::vector<std::string> files;

    for (const auto& entry : fs::directory_iterator(dirPath)) {
        if (entry.is_regular_file()) {
            std::string path = entry.path().string();
            // 检查文件扩展名
            if (path.size() >= 3 && path.substr(path.size() - 3) == ".md") {
                files.push_back(path);
            }
        }
    }

    return files;
}

std::vector<std::string> FileHandler::scanDirectoryRecursive(const std::string& dirPath) {
    std::vector<std::string> files;

    for (const auto& entry : fs::recursive_directory_iterator(dirPath)) {
        if (entry.is_regular_file()) {
            std::string path = entry.path().string();
            // 检查文件扩展名
            if (path.size() >= 3 && path.substr(path.size() - 3) == ".md") {
                files.push_back(path);
            }
        }
    }

    return files;
}

std::string FileHandler::generateOutputPath(const std::string& inputFile,
                                             const MermaidChart& chart) {
    std::string filename = chart.generateFileName(config.format);

    if (config.keepStructure) {
        // 保持目录结构
        fs::path inputPath(inputFile);
        fs::path relativePath = fs::relative(
            inputPath.parent_path(),
            config.inputPath
        );

        fs::path outputPath = fs::path(config.outputDir) / relativePath / filename;

        // 创建父目录
        fs::create_directories(outputPath.parent_path());

        return outputPath.string();
    } else {
        // 扁平输出
        return (fs::path(config.outputDir) / filename).string();
    }
}

bool FileHandler::processFile(const std::string& inputPath) {
    spdlog::info("处理文件: {}", inputPath);

    try {
        // 1. 解析 Markdown
        Markdown::Parser parser;
        auto charts = parser.parseFile(inputPath);

        if (charts.empty()) {
            spdlog::warn("未找到 Mermaid 图表: {}", inputPath);
            stats.filesProcessed++;
            return true;  // 不算错误,只是没有图表
        }

        spdlog::info("提取到 {} 个图表", charts.size());

        // 2. 创建渲染器
        Renderer::Renderer renderer(config);

        // 3. 渲染每个图表
        int successCount = 0;
        for (const auto& chart : charts) {
            std::string outputPath = generateOutputPath(inputPath, chart);

            spdlog::debug("渲染图表 #{}: {} -> {}",
                         chart.index, chart.title, outputPath);

            bool success = renderer.render(chart, outputPath);

            if (success) {
                successCount++;
                spdlog::info("✓ 图表 #{}: {}", chart.index, chart.title);
            } else {
                spdlog::error("✗ 图表 #{} 渲染失败", chart.index);
            }
        }

        stats.filesProcessed++;
        stats.chartsExtracted += charts.size();
        stats.chartsRendered += successCount;
        stats.errors += (charts.size() - successCount);

        return successCount == charts.size();
    }
    catch (const std::exception& e) {
        spdlog::error("处理文件失败: {} - {}", inputPath, e.what());
        stats.errors++;
        return false;
    }
}

ProcessingStats FileHandler::processAll() {
    if (fs::is_regular_file(config.inputPath)) {
        // 单文件处理
        processFile(config.inputPath);
    }
    else if (fs::is_directory(config.inputPath)) {
        // 目录处理
        std::vector<std::string> files = config.recursive
            ? scanDirectoryRecursive(config.inputPath)
            : scanDirectory(config.inputPath);

        for (const auto& file : files) {
            processFile(file);
        }
    }

    return stats;
}

} // namespace FileUtils
