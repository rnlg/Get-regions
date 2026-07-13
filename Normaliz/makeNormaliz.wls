#!/usr/bin/env wolframscript
(* ::Package:: *)

(*
makeNormaliz.wls - written by Roman Lee.
This script tries to compile the dynamica library ConvexHullNormaliz.so
which can be used from Mathematica.
*)
SetDirectory[DirectoryName[$InputFileName]]
If[FileExistsQ["ConvexHullNormaliz.cpp"],
Print["Compiling ConvexHullNormaliz library...\033[0;91m"];
Check[
Needs["CCompilerDriver`"];
path=CCompilerDriver`CreateLibrary[{"ConvexHullNormaliz.cpp"},
"ConvexHullNormaliz"];
, Print["Compilation error."];Quit[]];
Print["\033[1;;0mChecking ConvexHullNormaliz library...\033[0;91m"];
Check[
LibraryFunctionLoad[FindLibrary["ConvexHullNormaliz"], "NormalizInnerNormals", {{Integer, 2, "Constant"}}, {Integer, 2}];
, Print["Compilation error."];Quit[]];
Print["\033[1;0mCreated ",FileNameTake[path]," \033[4;94m\033]8;;file://",DirectoryName[path],"\033\\here\033]8;;\033\\.\033[1;0m"]];
Quit[]
