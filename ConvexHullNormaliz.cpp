#include "WolframLibrary.h"
#include "libnormaliz/libnormaliz.h"
#include <vector>
#include <algorithm>

// Return the version of Library Link
EXTERN_C DLLEXPORT mint WolframLibrary_getVersion() {
    return WolframLibraryVersion;
}

// Initialize Library
EXTERN_C DLLEXPORT int WolframLibrary_initialize(WolframLibraryData libData) {
    return LIBRARY_NO_ERROR;
}

// Uninitialize Library
EXTERN_C DLLEXPORT void WolframLibrary_uninitialize(WolframLibraryData libData) {
    return;
}

/**
 * Computes the convex hull of integer points in d-dimensional space using libnormaliz
 * and returns the normal vectors of the facets.
 *
 * Input: A 2D tensor representing integer points (each row is a point)
 * Output: A 2D tensor representing normal vectors of facets (each row is a normal vector)
 */
EXTERN_C DLLEXPORT int NormalizInnerNormals(WolframLibraryData libData, mint Argc, MArgument *Args, MArgument Res) {
    // Validate input arguments
    if (Argc != 1) {
        return LIBRARY_FUNCTION_ERROR;
    }
    
    // Get the input tensor containing the points
    MTensor inputPoints = MArgument_getMTensor(Args[0]);
    
    // Verify that the input is an integer tensor
    if (libData->MTensor_getType(inputPoints) != MType_Integer) {
        return LIBRARY_TYPE_ERROR;
    }
    
    // Verify that the input is a 2D tensor
    if (libData->MTensor_getRank(inputPoints) != 2) {
        return LIBRARY_RANK_ERROR;
    }
    
    // Get dimensions of the input tensor
    mint const* dims = libData->MTensor_getDimensions(inputPoints);
    mint numPoints = dims[0];  // Number of points
    mint dim = dims[1];        // Dimension of space
    
    // Get the data from the input tensor
    mint* inputData = libData->MTensor_getIntegerData(inputPoints);
    
    // Prepare input data for libnormaliz
    // Convert the flat array into the format expected by libnormaliz
    std::vector<std::vector<long>> points(numPoints, std::vector<long>(dim));
    for (mint i = 0; i < numPoints; i++) {
        for (mint j = 0; j < dim; j++) {
            points[i][j] = (long)inputData[i * dim + j];
        }
    }
    
    try {
        // Create a libnormaliz cone object with the points
        // For convex hull, we use InputType::polytope
        libnormaliz::Cone<long> cone(libnormaliz::InputType::polytope, points);
        
        // Compute the support hyperplanes (facets of the convex hull)
        cone.compute({libnormaliz::ConeProperty::SupportHyperplanes});
        
        // Get the support hyperplanes (these are the normal vectors we need)
        const std::vector<std::vector<long>>& supportHyperplanes = cone.getSupportHyperplanes();
        
        // Create output tensor for the normal vectors
        mint numFacets = supportHyperplanes.size();
        if (numFacets == 0) {
            // If no facets found, return empty tensor with proper dimensions
            mint outputDims[2] = {0, dim};
            MTensor outputNormals;
            int err = libData->MTensor_new(MType_Integer, 2, outputDims, &outputNormals);
            if (err) {
                return err;
            }
            MArgument_setMTensor(Res, outputNormals);
            return LIBRARY_NO_ERROR;
        }
        
        mint outputDims[2] = {numFacets, dim};  // Each normal vector has 'dim' components
        
        MTensor outputNormals;
        int err = libData->MTensor_new(MType_Integer, 2, outputDims, &outputNormals);
        if (err) {
            return err;
        }
        
        // Fill the output tensor with normal vectors
        mint* outputData = libData->MTensor_getIntegerData(outputNormals);
        for (mint i = 0; i < numFacets; i++) {
            for (mint j = 0; j < dim; j++) {
                outputData[i * dim + j] = (mint)supportHyperplanes[i][j];
            }
        }
        
        // Set the result
        MArgument_setMTensor(Res, outputNormals);
    } catch (...) {
        // Handle potential exceptions from libnormaliz
        return LIBRARY_FUNCTION_ERROR;
    }
    
    return LIBRARY_NO_ERROR;
}