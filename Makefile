CC=g++
CXXFLAGS=--std=c++20 -Iinclude -Wall -Wextra
OUT=build

textgen: src/*.cpp
	${CC} ${CXXFLAGS} src/*.cpp -o ${OUT}
