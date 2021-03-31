#include <iostream>
#include <fstream>

#include "reader.hpp"
using namespace basic;

int main()
{
    string str = string("henlo");
    for (char& chr : str) std::cout << chr << std::endl;

    std::fstream stream("res/test.txt", stream.in);
    if (!stream.is_open()) std::cout << "Could not open fstream!\n";

    char buffer[10];
    stream.getline(buffer, 10);
    std::cout << buffer << std::endl;

    return 0;
}
