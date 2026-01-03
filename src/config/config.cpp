#include "config.h"
#include <iostream>

bool Config::validate() const {
    // 检查格式
    if (format != "svg" && format != "png") {
        std::cerr << "错误: 无效的格式 '" << format
                  << "'，支持: svg, png\n";
        return false;
    }

    // 检查 PNG 参数
    if (format == "png") {
        if (pngWidth <= 0) {
            std::cerr << "错误: PNG 宽度必须大于 0\n";
            return false;
        }
        if (pngDPI <= 0) {
            std::cerr << "错误: PNG DPI 必须大于 0\n";
            return false;
        }
    }

    return true;
}
