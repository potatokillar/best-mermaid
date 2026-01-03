#ifndef CLI_PARSER_H
#define CLI_PARSER_H

#include "config/config.h"
#include <string>

namespace CLI {

class Parser {
private:
    Config config;

public:
    Parser(int argc, char* argv[]);
    const Config& getConfig() const { return config; }

private:
    void showHelp() const;
    void showVersion() const;
};

} // namespace CLI

#endif // CLI_PARSER_H
