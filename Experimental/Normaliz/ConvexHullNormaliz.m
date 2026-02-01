(* Mathematica Package for Convex Hull Normaliz Library *)

BeginPackage["ConvexHullNormaliz`"]

(* Exported functions *)
computeConvexHullNormals::usage = "computeConvexHullNormals[points] computes the convex hull of integer points and returns the normal vectors of the facets."

Begin["`Private`"]

(* Load the library *)
$ConvexHullNormalizLoaded = False;

loadLibrary[] := Module[{libPath},
  If[$ConvexHullNormalizLoaded === False,
    (* Try different possible locations for the library *)
    libPath = $CurrentDirectory <> "/ConvexHullNormaliz.so";
    If[FileExistsQ[libPath],
      $ConvexHullNormalizLib = LibraryLoad[libPath];
      $ConvexHullNormalizLoaded = True;
      Print["ConvexHullNormaliz library loaded successfully."];
      ,
      Print["Error: ConvexHullNormaliz.so not found in current directory."];
    ];
  ];
]

(* Main function *)
computeConvexHullNormals[points_] := Module[{result},
  loadLibrary[];
  If[$ConvexHullNormalizLoaded,
    result = LibraryFunction[$ConvexHullNormalizLib, "computeConvexHullNormals",
                   {{Integer, 2, "Constant"}}, {Integer, 2}][points];
    result,
    $Failed
  ]
]

(* Cleanup function *)
unloadLibrary[] := Module[{},
  If[$ConvexHullNormalizLoaded,
    LibraryUnload[$ConvexHullNormalizLib];
    $ConvexHullNormalizLoaded = False;
    Print["ConvexHullNormaliz library unloaded."];
  ]
]

(* End the private context *)
End[];

(* End the package *)
EndPackage[];

(* Example usage:
   points = {{0, 0}, {1, 0}, {1, 1}, {0, 1}};
   normals = computeConvexHullNormals[points];
*)