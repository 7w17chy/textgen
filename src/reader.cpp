#include "reader.hpp"
using namespace reader;

void string::slice::operator++()
{
    ++ptr;
    ++offset;
}

void string::slice::operator++(int val)
{
    ptr += static_cast<ptrdiff_t>(val);
    offset += val;
}

bool string::slice::operator!=(string::slice other)
{
    return this->ptr != other.ptr && this->offset != other.offset;
}

bool string::slice::operator==(string::slice other)
{
    return !(*this != other);
}

string::slice::reference operator*(string::slice rhs)
{
    return *(rhs.data());
}

string::slice string::slice::begin()
{
    return slice(ptr, 0, last);
}

string::slice string::slice::end()
{
    return slice(ptr, last, last);
}

// use utf8
[[nodiscard]] static bool isNoise(char8_t c) noexcept
{
    return c == '\n' || c == '\t' || c == ' '; 
}

[[nodiscard]] static size_t skipNoise(string::slice str, size_t index)
{
    size_t count = 0;
    // std::string::iterator it = str[index];
    // for (; it != str.end(); ++it) if (isNoise(*it)) ++count;
    return count;
}

size_t skipNotNoise(const std::string&, size_t)
{
    return 0;
}
