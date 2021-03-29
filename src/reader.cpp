#include "reader.hpp"
using namespace reader;

// use utf8
[[nodiscard]] bool reader::isNoise(char c) noexcept
{
    return c == '\n' || c == '\t' || c == ' '; 
}

void reader::skipNoise(string::slice slc)
{
    for (const char& chr : slc)
        if (!isNoise(chr)) break;
}

void reader::skipNotNoise(string::slice slc)
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
    // return slice(ptr, 0, last);
    return slice(ptr, last);
}

string::slice string::slice::end()
{
    // return slice(ptr, last, last);
    return slice(last, last);
}
