#ifndef ROMEO_ARRAY_H__
#define ROMEO_ARRAY_H__
#include <vector>
#include "carray.h"

namespace ROMEO {
    template<typename T, int64_t N>
    class array{
    public:
        array()
        : m_data(NULL)
        , m_numel(0)
        , owns_storage(true) {}

        array(T* data_, carray<int64_t, N>& size_)
        : m_data(data_)
        , m_size(size_)
        , m_numel(compute_numel())
        , owns_storage(false) {}

        array(carray<int64_t, N>& size_)
        : m_size(size_)
        , m_numel(compute_numel())
        , owns_storage(true) {
            storage.resize(m_numel);
            m_data = &storage[0];
        }

        int resize(carray<int64_t, N>& size_) {
            if (owns_storage) {
                m_size = size_;
                m_numel = compute_numel(); 
                storage.resize(m_numel);
                m_data = &storage[0];
                return 0;
            }
            return 1;
        }

        T* data() {return m_data; }
        int64_t numel()  { return m_numel; }
        carray<int64_t, N>& size()  { return m_size;}
        int64_t size(int64_t idx) { return m_size[idx]; }


        T& operator[](int64_t Index) const {
            //assert(Index < Length && "Invalid index!");
            return m_data[Index];
        }
        T& operator[](int64_t Index)  {
            //assert(Index < Length && "Invalid index!");
            return m_data[Index];
        }

        
    private:
        T * m_data;
        carray<int64_t, N> m_size;
        int64_t m_numel;
        std::vector<T> storage;
        bool owns_storage;
        
        int64_t compute_numel() { 
            float n=1;
            for(int64_t i=0; i<N; i++) n*=m_size[i];
            return n;
        }

        
    };
};

#endif
