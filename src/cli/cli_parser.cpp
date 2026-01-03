#include "cli_parser.h"
#include <iostream>
#include <getopt.h>
#include <cstdlib>

namespace CLI {

Parser::Parser(int argc, char* argv[]) {
    // 定义长选项
    static struct option longOptions[] = {
        {"output",        required_argument, 0, 'o'},
        {"format",        required_argument, 0, 'f'},
        {"recursive",     no_argument,       0, 'r'},
        {"width",         required_argument, 0, 'w'},
        {"height",        required_argument, 0, 'h'},
        {"dpi",           required_argument, 0, 'd'},
        {"keep-structure", no_argument,      0, 'k'},
        {"verbose",       no_argument,       0, 'v'},
        {"version",       no_argument,       0, 'V'},
        {"help",          no_argument,       0, 'H'},
        {0, 0, 0, 0}
    };

    // 解析循环
    int optionIndex = 0;
    int c;
    while ((c = getopt_long(argc, argv, "o:f:rw:h:d:kvV",
                            longOptions, &optionIndex)) != -1) {
        switch (c) {
            case 'o': config.outputDir = optarg; break;
            case 'f': config.format = optarg; break;
            case 'r': config.recursive = true; break;
            case 'w': config.pngWidth = std::stoi(optarg); break;
            case 'h': config.pngHeight = std::stoi(optarg); break;
            case 'd': config.pngDPI = std::stoi(optarg); break;
            case 'k': config.keepStructure = true; break;
            case 'v': config.verbose = true; break;
            case 'V': showVersion(); exit(0);
            case 'H': showHelp(); exit(0);
            default:
                std::cerr << "使用 'mermaid-extractor --help' 查看帮助\n";
                exit(1);
        }
    }

    // 获取输入路径
    if (optind < argc) {
        config.inputPath = argv[optind];
    } else {
        std::cerr << "错误: 缺少输入参数\n";
        showHelp();
        exit(1);
    }

    // 验证配置
    if (!config.validate()) {
        exit(1);
    }
}

void Parser::showHelp() const {
    std::cout << "Mermaid Extractor v1.0.0\n\n";
    std::cout << "用法: mermaid-extractor [options] <input>\n\n";
    std::cout << "选项:\n";
    std::cout << "  -o, --output <dir>     输出目录 (默认: ./output)\n";
    std::cout << "  -f, --format <fmt>     输出格式: svg|png (默认: svg)\n";
    std::cout << "  -r, --recursive        递归处理子目录\n";
    std::cout << "  -w, --width <px>       PNG 宽度 (默认: 2000)\n";
    std::cout << "  -h, --height <px>      PNG 高度 (默认: 自动)\n";
    std::cout << "  -d, --dpi <value>      PNG DPI (默认: 300)\n";
    std::cout << "  --keep-structure       保持原目录结构\n";
    std::cout << "  --verbose              详细输出模式\n";
    std::cout << "  -v, --version          显示版本信息\n";
    std::cout << "  -h, --help             显示此帮助信息\n";
}

void Parser::showVersion() const {
    std::cout << "Mermaid Extractor v1.0.0\n";
    std::cout << "从 Markdown 文件中提取 Mermaid 图表\n";
}

} // namespace CLI
