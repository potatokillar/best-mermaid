#include "renderer.h"
#include <spdlog/spdlog.h>
#include <sstream>
#include <cstdio>
#include <memory>
#include <fstream>
#include <unistd.h>  // for getpid

namespace Renderer {

bool Renderer::checkMmdcAvailable() {
    std::unique_ptr<FILE, decltype(&pclose)> pipe(popen("which mmdc", "r"), pclose);
    if (!pipe) return false;

    char buffer[128];
    return (fgets(buffer, sizeof(buffer), pipe.get()) != nullptr);
}

bool Renderer::render(const MermaidChart& chart,
                      const std::string& outputPath) {
    // 创建临时 .mmd 文件
    std::string tempMmd = "/tmp/mermaid-extractor-";
    tempMmd += std::to_string(getpid()) + "-";
    tempMmd += std::to_string(chart.index) + ".mmd";

    {
        std::ofstream file(tempMmd);
        file << chart.content;
        file.close();
    }

    // 构建 mmdc 命令
    std::stringstream cmd;
    cmd << "mmdc -i " << tempMmd << " -o " << outputPath;

    if (config.format == "svg") {
        cmd << " -b transparent";  // 透明背景
    } else if (config.format == "png") {
        cmd << " -s " << (config.pngWidth / 800.0);  // 缩放因子
        cmd << " --scale " << (config.pngDPI / 96.0);
        if (config.pngHeight > 0) {
            cmd << " -h " << config.pngHeight;
        }
    }

    if (config.verbose) {
        spdlog::info("执行命令: {}", cmd.str());
    }

    // 执行命令
    std::unique_ptr<FILE, decltype(&pclose)> pipe(popen(cmd.str().c_str(), "r"), pclose);
    if (!pipe) {
        spdlog::error("无法执行命令: {}", cmd.str());
        std::remove(tempMmd.c_str());
        return false;
    }

    // 读取输出(用于错误诊断)
    char buffer[128];
    while (fgets(buffer, sizeof(buffer), pipe.get()) != nullptr) {
        if (config.verbose) {
            spdlog::debug("mmdc: {}", buffer);
        }
    }

    int returnCode = pclose(pipe.release());
    bool success = (returnCode == 0);

    // 清理临时文件
    std::remove(tempMmd.c_str());

    return success;
}

} // namespace Renderer
