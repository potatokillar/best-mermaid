#ifndef MERMAID_EXTRACTOR_H
#define MERMAID_EXTRACTOR_H

#include <string>

struct MermaidChart {
    std::string title;        // 图表标题
    std::string content;      // Mermaid 源码
    int index;                // 序号(1开始)
    size_t startLine;         // 起始行号
    std::string sourceFile;   // 源文件路径

    // 生成输出文件名
    std::string generateFileName(const std::string& ext) const;
};

#endif // MERMAID_EXTRACTOR_H
