#ifndef CARRAY_H__
#define CARRAY_H__
#include <stddef.h>
#include <iostream>
#include <algorithm>



namespace carray_detail {
    template <typename T>
    struct add_pointer {
        typedef T* type;
    };
    
} // detail

/**
 * An implementation of C++11's <code>std::array</code> 
 * for compilers in C++03 mode that lack TR1.
 * 
 * Main differences with usual TR1 array:
 * 
 * * does not implement <code>array.at</code>.
 * * does not implement cbegin, cend, crbegin, crend.
 * 
 * @sa https://wg21.link/n1479
 * 
 */
template <typename T, size_t N>
struct carray {
    
    typedef T value_type;
    typedef T const           const_value_type;
    enum{ const_size = N};

    typedef size_t            size_type;
    typedef ptrdiff_t         difference_type;

    typedef typename carray_detail::add_pointer<T>::type    pointer;
    typedef typename carray_detail::add_pointer<const_value_type>::type const_pointer;
    
    typedef T&           reference;
    typedef T const&     const_reference;
    
    typedef pointer           iterator;
    typedef const_pointer     const_iterator;
    typedef std::reverse_iterator<iterator> reverse_iterator;
    typedef std::reverse_iterator<const_iterator> const_reverse_iterator;
    
    carray() {
      fill(T());
    }   
    carray(const T arr[N]) {
      std::copy(arr, arr+N, begin());
    }   
    carray(T const& t) {
      fill(t);
    }   
 
    pointer         data () { return elems; }
    const_pointer   data () const { return elems; }
    size_t     size () const { return N; }
    size_t     max_size () const { return N; }
    bool       empty () const { return false; }
    
    reference       front () { return elems[0]; }
    const_reference front () const { return elems[0]; }
    reference       back () { return elems[N-1]; }
    const_reference back () const { return elems[N-1]; }
    
    template<typename sizeT>
    reference       operator[] (sizeT i) { return elems[i]; }
    template<typename sizeT>
    const_reference operator[] (sizeT i) const { return elems[i]; }
    
    iterator        begin () { return elems; }
    const_iterator  begin () const { return elems; }
    iterator        end () { return elems+N; }
    const_iterator  end () const { return elems+N; }
   
    operator T*() { return data(); }
 
    void fill (T const& t) {
        std::fill(this->begin(), this->end(), t);
    }
    
    friend bool operator== (carray const& a1, carray const& a2) {
        return std::equal(a1.begin(), a1.end(), a2.begin());
    }
    friend bool operator< (carray const& a1, carray const& a2) {
        return std::lexicographical_compare(a1.begin(), a1.end(), a2.begin(), a2.end());
    }

    private:
    T elems[N];
};

template<typename T, size_t N>
std::ostream& operator<<(std::ostream& s, carray<T, N> const& vec)
{
  s << "[ ";
  for(typename carray<T,N>::const_iterator it = vec.begin(); it != vec.end(); ++it) {
    s << (*it) << " ";
  }
  s << "]";
  return s;
}


#endif
