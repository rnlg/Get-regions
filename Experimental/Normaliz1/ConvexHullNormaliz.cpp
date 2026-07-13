#include "WolframLibrary.h"
#include "libnormaliz/libnormaliz.h"
#include "normaliz_paths.h"
#include <vector>
#include <dlfcn.h>

EXTERN_C DLLEXPORT mint WolframLibrary_getVersion() { return WolframLibraryVersion; }
EXTERN_C DLLEXPORT int WolframLibrary_initialize(WolframLibraryData libData) { return LIBRARY_NO_ERROR; }
EXTERN_C DLLEXPORT void WolframLibrary_uninitialize(WolframLibraryData libData) {}

static void* load_lib(const char* env, const char* path, const char* name) {
    const char* p = getenv(env);
    void* h = p ? dlopen(p, RTLD_NOW|RTLD_GLOBAL|RTLD_DEEPBIND) : nullptr;
    if (!h) h = dlopen(path, RTLD_NOW|RTLD_GLOBAL|RTLD_DEEPBIND);
    if (!h) h = dlopen(name, RTLD_NOW|RTLD_GLOBAL|RTLD_DEEPBIND);
    return h;
}

__attribute__((constructor))
static void init() {
    load_lib("NORMALIZ_LIBGMP", NORMALIZ_LIBGMP_PATH, "libgmp.so.10");
    load_lib("NORMALIZ_LIBGMPXX", NORMALIZ_LIBGMPXX_PATH, "libgmpxx.so.4");
    load_lib("NORMALIZ_LIBNORMALIZ", NORMALIZ_LIBNORMALIZ_PATH, "libnormaliz.so.3");
}

EXTERN_C DLLEXPORT int NormalizInnerNormals(WolframLibraryData libData, mint Argc, MArgument *Args, MArgument Res) {
    if (Argc != 1) return LIBRARY_FUNCTION_ERROR;
    MTensor in = MArgument_getMTensor(Args[0]);
    if (libData->MTensor_getType(in) != MType_Integer || libData->MTensor_getRank(in) != 2)
        return LIBRARY_TYPE_ERROR;
    
    mint const* dims = libData->MTensor_getDimensions(in);
    mint n = dims[0], d = dims[1];
    mint* inData = libData->MTensor_getIntegerData(in);
    
    std::vector<std::vector<long>> pts(n, std::vector<long>(d));
    for (mint i = 0; i < n; i++)
        for (mint j = 0; j < d; j++)
            pts[i][j] = inData[i * d + j];
    
    try {
        libnormaliz::Cone<long> cone(libnormaliz::InputType::polytope, pts);
        cone.compute({libnormaliz::ConeProperty::SupportHyperplanes});
        const auto& hp = cone.getSupportHyperplanes();
        
        mint outDims[2] = {hp.size(), d};
        MTensor out;
        if (libData->MTensor_new(MType_Integer, 2, outDims, &out)) return LIBRARY_FUNCTION_ERROR;
        
        mint* outData = libData->MTensor_getIntegerData(out);
        for (mint i = 0; i < hp.size(); i++)
            for (mint j = 0; j < d; j++)
                outData[i * d + j] = hp[i][j];
        
        MArgument_setMTensor(Res, out);
    } catch (...) {
        return LIBRARY_FUNCTION_ERROR;
    }
    return LIBRARY_NO_ERROR;
}
