#ifndef ROMEO_PRIORITIQUEUE_H___
#define ROMEO_PRIORITIQUEUE_H___

#include <vector>
#include <iostream>
#include "utility.h"

template<typename T>
class PQueue {
    public:
        PQueue(){}

        PQueue(int64_t nbins)
        : m_min(nbins+1)
        , m_nbins(nbins)
        , content(nbins) {}

        PQueue(int64_t nbins, T item, int64_t weight)
        : m_min(nbins+1)
        , m_nbins(nbins)
        , content(nbins) {
            enqueue(item, weight);
        }

        void initialize(int64_t nbins) {
          m_min = nbins + 1;
          m_nbins = nbins;
          content.resize(nbins);
        }

        void enqueue(T item, int64_t weight) {
            content[weight-1].push_back(item);
            m_min = std::min(m_min, weight);
        }

        T dequeue() {
          T elem = content[m_min-1].back();
          content[m_min-1].pop_back();
          // increase smallestbin, if elem was last in bin
          while ((m_min <= m_nbins) && content[m_min-1].empty()){
            m_min++;
          }
          return elem;
        }

        bool isempty() {
          return m_min > m_nbins;
        }

        int64_t min() { return m_min;}

        int64_t nbins() { return m_nbins;}
        
    private:
        int64_t m_min;
        int64_t m_nbins;
        std::vector<std::vector<T> > content;

        friend std::ostream& operator<<(std::ostream& s, PQueue const& q)
        {
          s << "[ " << std::endl;
          s << "  m_min     = " << q.m_min << std::endl;
          s << "  m_nbins   = " << q.m_nbins << std::endl;
          s << "  content = " << q.content << std::endl;
          s << "]" << std::endl;
          return s;
        }


};



/*
template<typename T>
std::ostream& operator<<(std::ostream& s, PQueue<T> const& q)
{
  s << "[ " << std::endl;
  s << "  m_min     = " << q.m_min << std::endl;
  s << "  m_nbins   = " << q.m_nbins << std::endl;
  s << "  content = [ " << q.content;
  s << "            ]" << std::endl;
  s << "]"<< std::endl;
  return s;
}
*/

#endif