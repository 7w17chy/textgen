#pragma once

#include <string>
#include <valarray>
#include <optional>
#include <iterator>
#include <vector>

namespace reader
{
    [[nodiscard]] static size_t skipNoise(const std::string&, size_t);
    [[nodiscard]] static bool isNoise(char8_t) noexcept;

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
        virtual std::vector<std::slice> filter(bool(*filterFn)(const std::string&)) const = 0;
    };
     
    class Line : public Reader
    {
        std::optional<size_t> number;
        std::string contents;
    public:
        std::string& read_all() const override;         
        std::slice read() const override;
        std::vector<std::slice> filter(bool(*filterFn)(const std::string&)) const override;
    };
     
    class Word : public Reader
    {
    public:
        std::string& read_all() const override;
        std::slice read() const override;
        std::vector<std::slice> filter(bool(*filterFn)(const std::string&)) const override;
    };
}
