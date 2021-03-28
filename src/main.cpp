#include <iostream>
#include "reader.hpp"
using namespace reader;

int main()
{
    string str = string("henlo");
    for (char& chr : str) std::cout << str << std::endl;
    return 0;
}
