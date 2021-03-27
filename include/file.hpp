#pragma once

#include <string>

class File
{
    int descriptor;
public:
    // TODO: Rule of 5 -> copy and move constructor
    File(const std::string&);
    ~File();
};
