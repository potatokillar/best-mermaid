#include "mermaid_extractor.h"
#include <filesystem>
#include <sstream>
#include <iomanip>

namespace fs = std::filesystem;

std::string MermaidChart::generateFileName(const std::string& ext) const {
    // 获取文件名(不含路径和扩展名)
    fs::path sourcePath(sourceFile);
    std::string baseName = sourcePath.stem().string();

    // 格式: {文件名}-{标题}-{序号}.{扩展名}
    std::stringstream ss;
    ss << baseName << "-"
       << title << "-"
       << std::setw(3) << std::setfill('0') << index
       << "." << ext;

    return ss.str();
}
