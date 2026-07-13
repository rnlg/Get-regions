#!/usr/bin/env wolframscript
(* ::Package:: *)

(*
makeNormaliz.wls - written by Roman Lee. This script tries to compile the dynamica library ConvexHullNormaliz.so
which can be used from Mathematica.
*)
SetDirectory[DirectoryName[$InputFileName]];

If[!FileExistsQ["ConvexHullNormaliz.cpp"],Print["\033[1;31Can not find  ConvexHullNormaliz.cpp.\033[0m"];Quit[]];

Print["\033[1;33mCompiling ConvexHullNormaliz library...\033[0m"];
mathInclude = FileNameJoin[{$InstallationDirectory, "SystemFiles", "IncludeFiles", "C"}];
outFile = FileNameJoin[{$UserBaseDirectory, "SystemFiles", "LibraryResources", $SystemID,"ConvexHullNormaliz.so"}];
(*cmd = "g++ -std=c++17 -shared -fPIC -I\""<>mathInclude<>"\" -I/usr/local/include -I/usr/include -I. ConvexHullNormaliz.cpp -o \""<>outFile<>"\" -ldl";*)
cmd = "gcc -shared -fPIC -I\""<>mathInclude<>"\" ConvexHullNormaliz.cpp -o \""<>outFile<>"\" -ldl";
Print[cmd];
res = RunProcess[{$SystemShell, "-c", cmd}, ProcessDirectory -> Directory[]];
If[res["ExitCode"] =!= 0, Print["\033[1;31mLibrary compile error: "<>ToString[res["StandardError"]]<>".\033[0m"];Quiet[DeleteFile[outFile]];Quit[]];
Print["\033[1;32mCreated ", FileNameTake[outFile], " \033[4;94m\033]8;;file://", DirectoryName[outFile], "\033\\here\033]8;;\033\\\033[1;0m"];

Print["\033[1;33mChecking ConvexHullNormaliz library...\033[0m"];
Check[LibraryFunctionLoad[outFile, "NormalizInnerNormals", {{Integer, 2, "Constant"}}, {Integer, 2}], Print["\033[1;31mLibrary load error.\033[0m"];Quiet[DeleteFile[outFile]];Quit[]];
Print["\033[1;32mNormalizInnerNormals loaded successfully!\033[0m"];
Quit[];
