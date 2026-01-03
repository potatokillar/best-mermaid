#ifndef CONFIG_H
#define CONFIG_H

#include <string>

struct Config {
    // 输入
    std::string inputPath;
    bool recursive = false;

    // 输出
    std::string outputDir = "./output";
    std::string format = "svg";  // svg | png
    bool keepStructure = false;

    // PNG 设置
    int pngWidth = 2000;
    int pngHeight = 0;
    int pngDPI = 300;

    // 其他
    bool verbose = false;

    // 验证配置
    bool validate() const;
};

#endif // CONFIG_H
