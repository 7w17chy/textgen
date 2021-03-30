#include "reader.hpp"
using namespace basic;

// use utf8
[[nodiscard]] bool basic::isNoise(char c) noexcept
{
    return c == '\n' || c == '\t' || c == ' '; 
}

void basic::skipNoise(string::slice slc)
{
    for (const char& chr : slc)
        if (!isNoise(chr)) break;
}

void basic::skipNotNoise(string::slice slc)
{
    for (const char& chr : slc)
        if (isNoise(chr)) break;
}

void string::slice::operator++()
{
    ++ptr;
}

void string::slice::operator++(int val)
{
    ptr += static_cast<ptrdiff_t>(val);
}

bool string::slice::operator!=(string::slice other)
{
    return this->ptr != other.ptr && this->last != other.last;
}

bool string::slice::operator==(string::slice other)
{
    return !(*this != other);
}

string::slice::reference string::slice::operator*()
{
    return *ptr;
}

string::slice string::slice::begin()
{
    return slice(ptr, last);
}

string::slice string::slice::end()
{
    return slice(last, last);
}

