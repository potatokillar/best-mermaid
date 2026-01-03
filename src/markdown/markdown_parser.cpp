#include "markdown_parser.h"
#include <fstream>
#include <sstream>
#include <stdexcept>
#include <regex>
#include <algorithm>
#include <cctype>

namespace Markdown {

std::vector<MermaidChart> Parser::parseFile(const std::string& filePath) {
    // 读取文件
    std::ifstream file(filePath);
    if (!file.is_open()) {
        throw std::runtime_error("无法打开文件: " + filePath);
    }

    std::string content((std::istreambuf_iterator<char>(file)),
                        std::istreambuf_iterator<char>());
    file.close();

    return parseContent(content, filePath);
}

std::vector<MermaidChart> Parser::parseContent(
    const std::string& content,
    const std::string& sourceFile)
{
    std::vector<MermaidChart> charts;

    // 分割内容为行
    std::vector<std::string> lines;
    std::stringstream ss(content);
    std::string line;
    while (std::getline(ss, line)) {
        lines.push_back(line);
    }

    // 状态机
    enum State { NORMAL, IN_MERMAID };
    State state = NORMAL;
    std::string currentTitle;
    std::string currentContent;
    size_t startLine = 0;
    int chartIndex = 0;

    // 正则表达式
    std::regex titleRegex(R"(^#{1,6}\s+(.+)$)");
    std::regex mermaidStart(R"(^```\s*mermaid\s*$)");
    std::regex codeEnd(R"(^```\s*$)");

    for (size_t i = 0; i < lines.size(); ++i) {
        const auto& line = lines[i];

        if (state == NORMAL) {
            // 检查标题
            std::smatch titleMatch;
            if (std::regex_match(line, titleMatch, titleRegex)) {
                currentTitle = titleMatch[1].str();
            }

            // 检查代码块开始
            if (std::regex_match(line, mermaidStart)) {
                state = IN_MERMAID;
                startLine = i + 1;
                currentContent.clear();
            }
        }
        else if (state == IN_MERMAID) {
            // 检查代码块结束
            if (std::regex_match(line, codeEnd)) {
                // 创建图表对象
                MermaidChart chart;
                chart.title = extractAndCleanTitle(currentTitle);
                chart.content = currentContent;
                chart.index = ++chartIndex;
                chart.startLine = startLine;
                chart.sourceFile = sourceFile;

                if (!chart.content.empty()) {
                    charts.push_back(chart);
                }

                state = NORMAL;
            } else {
                currentContent += line + "\n";
            }
        }
    }

    // 检查未闭合的代码块
    if (state == IN_MERMAID) {
        throw std::runtime_error("未闭合的 Mermaid 代码块");
    }

    return charts;
}

std::string Parser::extractAndCleanTitle(const std::string& rawTitle) {
    if (rawTitle.empty()) {
        return "chart";
    }

    std::string cleaned;
    for (char c : rawTitle) {
        if (std::isalnum(static_cast<unsigned char>(c)) ||
            c == '-' || c == '_' || c == ' ') {
            cleaned += c;
        }
    }

    // 替换空格为连字符
    std::replace(cleaned.begin(), cleaned.end(), ' ', '-');

    // 转为小写
    std::transform(cleaned.begin(), cleaned.end(), cleaned.begin(),
                   [](unsigned char c) { return std::tolower(c); });

    // 限制长度
    if (cleaned.length() > 50) {
        cleaned = cleaned.substr(0, 50);
    }

    return cleaned;
}

} // namespace Markdown
