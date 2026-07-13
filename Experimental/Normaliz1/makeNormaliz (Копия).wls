#!/usr/bin/env wolframscript
(* ::Package:: *)

(*
makeNormaliz.wls - written by Roman Lee.
This script tries to compile the dynamic library ConvexHullNormaliz.so
which can be used from Mathematica.
*)
SetDirectory[DirectoryName[$InputFileName]];
Print["V3"];
If[FileExistsQ["ConvexHullNormaliz.cpp"],
  Print["Compiling ConvexHullNormaliz library...\033[0;91m"];
  
  Check[
    Needs["CCompilerDriver`"];
    
    path = CCompilerDriver`CreateLibrary[
      {"ConvexHullNormaliz.cpp"},
      "ConvexHullNormaliz",
      "Libraries" -> {"normaliz", "gmp"},
      "LibraryDirectories" -> {"/usr/local/lib", "/usr/lib/x86_64-linux-gnu"},
      "LinkerOptions" -> {
        "-Wl,-rpath,/usr/local/lib",
        "-Wl,--allow-shlib-undefined" (* \:0420\:0430\:0437\:0440\:0435\:0448\:0430\:0435\:043c \:043d\:0435\:043e\:043f\:0440\:0435\:0434\:0435\:043b\:0435\:043d\:043d\:044b\:0435 \:0441\:0438\:043c\:0432\:043e\:043b\:044b \:0438\:0437 \:0434\:0438\:043d\:0430\:043c\:0438\:0447\:0435\:0441\:043a\:0438\:0445 \:0431\:0438\:0431\:043b\:0438\:043e\:0442\:0435\:043a *)
      },
      "CompileOptions" -> "-std=c++17"
    ];
    ,
    Print["Compilation error."]; 
    Quit[]
  ];
    
    Print["\033[1;0mLibrary successfully created at:\033[0m ", path];
  
  Print["\033[1;0mChecking ConvexHullNormaliz library...\033[0;91m"];
  
  Check[
    LibraryFunctionLoad[path, "NormalizInnerNormals", {{Integer, 2, "Constant"}}, {Integer, 2}];
    Print["\033[1;0mLibrary loaded successfully!\033[0m"];
    ,
    Print["Library load error. The function was not found or dependencies failed to load."];
    Quiet[DeleteFile[path]];
    Quit[]
  ];
  
  Print["\033[1;0mCreated ", FileNameTake[path], " \033[4;94m\033]8;;file://", DirectoryName[path], "\033\\here\033]8;;\033\\\033[1;0m"];
];
Quit[]
