#include "reader.hpp"
using namespace reader;

// use utf8
[[nodiscard]] static bool isNoise(const char8_t c) noexcept
{
    return c == '\n' || c == '\t' || c == ' '; 
}

[[nodiscard]] static size_t skipNoise(const std::string& str, size_t index)
{
    size_t count = 0;
    std::string::iterator it = str[index];
    for (; it != str.end(); ++it) if (isNoise(*it)) ++count;
    return count;
}

size_t skipNotNoise(const std::string&, size_t)
{
    return 0;
}
