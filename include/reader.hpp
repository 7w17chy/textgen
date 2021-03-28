#pragma once

#include <string>
#include <valarray>
#include <optional>
#include <iterator>
#include <vector>

namespace reader
{
    [[nodiscard]] static size_t skipNoise(const std::string&, size_t);
    [[nodiscard]] static bool isNoise(const char8_t) noexcept;

    class string : public std::string
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

        slice sliceInto(uint32_t begin, uint32_t end); 
    };
    
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
        class iterator : public std::iterator<std::input_iterator_tag, std::slice,
                                              std::slice, const std::slice*, std::slice>
        {
        public:
            std::optional<size_t> index_into;
            explicit iterator(std::optional<size_t> ind) : index_into(ind) {}
        
            std::slice operator++();
            std::slice operator++(int);
            bool operator!=(iterator);
            bool operator==(iterator);
            std::slice operator*();
        };

        iterator begin() const { return iterator(0); }
        iterator end() const { return iterator(NULL); }
        
        virtual std::string& read_all() const = 0;
        virtual std::slice read() const = 0;
    };
     
    class Line : public Reader
    {
        std::optional<size_t> number;
        std::string contents;
    public:
        std::string& read_all() const override;         
        std::slice read() const override;
    };
     
    class Word : public Reader
    {
    public:
        std::string& read_all() const override;
        std::slice read() const override;
    };
}
