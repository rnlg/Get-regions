(* ::Package:: *)

BeginPackage["GetRegions`"]


InnerNormals;GetRegions;Factors;CollectFactors;


Begin["`Private`"]


PickBasis::usage="PickBasis[{v1,...vn}] picks basis among vectors."
PickBasis[vecs_?MatrixQ]:=Module[{basis={},r=0,new},Scan[(new=Append[basis,#];If[MatrixRank[new]>r,r++;basis=new])&,vecs];basis]


InnerNormals::usage="InnerNormals[points] gives inner normals of the convex hull of points."
InnerNormals[pts_?MatrixQ] :=
  Module[{np,dim,file,str,nf,fs,ns,mp=Total[pts]/Length[pts],in,out},
{np,dim}=Dimensions@pts;
file = OpenWrite[];
WriteString[file,ToString[dim] <> " # dimension\n"];WriteString[file,ToString[np] <> " # number of points\n"];
str=StringRiffle[StringRiffle[ToString /@#," "]&/@pts,"\n"];
WriteString[file,str];
in=Close[file];
out=Close[OpenWrite[]];
Run["qconvex Fv" <> " < " <> in <> " > " <> out];
file=OpenRead[out];
nf = Read[file,Number];
ns=-Cross@@Rest[#]/First[#] . (Cross@@Rest[#])&/@(PickBasis[Differences[Prepend[pts[[#]],mp]]]&/@(Rest[#+1]&/@ReadList[file,Number,RecordLists->True]));
Close[file];LCM@@Abs[Denominator[#]]/GCD@@Abs[Numerator[#]]*#&/@ns]


GetRegions::usage="GetRegions[{p1,p2,..pk},{x1,x2,...xn}, a] detects regions in the asymptotic expansion of the integral Integrate[p1^a1*p2^a2*...pk^ak,{x1,0,Infty},{x2,0,Infty},...{xn,0,Infty}]. 
By default, the result is the scaling powers of polynomials and variables for each region. Try GetRegions with option OutputForm->Rule or OutputForm->RuleDelayed."


GetRegions::poly="GetRegions works only for polynomial functions of both variables and small parameters.";
GetRegions::zero="The integral is scaleless! Returning scaling";
Options[GetRegions]={OutputForm->Exponent};
GetRegions[polys_List,vars_List,p_Symbol,OptionsPattern[]]:=Module[{normals,pvs=Prepend[vars,p],nv=Length@vars,ufold,scalings},
If[!AllTrue[polys,PolynomialQ[#,pvs]&],Message[GetRegions::poly];Return[$Failed]];
(*If the integral is just proportional to a power of small parameter, the polynomial should be homogeneous wrt some scaling*)
normals=NullSpace[Differences[First/@CoefficientRules[Times@@polys,pvs]]];
If[normals=!={},
normals=DeleteCases[RowReduce[normals],{0,___}],
normals=Cases[InnerNormals[First/@CoefficientRules[Times@@polys,pvs]],s:{_?Positive,__}:>s/First[s]]];
scalings=MapThread[List,{Transpose@Outer[Min[(First/@CoefficientRules[#,pvs]) . #2]&,polys,normals,1],
Rest/@normals}];
Replace[OptionValue[OutputForm],{
Rule->({Thread[polys->(p^(#1))Factor[polys/(p^#1)/.Thread[vars->p^#2 vars]]],Thread[vars->p^#2 vars]}&@@@scalings),
RuleDelayed:>((Function[{pp,vp},{Thread[polys^C_:>Evaluate[(p^(pp*C))Factor[polys/(p^pp)/.Thread[vars->p^vp vars]]^C]],Thread[vars->p^vp vars]}]@@@scalings)&[Unique["n"]]),
_->scalings}]
]
GetRegions[poly_,vars_List,p_Symbol,opts:OptionsPattern[]]:={First[#1],#2}&@@@GetRegions[{poly},vars,p,opts]


Factors::usage="Factors[ex] does the same as FactorList except that it allows for non-integer powers.\nFactors[ex,{x1,x2,...}] in addition consolidates all factors which do not depend on x1,x2,...";
Factors[ex_]:=Module[{flist=FactorList[ex]},flist=Replace[flist,{Power[x_,a_],n_}:>{x,n*a},{1}]];
Factors[ex_,xs_List]:=Module[{flist=Factors[ex],p},p=Position[flist,_?(FreeQ[#,Alternatives@@xs]&),{1},Heads->False];Prepend[Delete[flist,p],{Times@@Power@@@flist[[Flatten@p]],1}]];


Options[CollectFactors]={Flat->False};
CollectFactors::usage="CollectFactors[ex_,xs_,f_:Identity] does the same as Collect, but for each factor of ex";
CollectFactors[ex_,xs_,f_:Identity]:=Times@@(Collect[#,xs,f]^#2&@@@Factors[ex])


End[]
EndPackage[]
