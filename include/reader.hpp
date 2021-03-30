#pragma once

#include <string>
#include <optional>
#include <iterator>
#include <fstream>

// TODO: use wide chars (char*_t) instead of `just` char

namespace basic
{

    class string : public std::basic_string<char>
    {
    public:
        class slice : public std::iterator<std::input_iterator_tag, const char>
        {
        private:
            const char* ptr;
            const char* last;
            
            slice(const char* fst, const char* lst)
                : ptr(fst), last(lst)
            {}
        public:
            slice(const char* str, ptrdiff_t begin, ptrdiff_t last)
                : ptr(str + begin), last(str + last)
            {}

            template<typename T>
            T size() const
            {
                ptrdiff_t diff = last - ptr;
                return static_cast<T>(diff);
            }

            slice begin();
            slice end();

            const char* data() const noexcept { return this->ptr; }
            
            void operator++();
            void operator++(int);
            bool operator!=(slice);
            bool operator==(slice);
            reference operator*();
        };

        string(const char* str)
            : std::basic_string<char>(str)
        {}

        const char* dataPtr() const noexcept
        {
            return this->data();
        }

        slice sliceInto(uint32_t begin, uint32_t end); 
    };

    [[nodiscard]] bool isNoise(char) noexcept;
    void skipNoise(string::slice);
    void skipNotNoise(string::slice);
}

namespace reader
{
    class reader : std::basic_fstream<char> {};
}
