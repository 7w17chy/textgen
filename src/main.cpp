#include <iostream>
#include "reader.hpp"
using namespace basic;

int main()
{
    string str = string("henlo");
    for (char& chr : str) std::cout << chr << std::endl;
    return 0;
}
