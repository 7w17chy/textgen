CC=g++
# anstatt `-Og`: -ggdb3 for specific gdb debug symbols
DEBUGFLAGS=--std=c++20 -Iinclude -Wall -Wextra -Og -fsanitize=address
OUT=build

textgen: src/*.cpp
	${CC} ${DEBUGFLAGS} src/*.cpp -o ${OUT}/textgen.debug
