# Convex Hull Normaliz Library for Mathematica

This library provides a bridge between Mathematica and the libnormaliz library for computing convex hulls of integer points in d-dimensional space. It returns the normal vectors of the facets of the convex hull.

## Features

- Computes convex hull of integer points in arbitrary dimensions
- Returns normal vectors of the facets of the convex hull
- Integrates seamlessly with Mathematica via LibraryLink
- Handles multi-dimensional spaces (d > 3)

## Requirements

- Mathematica/Wolfram Language
- libnormaliz development headers and library
- C++ compiler with C++11 support

## Installation

1. Compile the library using the provided Makefile:
   ```bash
   make
   ```

2. The compiled library `ConvexHullNormaliz.so` will be created.

3. Place the library in a location where Mathematica can find it, or load it using its full path.

## Usage

### From Mathematica:

```mathematica
(* Load the library *)
lib = LibraryLoad["./ConvexHullNormaliz.so"];

(* Define your integer points *)
points = {{0, 0}, {1, 0}, {1, 1}, {0, 1}};

(* Call the function to compute normal vectors *)
normals = LibraryFunction[lib, "computeConvexHullNormals",
              {{Integer, 2, "Constant"}}, {Integer, 2}][points];

(* Clean up *)
LibraryUnload[lib];
```

### Using the Package

Alternatively, you can use the provided Mathematica package:

```mathematica
<< ConvexHullNormaliz`

points = {{0, 0}, {1, 0}, {1, 1}, {0, 1}};
normals = computeConvexHullNormals[points];
```

### Function Signature

The main function has the following signature:
- Name: `computeConvexHullNormals`
- Input: A 2D tensor of integers representing points (each row is a point)
- Output: A 2D tensor of integers representing normal vectors of facets (each row is a normal vector)

## How It Works

The library works by:

1. Converting the input from Mathematica's tensor format to libnormaliz's expected format
2. Creating a libnormaliz cone object with the input points using the `polytope` input type
3. Computing the support hyperplanes (which correspond to the facets of the convex hull)
4. Extracting the normal vectors from the support hyperplanes
5. Converting the results back to Mathematica's tensor format

## Example

For a 2D square defined by points `{{0, 0}, {1, 0}, {1, 1}, {0, 1}}`, the function would return the normal vectors of the four edges of the square.

For a 3D cube, it would return the normal vectors of the six faces.

## Notes

- The library handles integer points specifically. For rational points, they should be scaled to integers before passing to the library.
- The normal vectors returned are the outward-pointing normals of the facets.
- The dimensionality of the space is determined by the number of columns in the input matrix.

## Building

To build the library from source:

```bash
make
```

To clean the build:

```bash
make clean
```

## Dependencies

- libnormaliz: Required for convex hull computation
- GMP: Required by libnormaliz for high-precision arithmetic
- Wolfram Library: For Mathematica integration