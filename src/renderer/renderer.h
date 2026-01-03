#ifndef RENDERER_H
#define RENDERER_H

#include "config/config.h"
#include "mermaid/mermaid_extractor.h"
#include <string>

namespace Renderer {

class Renderer {
private:
    Config config;

public:
    Renderer(const Config& cfg) : config(cfg) {}

    // 渲染单个图表
    bool render(const MermaidChart& chart, const std::string& outputPath);

    // 检查 mmdc 可用性
    bool checkMmdcAvailable();
};

} // namespace Renderer

#endif // RENDERER_H
