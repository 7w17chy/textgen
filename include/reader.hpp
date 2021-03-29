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

    // TODO: concept `Readable`
    template<typename R>
    class Reader
    {
    private:
        R contents;
    public:
        virtual string& read_all() = 0;
        virtual std::optional<string::slice> read() = 0;
        virtual string::slice read_while(bool (*func)(string::slice)) = 0;
    };

    template<typename R>
    class Line : public Reader<R>
    {
    private:
        std::optional<size_t> number;
        string contents;
    public:
        // as an iterator; maybe return contents and line number?
        class iterator : std::iterator<std::input_iterator_tag, string::slice>
        {
        private:
            const char* index;
        public:
            iterator(const char* c)
                : index(c)
            {}
            
            reference operator*();
            void operator++();
            void operator++(int);
            bool operator==(iterator);
            bool operator!=(iterator);
        };

        iterator begin() { return iterator(contents.data()); }
        iterator end() { return iterator(contents.data()[contents.size() - 1]); }
        
        string& read_all() override;
        std::optional<string::slice> read() override;
        string::slice read_while(bool (*func)(string::slice)) override;
    };

    template<typename R>
    class Word : public Reader<R>
    {
    public:
        string& read_all() override;
        std::optional<string::slice> read() override;
        string::slice read_while(bool (*func)(string::slice)) override;
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
