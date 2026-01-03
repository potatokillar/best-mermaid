#ifndef MARKDOWN_PARSER_H
#define MARKDOWN_PARSER_H

#include "mermaid/mermaid_extractor.h"
#include <vector>
#include <string>

namespace Markdown {

class Parser {
public:
    // 从文件解析
    std::vector<MermaidChart> parseFile(const std::string& filePath);

    // 从内容解析
    std::vector<MermaidChart> parseContent(const std::string& content,
                                           const std::string& sourceFile);

private:
    // 提取和清理标题
    static std::string extractAndCleanTitle(const std::string& rawTitle);
};

} // namespace Markdown

#endif // MARKDOWN_PARSER_H
