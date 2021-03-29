#pragma once

#include <string>
#include <optional>
#include <iterator>
//#include <concepts>

namespace reader
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
    
    void skipNoise(string::slice);
    void skipNotNoise(string::slice);
    [[nodiscard]] bool isNoise(char) noexcept;
    
    template<typename R>
    class Reader
    {
    private:
        R contents;
    public:
        class iterator : public std::iterator<std::input_iterator_tag, string::slice,
                                              string::slice, const string::slice*, string::slice>
        {
	// each reader iterator will have to need it's own reader type so that it can `poll` with `read`
        public:
            std::optional<size_t> index_into;
            explicit iterator(std::optional<size_t> ind) : index_into(ind) {}
        
            string::slice operator++(); // advance with reader::read() etc.
            string::slice operator++(int);
            bool operator!=(iterator);
            bool operator==(iterator);
            string::slice operator*();
        };

        iterator begin() const { return iterator(0); }
        iterator end() const { return iterator(NULL); }
        
        virtual string& read_all() const = 0;
        virtual std::optional<string::slice> read() const = 0;
    };

    template<typename R>
    class Line : public Reader<R>
    {
        std::optional<size_t> number;
        string contents;
    public:
        string& read_all() const override;
        std::optional<string::slice> read() const override;
    };

    template<typename R>
    class Word : public Reader<R>
    {
    public:
        string& read_all() const override;
        std::optional<string::slice> read() const override;
    };

    // template<typename T>
    // concept Readable = std::is_base_of<reader::Reader, T>();
    //
    // template<Readable R>
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
}
