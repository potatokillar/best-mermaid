#ifndef FILE_HANDLER_H
#define FILE_HANDLER_H

#include "config/config.h"
#include "mermaid/mermaid_extractor.h"
#include <string>
#include <vector>

namespace FileUtils {

struct ProcessingStats {
    int filesProcessed = 0;
    int chartsExtracted = 0;
    int chartsRendered = 0;
    int errors = 0;

    void printSummary() const;
};

class FileHandler {
private:
    Config config;
    ProcessingStats stats;

public:
    FileHandler(const Config& cfg) : config(cfg) {}

    // 处理所有输入
    ProcessingStats processAll();

    // 扫描目录
    std::vector<std::string> scanDirectory(const std::string& dirPath);
    std::vector<std::string> scanDirectoryRecursive(const std::string& dirPath);

    // 处理单个文件
    bool processFile(const std::string& inputPath);

    // 生成输出路径
    std::string generateOutputPath(const std::string& inputFile,
                                   const MermaidChart& chart);

    const ProcessingStats& getStats() const { return stats; }
};

} // namespace FileUtils

#endif // FILE_HANDLER_H
