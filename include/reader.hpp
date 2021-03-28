#pragma once

#include <string>
#include <valarray>
#include <optional>
#include <iterator>
#include <vector>

namespace reader
{
    class string : public std::basic_string<char8_t>
    {
    public:
        class slice
        {
        private:
            const char* ptr;
            uint32_t offset;
            uint32_t end;
        public:
            slice(const char* str, uint32_t begin, uint32_t end)
                : ptr(str + begin), offset(0), end(end)
            {}

            operator++();
            operator++(int);
        };

        string(const char8_t* str)
            : std::basic_str<char8_t>(str)
        {}

        slice sliceInto(uint32_t begin, uint32_t end); 
    };
    
    [[nodiscard]] static size_t skipNoise(string::slice, size_t);
    [[nodiscard]] static bool isNoise(char8_t) noexcept;
    
    // use concepts
    // template<const Reader R>
    // std::vector<std::slice> filter(R, bool(*filterFn)(const std::string&))
    // {
    //     std::vector<std::slice> retval();
    //     // we know `Reader` implements iterator
    //     for (auto it& : R) {
    //         const std::string& contents = it.getContents();
    //         if(filterFn(contents)) retval.push_back(slice(contents));
    //     }

    //     return retval;
    // }
    
    class Reader
    {
    public:
        class iterator : public std::iterator<std::input_iterator_tag, string::slice,
                                              string::slice, const string::slice*, string::slice>
        {
        public:
            std::optional<size_t> index_into;
            explicit iterator(std::optional<size_t> ind) : index_into(ind) {}
        
            string::slice operator++();
            string::slice operator++(int);
            bool operator!=(iterator);
            bool operator==(iterator);
            string::slice operator*();
        };

        iterator begin() const { return iterator(0); }
        iterator end() const { return iterator(NULL); }
        
        virtual string& read_all() const = 0;
        virtual string::slice read() const = 0;
    };
     
    class Line : public Reader
    {
        std::optional<size_t> number;
        string contents;
    public:
        string& read_all() const override;         
        string::slice read() const override;
    };
     
    class Word : public Reader
    {
    public:
        string& read_all() const override;
        string::slice read() const override;
    };
}
