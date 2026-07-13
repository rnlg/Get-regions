#include "WolframLibrary.h"
#include "libnormaliz/libnormaliz.h"
#include <vector>
#include <dlfcn.h>
#include <cstdlib>
#include <cstdio>

EXTERN_C DLLEXPORT mint WolframLibrary_getVersion() { return WolframLibraryVersion; }
EXTERN_C DLLEXPORT int WolframLibrary_initialize(WolframLibraryData libData) { return LIBRARY_NO_ERROR; }
EXTERN_C DLLEXPORT void WolframLibrary_uninitialize(WolframLibraryData libData) {}

// Вспомогательная функция для загрузки библиотеки с fallback
static void* load_library(const char* env_var, const char* short_name, const char* fallback_path) {
    const char* path = getenv(env_var);
    if (!path) path = fallback_path;
    
    // Пробуем загрузить с указанным путём
    void* handle = dlopen(path, RTLD_NOW | RTLD_GLOBAL | RTLD_DEEPBIND);
    if (handle) return handle;
    
    // Если не получилось, пробуем короткое имя (поиск через стандартные пути)
    if (path != short_name) {
        handle = dlopen(short_name, RTLD_NOW | RTLD_GLOBAL | RTLD_DEEPBIND);
        if (handle) return handle;
    }
    
    fprintf(stderr, "[ConvexHullNormaliz] Warning: failed to load %s: %s\n", short_name, dlerror());
    return nullptr;
}

__attribute__((constructor))
static void load_dependencies() {
    // Загружаем libgmp (системную версию, а не версию Mathematica)
    // Можно переопределить путь через переменную окружения NORMALIZ_LIBGMP
    load_library("NORMALIZ_LIBGMP", "libgmp.so.10", "/usr/lib/x86_64-linux-gnu/libgmp.so.10");
    
    // Загружаем libgmpxx
    load_library("NORMALIZ_LIBGMPXX", "libgmpxx.so.4", "/usr/lib/x86_64-linux-gnu/libgmpxx.so.4");
    
    // Загружаем libnormaliz
    // Можно переопределить путь через переменную окружения NORMALIZ_LIBNORMALIZ
    load_library("NORMALIZ_LIBNORMALIZ", "libnormaliz.so.3", "/usr/local/lib/libnormaliz.so.3");
}

EXTERN_C DLLEXPORT int NormalizInnerNormals(WolframLibraryData libData, mint Argc, MArgument *Args, MArgument Res) {
    if (Argc != 1) return LIBRARY_FUNCTION_ERROR;
    
    MTensor inputPoints = MArgument_getMTensor(Args[0]);
    if (libData->MTensor_getType(inputPoints) != MType_Integer || 
        libData->MTensor_getRank(inputPoints) != 2) {
        return LIBRARY_TYPE_ERROR;
    }
    
    mint const* dims = libData->MTensor_getDimensions(inputPoints);
    mint numPoints = dims[0], dim = dims[1];
    mint* inputData = libData->MTensor_getIntegerData(inputPoints);
    
    std::vector<std::vector<long>> points(numPoints, std::vector<long>(dim));
    for (mint i = 0; i < numPoints; i++)
        for (mint j = 0; j < dim; j++)
            points[i][j] = inputData[i * dim + j];
    
    try {
        libnormaliz::Cone<long> cone(libnormaliz::InputType::polytope, points);
        cone.compute({libnormaliz::ConeProperty::SupportHyperplanes});
        const auto& hyperplanes = cone.getSupportHyperplanes();
        
        mint numFacets = hyperplanes.size();
        mint outputDims[2] = {numFacets, dim};
        MTensor outputNormals;
        if (libData->MTensor_new(MType_Integer, 2, outputDims, &outputNormals)) return LIBRARY_FUNCTION_ERROR;
        
        mint* outputData = libData->MTensor_getIntegerData(outputNormals);
        for (mint i = 0; i < numFacets; i++)
            for (mint j = 0; j < dim; j++)
                outputData[i * dim + j] = hyperplanes[i][j];
        
        MArgument_setMTensor(Res, outputNormals);
    } catch (...) {
        return LIBRARY_FUNCTION_ERROR;
    }
    
    return LIBRARY_NO_ERROR;
}
