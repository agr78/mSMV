#include "mex.h"
#include "matrix.h"
#include "romeo.h"
#include "utility.h"

template<int N> struct mxClassID_to { typedef char type; };
template<> struct mxClassID_to<mxDOUBLE_CLASS> { typedef double type; };
template<> struct mxClassID_to<mxSINGLE_CLASS> { typedef float type; };

template<int N, typename Tout>
void read_data_impl(const mxArray* in, ROMEO::array<Tout,3>& out)
{
    typedef typename mxClassID_to<N>::type T;
    mwSize n = mxGetNumberOfDimensions(in);
    if (3 != n) {
        mexErrMsgTxt("Argument %d should be 3-dimensional.");
    }
    const mwSize *dim_array=mxGetDimensions(in);
    carray<int64_t, 3> size;
    for (int64_t j=0; j<3; j++) size[j] = (int64_t)dim_array[j];
    out.resize(size);
    for (int64_t j=0; j<out.numel(); j++) 
        out[j] = (Tout)(((T*)mxGetData(in))[j]);
}

template<typename Tout>
void read_data(const mxArray* in, ROMEO::array<Tout,3>& out)
{
    if (mxIsComplex(in)) {
        mexErrMsgTxt("Argument %d should be real single/double.");
    }
#define convert(a) \
    case a : return read_data_impl<a,Tout>(in,out); break;
    
    switch(mxGetClassID(in)) {
        convert(mxDOUBLE_CLASS);
        convert(mxSINGLE_CLASS);
        default:
            mexErrMsgTxt("Inputs must be single or double.");
    }
    
#undef convert
    return;
}

template<int N, typename Tin>
mxArray* write_data_impl(ROMEO::array<Tin,3>& in)
{
    mwSize dim_array[3];
    for (int64_t j=0; j<3; j++) dim_array[j] = in.size(j);
    mxArray* out = mxCreateNumericArray(3, dim_array, (mxClassID)N, mxREAL);
    typedef typename mxClassID_to<N>::type T;
    for (int64_t j=0; j<in.numel(); j++)
        ((T*)mxGetData(out))[j] = (T)in[j];
    return out;
}

template<typename Tin>
mxArray* write_data(ROMEO::array<Tin,3>& in, mxClassID id)
{
#define convert(a) \
    case a : return write_data_impl<a,Tin>(in); break;
    
    switch(id) {
        convert(mxDOUBLE_CLASS);
        convert(mxSINGLE_CLASS);
        default:
            mexErrMsgTxt("Output must be single or double.");
    }
    
#undef convert
    return NULL;
}

typedef struct {
    std::string name;
    mxArray *ptr;
} mxField; 

std::vector<mxField> get_mxField(const mxArray* ptr)
{   
    std::vector<mxField> f;
    if (mxGetNumberOfElements(ptr)<1) return f;
    int nfields = mxGetNumberOfFields(ptr);
    for (int j=0; j<nfields; j++) {
        mxField m;
        m.ptr = mxGetFieldByNumber(ptr,0,j);
        if (m.ptr != NULL) {
            m.name = mxGetFieldNameByNumber(ptr,j);
            f.push_back(m);
        }
    }
    return f;
}

bool get_bool(const mxArray* ptr) {
    void * dptr = mxGetData(ptr);
    if (NULL == dptr) {
        mexErrMsgTxt("invalid bool.");
    };
    switch(mxGetClassID(ptr)) {
        case mxLOGICAL_CLASS:
            return *((mxLogical*)ptr) ? true : false;
            break;
        case mxSINGLE_CLASS:
            return *((float*)ptr) ? true : false;
            break;
        case mxDOUBLE_CLASS:
            return *((double*)ptr) ? true : false;
            break; 
        default:
            mexErrMsgTxt("invalid bool.");
    }
}

std::string get_string(mxArray* ptr)
{
    if (mxCHAR_CLASS != mxGetClassID(ptr)) {
        mexErrMsgIdAndTxt( "MATLAB:explore:invalidStringArray",
                "variable is not a string.");
    }
    size_t len = mxGetNumberOfElements(ptr);
    std::string str(len+1,'\0');
    if (mxGetString(ptr, &str[0],len+1) != 0) {
        mexErrMsgIdAndTxt( "MATLAB:explore:invalidStringArray",
                "Could not convert string data.");
    }
    str.resize(len);
    return str;
}

/* interface */
void mexFunction( int nlhs, mxArray      *plhs[],
		          int nrhs, const mxArray *prhs[]) {
    if (nrhs ==0) {
        mexErrMsgTxt("at least 1 input required.");
    }
    
    ROMEO::flags_t flags = ROMEO::W_INVALID;
    ROMEO::array<float,3> phase;
    ROMEO::options_t options;
    int phase_idx = -1;
    
    for (int i=0; i<nrhs; i++) {
        if (mxIsStruct(prhs[i])) {
            std::vector<mxField> f = get_mxField(prhs[i]);
            for (int j=0; j<f.size(); j++) {
                if (f[j].name == "weights") {
                    std::string buf = get_string(f[j].ptr);
                    if ( 4 != buf.size()) {
                        mexErrMsgTxt("argument to weights should be a four character string (0s and 1s).");
                    }
                    for (int k=0; k<4; k++) {
                        if (buf[k]=='1') flags = (ROMEO::flags_t)(flags | (1<< k));
                    }
                } else if (f[j].name == "correctglobal") {
                    options.correctglobal = get_bool(f[j].ptr);
                }
            }
        } else if (0 == phase.numel()) {
            read_data(prhs[i], phase);
            phase_idx = i;
        } else if (0 == options.mag.numel()) {
            read_data(prhs[i], options.mag);
        } else if (0 == options.mask.numel()) {
            read_data(prhs[i], options.mask);
        } 
    }
    if (0 == phase.numel()) {
        mexErrMsgTxt("No phase data provided.");
    }
    if (ROMEO::W_INVALID != flags) {
        options.flags = flags;
        
    }
    printf("flags = %d\n", options.flags);
    ROMEO::unwrap(phase, options);
    
    const mxArray *ptr = prhs[phase_idx];
    if (nlhs>0) {
        plhs[0] = write_data(phase,  mxGetClassID(ptr));
    }
            
    return;
}

