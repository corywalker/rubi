(* ::Package:: *)

(* TimeLimit is the time constraint in seconds on some potentially expensive routines. *) 
If[Not[NumberQ[TimeLimit]], TimeLimit=1.0];


Map2[func_,lst1_,lst2_] :=
  Module[{i},
    ReapList[Do[Sow[func[lst1[[i]],lst2[[i]]]],{i,Length[lst1]}]]]


ReapList[u_] :=
  Module[{lst=Reap[u][[2]]},
  If[lst==={}, lst, lst[[1]]]]

SetAttributes[ReapList,HoldFirst]


(* MapAnd[f,l] applies f to the elements of list l until False is returned; else returns True *)
MapAnd[f_,lst_] :=
  Catch[Scan[Function[If[f[#],Null,Throw[False]]],lst];True]

MapAnd[f_,lst_,x_] :=
  Catch[Scan[Function[If[f[#,x],Null,Throw[False]]],lst];True]


(* MapOr[f,l] applies f to the elements of list l until True is return; else returns False *)
MapOr[f_,lst_] :=
  Catch[Scan[Function[If[f[#],Throw[True],Null]],lst];False]


(* If u is a sum, MapSum[f,u,x] applies f to the terms of u; else it applies f to u. *)
(* MapSum[f_,u_,x_Symbol] :=
  If[SumQ[u],
    Map[Function[f[#,x]],u],
  f[u,x]] *)


(* NotIntegrableQ[u,x] returns True if u is definitely not integrable wrt x; else it returns 
	False if u is, or might be, integrable wrt x. *)
NotIntegrableQ[u_,x_Symbol] :=
  MatchQ[u,x^m_*Log[a_+b_.*x]^n_ /; FreeQ[{a,b},x] && IntegersQ[m,n] && m<0 && n<0] ||
  MatchQ[u,f_[x^m_.*Log[a_.+b_.*x]] /; FreeQ[{a,b},x] && IntegerQ[m] && (TrigQ[f] || HyperbolicQ[f])]


(* ZeroQ[u1,u2,...] returns True if u1, u2, ... are all 0; else returns False *)
ZeroQ[u_] := Quiet[PossibleZeroQ[u]]
NonzeroQ[u_] := Not[Quiet[PossibleZeroQ[u]]]

ZeroQ[u__] := Catch[Scan[Function[If[ZeroQ[#],Null,Throw[False]]],{u}];True]


(* OneQ[u1,u2,...] returns True if u1, u2, ... are all 1; else returns False *)
OneQ[u_] := PossibleZeroQ[u-1]

OneQ[u__] := Catch[Scan[Function[If[OneQ[#],Null,Throw[False]]],{u}];True]


(* RealNumericQ[u] returns True if u is a real numeric quantity, else returns False. *)
RealNumericQ[u_] := NumericQ[u] && PossibleZeroQ[Im[N[u]]]


(* ImaginaryNumericQ[u] returns True if u is an imaginary numeric quantity, else returns False. *)
ImaginaryNumericQ[u_] :=
  NumericQ[u] && PossibleZeroQ[Re[N[u]]] && Not[PossibleZeroQ[Im[N[u]]]]


(* PositiveQ[u] returns True if u is a positive numeric quantity, else returns False. *)
PositiveQ[u_] :=
  Module[{v=Simplify[u]},
  RealNumericQ[v] && Re[N[v]]>0]


(* PositiveOrZeroQ[u] returns True if u is a nonpositive numeric quantity, else returns False. *)
PositiveOrZeroQ[u_] :=
  Module[{v=Simplify[u]},
  RealNumericQ[v] && Re[N[v]]>=0]


(* NegativeQ[u] returns True if u is a negative numeric quantity, else returns False. *)
NegativeQ[u_] :=
  Module[{v=Simplify[u]},
  RealNumericQ[v] && Re[N[v]]<0]


(* NegativeQ[u] returns True if u is a negative numeric quantity, else returns False. *)
NegativeOrZeroQ[u_] :=
  Module[{v=Simplify[u]},
  RealNumericQ[v] && Re[N[v]]<=0]


(* IntegersQ[m,n,...] returns True if m, n, ... are all explicit integers; else it returns False. *)
IntegersQ[u__] := Catch[Scan[Function[If[IntegerQ[#],Null,Throw[False]]],{u}]; True];


(* PositiveIntegerQ[m,n,...] returns True if m, n, ... are all explicit positive integers; else it returns False. *)
PositiveIntegerQ[u__] := Catch[Scan[Function[If[IntegerQ[#] && #>0,Null,Throw[False]]],{u}]; True];


(* NegativeIntegerQ[m,n,...] returns True if m, n, ... are all explicit negative integers; else it returns False. *)
NegativeIntegerQ[u__] := Catch[Scan[Function[If[IntegerQ[#] && #<0,Null,Throw[False]]],{u}]; True];


(* FractionQ[m,n,...] returns True if m, n, ... are all explicit fractions; else it returns False. *)
FractionQ[u__] := Catch[Scan[Function[If[Head[#]===Rational,Null,Throw[False]]],{u}]; True]


(* RationalQ[m,n,...] returns True if m, n, ... are all explicit integers or fractions; else it returns False. *)
RationalQ[u__] := Catch[Scan[Function[If[IntegerQ[#] || Head[#]===Rational,Null,Throw[False]]],{u}]; True]


(* FractionOrNegativeQ[u] returns True if u is a fraction or negative number; else returns False *)
FractionOrNegativeQ[u__] := Catch[Scan[Function[If[FractionQ[#] || IntegerQ[#] && #<0,Null,Throw[False]]],{u}]; True]


(* SqrtNumberQ[u] returns True if u^2 is a rational number; else it returns False. *)
SqrtNumberQ[m_^n_] :=
  IntegerQ[n] && SqrtNumberQ[m] || IntegerQ[n-1/2] && RationalQ[m]

SqrtNumberQ[u_*v_] :=
  SqrtNumberQ[u] && SqrtNumberQ[v]

SqrtNumberQ[u_] :=
  RationalQ[u] || u===I


SqrtNumberSumQ[u_] :=
  SumQ[u] && SqrtNumberQ[First[u]] && SqrtNumberQ[Rest[u]] || 
  ProductQ[u] && SqrtNumberQ[First[u]] && SqrtNumberSumQ[Rest[u]]


(* AlgebraicNumberQ[u] returns True if u is a real-valued algebraic number (a rational number,
   an algebraic number raised to an integer power, a positive algebraic number raised to a 
   fractional power, or a product or sum of algebraic numbers); else returns False. *)
(* AlgebraicNumberQ[u_] :=
  MapAnd[AlgebraicNumberQ,u] /;
ListQ[u]

AlgebraicNumberQ[u_^v_] :=
  AlgebraicNumberQ[u] && (IntegerQ[v] || PositiveQ[u] && FractionQ[v])

AlgebraicNumberQ[u_*v_] :=
  AlgebraicNumberQ[u] && AlgebraicNumberQ[v]

AlgebraicNumberQ[u_+v_] :=
  AlgebraicNumberQ[u] && AlgebraicNumberQ[v]

AlgebraicNumberQ[u_] :=
  RationalQ[u] *)


NiceSqrtQ[u_] :=
  Not[NegativeQ[u]] && NiceSqrtAuxQ[u]

NiceSqrtAuxQ[u_] :=
  If[RationalQ[u],
    u>0,
  If[PowerQ[u],
    EvenQ[u[[2]]],
  If[ProductQ[u],
    NiceSqrtAuxQ[First[u]] && NiceSqrtAuxQ[Rest[u]],
  If[SumQ[u],
    Function[NonsumQ[#] && NiceSqrtAuxQ[#]] [Simplify[u]],
  False]]]]


(* If u is a rational number whose squareroot is rational or if u is of the form u1^n1 u2^n2 ... 
	and n1, n2, ... are even, PerfectSquareQ[u] returns True; else it returns False. *)
PerfectSquareQ[u_] :=
  If[RationalQ[u],
    u>0 && u!=1 && RationalQ[Sqrt[u]],
  If[PowerQ[u],
    EvenQ[u[[2]]],
  If[ProductQ[u],
    PerfectSquareQ[First[u]] && PerfectSquareQ[Rest[u]],
  If[SumQ[u],
    Function[NonsumQ[#] && PerfectSquareQ[#]] [Simplify[u]],
  False]]]]


(* If u is a perfect square, PerfectSquareRoot[u] returns the squareroot of u. *)
(* PerfectSquareRoot[u_] :=
  If[RationalQ[u],
    Sqrt[u],
  If[PowerQ[u],
    u[[1]]^(u[[2]]/2),
  If[ProductQ[u],
    PerfectSquareRoot[First[u]]*PerfectSquareRoot[Rest[u]],
  If[SumQ[u],
    PerfectSquareRoot[Simplify[u]],
  False]]]] *)


FalseQ[u_] :=
  u===False


NotFalseQ[u_] :=
  u=!=False


SumQ[u_] :=
  Head[u]===Plus

NonsumQ[u_] :=
  Head[u]=!=Plus

ProductQ[u_] :=
  Head[u]===Times

PowerQ[u_] :=
  Head[u]===Power

IntegerPowerQ[u_] :=
  PowerQ[u] && IntegerQ[u[[2]]]

PositiveIntegerPowerQ[u_] :=
  PowerQ[u] && IntegerQ[u[[2]]] && u[[2]]>0

FractionalPowerQ[u_] :=
  PowerQ[u] && FractionQ[u[[2]]]

RationalPowerQ[u_] :=
  PowerQ[u] && RationalQ[u[[2]]]

SqrtQ[u_] :=
  PowerQ[u] && u[[2]]===1/2

ExpQ[u_] :=
  PowerQ[u] && u[[1]]===E

ImaginaryQ[u_] :=\
  Head[u]===Complex && Re[u]===0


FractionalPowerFreeQ[u_] :=
  If[AtomQ[u],
    True,
  If[FractionalPowerQ[u] && Not[AtomQ[u[[1]]]],
    False,
  Catch[Scan[Function[If[FractionalPowerFreeQ[#],Null,Throw[False]]],u];True]]]


ComplexFreeQ[u_] :=
  If[AtomQ[u],
    Head[u]=!=Complex,
  Catch[Scan[Function[If[ComplexFreeQ[#],Null,Throw[False]]],u];True]]


LogQ[u_] :=
  Head[u]===Log


SinQ[u_] :=
  Head[u]===Sin

CosQ[u_] :=
  Head[u]===Cos

TanQ[u_] :=
  Head[u]===Tan

CotQ[u_] :=
  Head[u]===Cot

SecQ[u_] :=
  Head[u]===Sec

CscQ[u_] :=
  Head[u]===Csc


SinhQ[u_] :=
  Head[u]===Sinh

CoshQ[u_] :=
  Head[u]===Cosh

TanhQ[u_] :=
  Head[u]===Tanh

CothQ[u_] :=
  Head[u]===Coth

SechQ[u_] :=
  Head[u]===Sech

CschQ[u_] :=
  Head[u]===Csch


(* TrigQ[u] returns True if u or the head of u is a trig function; else returns False *)
TrigQ[u_] :=
  MemberQ[{Sin,Cos,Tan,Cot,Sec,Csc},If[AtomQ[u],u,Head[u]]]

(* InverseTrigQ[u] returns True if u or the head of u is an inverse trig function; else returns False *)
InverseTrigQ[u_] :=
  MemberQ[{ArcSin,ArcCos,ArcTan,ArcCot,ArcSec,ArcCsc},If[AtomQ[u],u,Head[u]]]

(* HyperbolicQ[u] returns True if u or the head of u is a trig function; else returns False *)
HyperbolicQ[u_] :=
  MemberQ[{Sinh,Cosh,Tanh,Coth,Sech,Csch},If[AtomQ[u],u,Head[u]]]

(* InverseHyperbolicQ[u] returns True if u or the head of u is an inverse trig function; else returns False *)
InverseHyperbolicQ[u_] :=
  MemberQ[{ArcSinh,ArcCosh,ArcTanh,ArcCoth,ArcSech,ArcCsch},If[AtomQ[u],u,Head[u]]]


SinCosQ[f_] :=
  MemberQ[{Sin,Cos,Sec,Csc},f]


SinhCoshQ[f_] :=
  MemberQ[{Sinh,Cosh,Sech,Csch},f]


CalculusFunctions={D,Integrate,Sum,Product,Int,Dif,Subst};

(* CalculusQ[u] returns True if the head of u is a calculus function; else returns False *)
CalculusQ[u_] :=
  MemberQ[CalculusFunctions,Head[u]]

CalculusFreeQ[u_,x_] :=
  If[AtomQ[u],
    True,
  If[CalculusQ[u] && u[[2]]===x || HeldFormQ[u],
    False,
  Catch[Scan[Function[If[CalculusFreeQ[#,x],Null,Throw[False]]],u];True]]]


HeldFormQ[u_] :=
  If[AtomQ[Head[u]],
    MemberQ[{Hold,HoldForm,Defer,Pattern},Head[u]],
  HeldFormQ[Head[u]]]


(* InverseFunctionQ[u] returns True if u is a call on an inverse function; else returns False. *)
InverseFunctionQ[u_] :=
  LogQ[u] || InverseTrigQ[u] && Length[u]==1 || InverseHyperbolicQ[u] || Head[u]===Mods


(* If u is free of inverse or calculus functions involving x,
	InverseFunctionFreeQ[u,x] returns true; else it returns False. *)
TrigHyperbolicFreeQ[u_,x_Symbol] :=
  If[AtomQ[u],
    True,
  If[TrigQ[u] || HyperbolicQ[u] || CalculusQ[u],
    FreeQ[u,x],
  Catch[Scan[Function[If[TrigHyperbolicFreeQ[#,x],Null,Throw[False]]],u];True]]]


(* If u is free of inverse or calculus functions involving x,
	InverseFunctionFreeQ[u,x] returns true; else it returns False. *)
InverseFunctionFreeQ[u_,x_Symbol] :=
  If[AtomQ[u],
    True,
  If[InverseFunctionQ[u] || CalculusQ[u],
(*  If[Head[u]===ArcTan && TanQ[u[[1]]] || Head[u]===ArcCot && CotQ[u[[1]]] ||
       Head[u]===ArcTanh && TanhQ[u[[1]]] || Head[u]===ArcCoth && CothQ[u[[1]]],
      InverseFunctionFreeQ[u[[1,1]],x], *)
    FreeQ[u,x],
  Catch[Scan[Function[If[InverseFunctionFreeQ[#,x],Null,Throw[False]]],u];True]]]


(* ElementaryExpressionQ[u] returns True if u is a sum, product, or power and all the operands
	are elementary expressions; or if u is a call on a trig, hyperbolic, or inverse function
	and all the arguments are elementary expressions; else it returns False. *)
(* ElementaryFunctionQ[u_] :=
  If[AtomQ[u],
    True,
  If[SumQ[u] || ProductQ[u] || PowerQ[u] || TrigQ[u] || HyperbolicQ[u] || InverseFunctionQ[u],
    Catch[Scan[Function[If[ElementaryFunctionQ[#],Null,Throw[False]]],u];True],
  False]] *)


(* If u is an expression of the form -v, NegativeCoefficientQ[u] returns True; else False. *)
NegativeCoefficientQ[u_] :=
  If[SumQ[u],
(*  MapAnd[NegativeCoefficientQ,u], *)
    NegativeCoefficientQ[First[u]],
  MatchQ[u, m_*v_. /; RationalQ[m] && m<0]]


(* Real[u] returns True if u is a real-valued quantity, else returns False. *)
RealQ[u_] :=
  MapAnd[RealQ,u] /;
ListQ[u]

RealQ[u_] :=
  PossibleZeroQ[Im[N[u]]] /;
NumericQ[u]

RealQ[u_^v_] :=
  RealQ[u] && RealQ[v] && (IntegerQ[v] || PositiveOrZeroQ[u])  

RealQ[u_*v_] :=
  RealQ[u] && RealQ[v]

RealQ[u_+v_] :=
  RealQ[u] && RealQ[v]

RealQ[f_[u_]] :=
  If[MemberQ[{Sin,Cos,Tan,Cot,Sec,Csc,ArcTan,ArcCot,Erf},f],
    RealQ[u],
  If[MemberQ[{ArcSin,ArcCos},f],
    LE[-1,u,1],
  If[f===Log,
    PositiveOrZeroQ[u],
  False]]]

RealQ[u_] :=
  False


(* If u is not 0 and has a positive form, PosQ[u] returns True, else it returns False. *)
PosQ[u_] :=
  PosAux[TogetherSimplify[u]]

PosAux[u_] :=
  If[RationalQ[u],
    u>0,
  If[NumberQ[u],
    If[PossibleZeroQ[Re[u]],
      Im[u]>0,
    Re[u]>0],
  If[NumericQ[u],
    Module[{v=N[u]},
    If[PossibleZeroQ[Re[v]],
      Im[v]>0,
    Re[v]>0]],
  If[ProductQ[u],
    If[PosAux[First[u]],
      PosAux[Rest[u]],
    Not[PosAux[Rest[u]]]],
  If[SumQ[u],
    PosAux[First[u]],
  True]]]]]


NegQ[u_] :=
  If[PossibleZeroQ[u],
    False,
  Not[PosQ[u]]]


LeadTerm[u_] :=
  If[SumQ[u],
    First[u],
  u]


RemainingTerms[u_] :=
  If[SumQ[u],
    Rest[u],
  0]


(* LeadFactor[u] returns the leading factor of u. *)
LeadFactor[u_] :=
  If[ProductQ[u],
    LeadFactor[First[u]],
  If[ImaginaryQ[u],
    If[Im[u]===1,
      u,
    LeadFactor[Im[u]]],
  u]]


(* RemainingFactors[u] returns the remaining factors of u. *)
RemainingFactors[u_] :=
  If[ProductQ[u],
    RemainingFactors[First[u]]*Rest[u],
  If[ImaginaryQ[u],
    If[Im[u]===1,
      1,
    I*RemainingFactors[Im[u]]],
  1]]


(* LeadBase[u] returns the base of the leading factor of u. *)
LeadBase[u_] :=
  Module[{v=LeadFactor[u]},
  If[PowerQ[v],
    v[[1]],
  v]]


(* LeadDegree[u] returns the degree of the leading factor of u. *)
LeadDegree[u_] :=
  Module[{v=LeadFactor[u]},
  If[PowerQ[v],
    v[[2]],
  1]]


(* If v^n is a factor of u, FindFactor[u,v] returns the list {n,u/v^n}; else it returns False. *)
(* FindFactor[u_,v_] :=
  If[u===1,
    False,
  If[LeadBase[u]===v,
    {LeadDegree[u], RemainingFactors[u]},
  Module[{lst=FindFactor[RemainingFactors[u],v]},
  If[FalseQ[lst],
    False,
  {lst[[1]], LeadFactor[u]*lst[[2]]}]]]] *)


(* LT[u,v] returns True if u and v are real-valued numeric quantities and u<v, else returns False *)
LT[u_,v_] :=
  RealNumericQ[u] && RealNumericQ[v] && Re[N[u]]<Re[N[v]]

LT[u_,v_,w_] :=
  LT[u,v] && LT[v,w]


(* LE[u,v] returns True if u and v are real-valued numeric quantities and u<=v, else returns False *)
LE[u_,v_] :=
  RealNumericQ[u] && RealNumericQ[v] && Re[N[u]]<=Re[N[v]]

LE[u_,v_,w_] :=
  LE[u,v] && LE[v,w]


(* GT[u,v] returns True if u and v are real-valued numeric quantities and u>v, else returns False *)
GT[u_,v_] :=
  RealNumericQ[u] && RealNumericQ[v] && Re[N[u]]>Re[N[v]]

GT[u_,v_,w_] :=
  GT[u,v] && GT[v,w]


(* GE[u,v] returns True if u and v are real-valued numeric quantities and u>=v, else returns False *)
GE[u_,v_] :=
  RealNumericQ[u] && RealNumericQ[v] && Re[N[u]]>=Re[N[v]]

GE[u_,v_,w_] :=
  GE[u,v] && GE[v,w]


IndependentQ[u_,x_] :=
  FreeQ[u,x]


(* FreeFactors[u,x] returns the product of the factors of u free of x. *)
FreeFactors[u_,x_] :=
  If[ProductQ[u],
    Map[Function[If[FreeQ[#,x],#,1]],u],
  If[FreeQ[u,x],
    u,
  1]]


(* NonfreeFactors[u,x] returns the product of the factors of u not free of x. *)
NonfreeFactors[u_,x_] :=
  If[ProductQ[u],
    Map[Function[If[FreeQ[#,x],1,#]],u],
  If[FreeQ[u,x],
    1,
  u]]


(* SplitFreeFactors[u,x] returns the list {v,w} where v is the product of the factors of u free of x
	and w is the product of the other factors. *)
(* Compare with the more active function ConstantFactor. *)
SplitFreeFactors[u_,x_] :=
  If[ProductQ[u],
    Map[Function[If[FreeQ[#,x],{#,1},{1,#}]],u],
  If[FreeQ[u,x],
    {u,1},
  {1,u}]]


(* FreeTerms[u,x] returns the sum of the terms of u free of x. *)
FreeTerms[u_,x_] :=
  If[SumQ[u],
    Map[Function[If[FreeQ[#,x],#,0]],u],
  If[FreeQ[u,x],
    u,
  0]]


(* NonfreeTerms[u,x] returns the sum of the terms of u not free of x. *)
NonfreeTerms[u_,x_] :=
  If[SumQ[u],
    Map[Function[If[FreeQ[#,x],0,#]],u],
  If[FreeQ[u,x],
    0,
  u]]


LinearQ[u_,x_Symbol] :=
  PolyQ[u,x,1]


PowerOfLinearQ[u_^m_.,x_Symbol] :=
  FreeQ[m,x] && PolynomialQ[u,x] && If[IntegerQ[m], MatchQ[FactorSquareFree[u], w_^n_. /; FreeQ[n,x] && LinearQ[w,x]], LinearQ[u,x]]


QuadraticQ[u_,x_Symbol] :=
  PolyQ[u,x,2]


PolyQ[u_,x_Symbol,n_Integer] :=
  If[ListQ[u],
    Catch[Scan[Function[If[Not[PolyQ[#,x,n]],Throw[False]]],u]; True],
  PolynomialQ[u,x] && Exponent[u,x]==n]


LinearPairQ[u_,v_,x_Symbol] :=
  LinearQ[u,x] && LinearQ[v,x] && NonzeroQ[u-x] && ZeroQ[Coefficient[u,x,0]*Coefficient[v,x,1]-Coefficient[u,x,1]*Coefficient[v,x,0]]


BinomialQ[u_,x_Symbol] :=
  If[ListQ[u],
    Catch[Scan[Function[If[Not[BinomialQ[#,x]],Throw[False]]],u]; True],
  NotFalseQ[BinomialTest[u,x]]]


BinomialQ[u_,x_Symbol,n_] :=
  If[ListQ[u],
    Catch[Scan[Function[If[Not[BinomialQ[#,x,n]],Throw[False]]],u]; True],
  Function[NotFalseQ[#] && #[[3]]===n][BinomialTest[u,x]]]


GeneralizedBinomialQ[u_,x_Symbol] :=
  If[ListQ[u],
    Catch[Scan[Function[If[Not[GeneralizedBinomialQ[#,x]],Throw[False]]],u]; True],
  NotFalseQ[GeneralizedBinomialTest[u,x]]]


TrinomialQ[u_,x_Symbol] :=
  If[ListQ[u],
    Catch[Scan[Function[If[Not[TrinomialQ[#,x]],Throw[False]]],u]; True],
  NotFalseQ[TrinomialTest[u,x]] && Not[QuadraticQ[u,x]] && Not[MatchQ[u,w_^2 /; BinomialQ[w,x]]]]


GeneralizedTrinomialQ[u_,x_Symbol] :=
  If[ListQ[u],
    Catch[Scan[Function[If[Not[GeneralizedTrinomialQ[#,x]],Throw[False]]],u]; True],
  NotFalseQ[GeneralizedTrinomialTest[u,x]]]


MonomialQ[u_,x_Symbol] :=
  If[ListQ[u],
    Catch[Scan[Function[If[MonomialQ[#,x],Null,Throw[False]]],u]; True],
  MatchQ[u, a_.*x^n_. /; FreeQ[{a,n},x]]]


MonomialSumQ[u_,x_Symbol] :=
  SumQ[u] && Catch[
	Scan[Function[If[FreeQ[#,x] || MonomialQ[#,x], Null, Throw[False]]],u];
    True]


MinimumMonomialExponent[u_,x_Symbol] :=
  Module[{n=MonomialExponent[First[u],x]},
  Scan[Function[If[PosQ[n-MonomialExponent[#,x]],n=MonomialExponent[#,x]]],u];
  n]


MonomialExponent[a_.*x_^n_.,x_Symbol] :=
  n /; 
FreeQ[{a,n},x]


LinearMatchQ[u_,x_Symbol] :=
  If[ListQ[u],
    Catch[Scan[Function[If[Not[LinearMatchQ[#,x]],Throw[False]]],u]; True],
  MatchQ[u, a_.+b_.*x /; FreeQ[{a,b},x]]]


PowerOfLinearMatchQ[u_,x_Symbol] :=
  If[ListQ[u],
    Catch[Scan[Function[If[Not[PowerOfLinearMatchQ[#,x]],Throw[False]]],u]; True],
  MatchQ[u, (a_.+b_.*x)^m_. /; FreeQ[{a,b,m},x]]]


QuadraticMatchQ[u_,x_Symbol] :=
  If[ListQ[u],
    Catch[Scan[Function[If[Not[QuadraticMatchQ[#,x]],Throw[False]]],u]; True],
  MatchQ[u, a_.+b_.*x+c_.*x^2 /; FreeQ[{a,b,c},x]] || MatchQ[u, a_.+c_.*x^2 /; FreeQ[{a,c},x]]]


CubicMatchQ[u_,x_Symbol] :=
  If[ListQ[u],
    Catch[Scan[Function[If[Not[CubicMatchQ[#,x]],Throw[False]]],u]; True],
  MatchQ[u, a_.+b_.*x+c_.*x^2+d_.*x^3 /; FreeQ[{a,b,c,d},x]] || 
  MatchQ[u, a_.+b_.*x+d_.*x^3 /; FreeQ[{a,b,d},x]] ||
  MatchQ[u, a_.+c_.*x^2+d_.*x^3 /; FreeQ[{a,c,d},x]] || 
  MatchQ[u, a_.+d_.*x^3 /; FreeQ[{a,d},x]]]


BinomialMatchQ[u_,x_Symbol] :=
  If[ListQ[u],
    Catch[Scan[Function[If[Not[BinomialMatchQ[#,x]],Throw[False]]],u]; True],
  MatchQ[u, a_.+b_.*x^n_. /; FreeQ[{a,b,n},x]]]


GeneralizedBinomialMatchQ[u_,x_Symbol] :=
  If[ListQ[u],
    Catch[Scan[Function[If[Not[GeneralizedBinomialMatchQ[#,x]],Throw[False]]],u]; True],
  MatchQ[u, a_.*x^q_.+b_.*x^n_. /; FreeQ[{a,b,n,q},x]]]


TrinomialMatchQ[u_,x_Symbol] :=
  If[ListQ[u],
    Catch[Scan[Function[If[Not[TrinomialMatchQ[#,x]],Throw[False]]],u]; True],
  MatchQ[u, a_.+b_.*x^n_.+c_.*x^j_. /; FreeQ[{a,b,c,n},x] && ZeroQ[j-2*n]]]


GeneralizedTrinomialMatchQ[u_,x_Symbol] :=
  If[ListQ[u],
    Catch[Scan[Function[If[Not[GeneralizedTrinomialMatchQ[#,x]],Throw[False]]],u]; True],
  MatchQ[u, a_.*x^q_.+b_.*x^n_.+c_.*x^r_. /; FreeQ[{a,b,c,n,q},x] && ZeroQ[r-(2*n-q)]]]


QuotientOfLinearsMatchQ[u_,x_Symbol] :=
  If[ListQ[u],
    Catch[Scan[Function[If[Not[QuotientOfLinearsMatchQ[#,x]],Throw[False]]],u]; True],
  MatchQ[u, e_.*(a_.+b_.*x)/(c_.+d_.*x) /; FreeQ[{a,b,c,d,e},x]]]


(* If u (x) is an expression of the form a*x^n where n is zero or a positive integer,
	PolynomialTermQ[u,x] returns True; else it returns False. *)
PolynomialTermQ[u_,x_Symbol] :=
  FreeQ[u,x] || MatchQ[u,a_.*x^n_. /; FreeQ[a,x] && IntegerQ[n] && n>0]


(* u (x) is a sum.  PolynomialTerms[u,x] returns the sum of the polynomial terms of u (x). *)
PolynomialTerms[u_,x_Symbol] :=
  Map[Function[If[PolynomialTermQ[#,x],#,0]],u]


(* u (x) is a sum.  NonpolynomialTerms[u,x] returns the sum of the nonpolynomial terms of u (x). *)
NonpolynomialTerms[u_,x_Symbol] :=
  Map[Function[If[PolynomialTermQ[#,x],0,#]],u]


(* u is a binomial. BinomialDegree[u,x] returns the degree of x in u. *)
BinomialDegree[u_,x_Symbol] :=
  BinomialTest[u,x][[3]]


(* If u[x] is equivalent to an expression of the form a+b*x^n where n!=0 and b!=0,
	BinomialTest[u,x] returns the list {a,b,n}; else it returns False. *)
BinomialTest[u_,x_Symbol] :=
  If[PolynomialQ[u,x],
    If[Exponent[u,x]>0,
      Module[{lst=Exponent[u,x,List]},
        If[Length[lst]==1,
          {0, Coefficient[u,x,Exponent[u,x]], Exponent[u,x]},
        If[Length[lst]==2 && lst[[1]]==0,
          {Coefficient[u,x,0], Coefficient[u,x,Exponent[u,x]], Exponent[u,x]},
        False]]],
    False],
  If[PowerQ[u],
    If[u[[1]]===x && FreeQ[u[[2]],x],
      {0,1,u[[2]]},
    False],
  Module[{lst1,lst2},
  If[ProductQ[u],
    If[FreeQ[First[u],x],
      lst2=BinomialTest[Rest[u],x];
      If[FalseQ[lst2],
        False,
      {First[u]*lst2[[1]],First[u]*lst2[[2]],lst2[[3]]}],
    If[FreeQ[Rest[u],x],
      lst1=BinomialTest[First[u],x];
      If[FalseQ[lst1],
        False,
      {Rest[u]*lst1[[1]],Rest[u]*lst1[[2]],lst1[[3]]}],
    lst1=BinomialTest[First[u],x];
    lst2=BinomialTest[Rest[u],x];
    If[FalseQ[lst1] || FalseQ[lst2],
      False,
    Module[{a,b,c,d,m,n},
    {a,b,m}=lst1;
    {c,d,n}=lst2;
    If[ZeroQ[a],
      If[ZeroQ[c],
        {0,b*d,m+n},
      If[ZeroQ[m+n],
        {b*d,b*c,m},
      False]],
    If[ZeroQ[c],
      If[ZeroQ[m+n],
        {b*d,a*d,n},
      False],
    If[ZeroQ[m-n] && ZeroQ[a*d+b*c],
      {a*c,b*d,2*m},
    False]]]]]]],
  If[SumQ[u],
    If[FreeQ[First[u],x],
      lst2=BinomialTest[Rest[u],x];
      If[FalseQ[lst2],
        False,
      {First[u]+lst2[[1]],lst2[[2]],lst2[[3]]}],
    If[FreeQ[Rest[u],x],
      lst1=BinomialTest[First[u],x];
      If[FalseQ[lst1],
        False,
      {Rest[u]+lst1[[1]],lst1[[2]],lst1[[3]]}],
    lst1=BinomialTest[First[u],x];
    lst2=BinomialTest[Rest[u],x];
    If[FalseQ[lst1] || FalseQ[lst2],
      False,
    If[ZeroQ[lst1[[3]]-lst2[[3]]],
      {lst1[[1]]+lst2[[1]],lst1[[2]]+lst2[[2]],lst1[[3]]},
    False]]]],
  False]]]]]


(* If u is equivalent to a generalized binomial of the form a*x^q + b*x^n where a, b, n, and q not equal 0,
	GeneralizedBinomialDegree[u,x] returns n-q. *)
GeneralizedBinomialDegree[u_,x_Symbol] :=
  Function[#[[3]]-#[[4]]][GeneralizedBinomialTest[u,x]]


(* If u is equivalent to a generalized binomial of the form a*x^q + b*x^n where a, b, n, and q not equal 0,
	GeneralizedBinomialTest[u,x] returns the list {a,b,n,q}; else it returns False. *)
GeneralizedBinomialTest[a_.*x_^q_.+b_.*x_^n_.,x_Symbol] :=
  {a,b,n,q} /;
FreeQ[{a,b,n,q},x] && PosQ[n-q]

GeneralizedBinomialTest[a_*u_,x_Symbol] :=
  Module[{lst=GeneralizedBinomialTest[u,x]},
  {a*lst[[1]], a*lst[[2]], lst[[3]], lst[[4]]} /;
 NotFalseQ[lst]] /;
FreeQ[a,x]

GeneralizedBinomialTest[x_^m_.*u_,x_Symbol] :=
  Module[{lst=GeneralizedBinomialTest[u,x]},
  {lst[[1]], lst[[2]], m+lst[[3]], m+lst[[4]]} /;
 NotFalseQ[lst] && NonzeroQ[m+lst[[3]]] && NonzeroQ[m+lst[[4]]]] /;
FreeQ[m,x]

GeneralizedBinomialTest[x_^m_.*u_,x_Symbol] :=
  Module[{lst=BinomialTest[u,x]},
  {lst[[1]], lst[[2]], m+lst[[3]], m} /;
 NotFalseQ[lst] && NonzeroQ[m+lst[[3]]]] /;
FreeQ[m,x]

GeneralizedBinomialTest[u_,x_Symbol] :=
  False


(* If u is equivalent to a trinomial of the form a + b*x^n + c*x^(2*n) where n!=0, b!=0 and c!=0, 
	TrinomialDegree[u,x] returns n. *)
TrinomialDegree[u_,x_Symbol] :=
  TrinomialTest[u,x][[4]]


(* If u is equivalent to a trinomial of the form a + b*x^n + c*x^(2*n) where n!=0, b!=0 and c!=0,
	TrinomialTest[u,x] returns the list {a,b,c,n}; else it returns False. *)
TrinomialTest[u_,x_Symbol] :=
  If[PolynomialQ[u,x],
    Module[{lst=CoefficientList[u,x]},
    If[Length[lst]<3 || EvenQ[Length[lst]] || ZeroQ[lst[[(Length[lst]+1)/2]]],
      False,
    Catch[
      Scan[Function[If[ZeroQ[#],Null,Throw[False]]],Drop[Drop[Drop[lst,{(Length[lst]+1)/2}],1],-1]];
      {First[lst],lst[[(Length[lst]+1)/2]],Last[lst],(Length[lst]-1)/2}]]],
  If[PowerQ[u],
    If[ZeroQ[u[[2]]-2],
      Module[{lst=BinomialTest[u[[1]],x]},
      If[FalseQ[lst],
        False,
      {lst[[1]]^2,2*lst[[1]]*lst[[2]],lst[[2]]^2,lst[[3]]}]],
    False],
  Module[{lst1,lst2},
  If[ProductQ[u],
    If[FreeQ[First[u],x],
      lst2=TrinomialTest[Rest[u],x];
      If[FalseQ[lst2],
        False,
      {First[u]*lst2[[1]],First[u]*lst2[[2]],First[u]*lst2[[3]],lst2[[4]]}],
    If[FreeQ[Rest[u],x],
      lst1=TrinomialTest[First[u],x];
      If[FalseQ[lst1],
        False,
      {Rest[u]*lst1[[1]],Rest[u]*lst1[[2]],Rest[u]*lst1[[3]],lst1[[4]]}],
    lst1=BinomialTest[First[u],x];
    lst2=BinomialTest[Rest[u],x];
    If[FalseQ[lst1] || FalseQ[lst2],
      False,
    Module[{a,b,c,d,m,n},
    {a,b,m}=lst1;
    {c,d,n}=lst2;
    If[ZeroQ[m-n] && NonzeroQ[a*d+b*c],
      {a*c,a*d+b*c,b*d,m},
    False]]]]],
  If[SumQ[u],
    If[FreeQ[First[u],x],
      lst2=TrinomialTest[Rest[u],x];
      If[FalseQ[lst2],
        False,
      {First[u]+lst2[[1]],lst2[[2]],lst2[[3]],lst2[[4]]}],
    If[FreeQ[Rest[u],x],
      lst1=TrinomialTest[First[u],x];
      If[FalseQ[lst1],
        False,
      {Rest[u]+lst1[[1]],lst1[[2]],lst1[[3]],lst1[[4]]}],
    lst1=TrinomialTest[First[u],x];
    If[FalseQ[lst1],
      lst1=BinomialTest[First[u],x];
      If[FalseQ[lst1],
        False,
      lst2=TrinomialTest[Rest[u],x];
      If[FalseQ[lst2],
        lst2=BinomialTest[Rest[u],x];
        If[FalseQ[lst2],
          False,
        If[ZeroQ[lst1[[3]]-2*lst2[[3]]],
          {lst1[[1]]+lst2[[1]],lst2[[2]],lst1[[2]],lst2[[3]]},
        If[ZeroQ[lst2[[3]]-2*lst1[[3]]],
          {lst1[[1]]+lst2[[1]],lst1[[2]],lst2[[2]],lst1[[3]]},
        False]]],
      If[ZeroQ[lst1[[3]]-lst2[[4]]] && NonzeroQ[lst1[[2]]+lst2[[2]]],
        {lst1[[1]]+lst2[[1]],lst1[[2]]+lst2[[2]],lst2[[3]],lst2[[4]]},
      If[ZeroQ[lst1[[3]]-2*lst2[[4]]] && NonzeroQ[lst1[[2]]+lst2[[3]]],
        {lst1[[1]]+lst2[[1]],lst2[[2]],lst1[[2]]+lst2[[3]],lst2[[4]]},
      False]]]],     
    lst2=TrinomialTest[Rest[u],x];
    If[FalseQ[lst2],
      lst2=BinomialTest[Rest[u],x];
      If[FalseQ[lst2],
        False,
      If[ZeroQ[lst2[[3]]-lst1[[4]]] && NonzeroQ[lst1[[2]]+lst2[[2]]],
        {lst1[[1]]+lst2[[1]],lst1[[2]]+lst2[[2]],lst1[[3]],lst1[[4]]},
      If[ZeroQ[lst2[[3]]-2*lst1[[4]]] && NonzeroQ[lst1[[3]]+lst2[[2]]],
        {lst1[[1]]+lst2[[1]],lst1[[2]],lst1[[3]]+lst2[[2]],lst1[[4]]},
      False]]],           
    If[ZeroQ[lst1[[4]]-lst2[[4]]] && NonzeroQ[lst1[[2]]+lst2[[2]]] && NonzeroQ[lst1[[3]]+lst2[[3]]],
      {lst1[[1]]+lst2[[1]],lst1[[2]]+lst2[[2]],lst1[[3]]+lst2[[3]],lst1[[4]]},
    False]]]]],
  False]]]]]


(* If u is equivalent to a generalized trinomial of the form a*x^q + b*x^n + c*x^(2*n-q) where n!=0, q!=0, b!=0 and c!=0, 
	GeneralizedTrinomialDegree[u,x] returns n-q. *)
GeneralizedTrinomialDegree[u_,x_Symbol] :=
  Function[#[[4]]-#[[5]]][GeneralizedTrinomialTest[u,x]]


(* If u is equivalent to a generalized trinomial of the form a*x^q + b*x^n + c*x^(2*n-q) where n!=0, q!=0, b!=0 and c!=0,
	GeneralizedTrinomialTest[u,x] returns the list {a,b,c,n,q}; else it returns False. *)
GeneralizedTrinomialTest[a_.*x_^q_.+b_.*x_^n_.+c_.*x_^r_.,x_Symbol] :=
  {a,b,c,n,q} /;
FreeQ[{a,b,c,n,q},x] && ZeroQ[r-(2*n-q)]

GeneralizedTrinomialTest[a_*u_,x_Symbol] :=
  Module[{lst=GeneralizedTrinomialTest[u,x]},
  {a*lst[[1]], a*lst[[2]], a*lst[[3]], lst[[4]], lst[[5]]} /;
 NotFalseQ[lst]] /;
FreeQ[a,x]

GeneralizedTrinomialTest[x_^m_.*u_,x_Symbol] :=
  Module[{lst=GeneralizedTrinomialTest[u,x]},
  {lst[[1]], lst[[2]], lst[[3]], m+lst[[4]], m+lst[[5]]} /;
 NotFalseQ[lst] && NonzeroQ[m+lst[[4]]] && NonzeroQ[m+lst[[5]]]] /;
FreeQ[m,x]

GeneralizedTrinomialTest[x_^m_.*u_,x_Symbol] :=
  Module[{lst=TrinomialTest[u,x]},
  {lst[[1]], lst[[2]], lst[[3]], m+lst[[4]], m} /;
 NotFalseQ[lst] && NonzeroQ[m+lst[[4]]]] /;
FreeQ[m,x]

GeneralizedTrinomialTest[u_,x_Symbol] :=
  False


(* If u (x) is equivalent to a polynomial raised to an integer power greater than 1,
	PerfectPowerTest[u,x] returns u (x) as an expanded polynomial raised to the power;
	else it returns False. *)
PerfectPowerTest[u_,x_Symbol] :=
  If[PolynomialQ[u,x],
    Module[{lst=FactorSquareFreeList[u],gcd=0,v=1},
    If[lst[[1]]==={1,1},
      lst=Rest[lst]];
    Scan[Function[gcd=GCD[gcd,#[[2]]]],lst];
    If[gcd>1,
      Scan[Function[v=v*#[[1]]^(#[[2]]/gcd)],lst];
      Expand[v]^gcd,
    False]],
  False]


(* If u (x) can be square free factored, SquareFreeFactorTest[u,x] returns u (x) in
	factored form; else it returns False. *)
(* SquareFreeFactorTest[u_,x_Symbol] :=
  If[PolynomialQ[u,x],
    Module[{v=FactorSquareFree[u]},
    If[PowerQ[v] || ProductQ[v],
      v,
    False]],
  False] *)


(* RationalFunctionQ[u,x] returns True iff u is a polynomial or rational function of x *)
RationalFunctionQ[u_,x_Symbol] :=
  If[AtomQ[u] || FreeQ[u,x],
    True,
  If[IntegerPowerQ[u],
    RationalFunctionQ[u[[1]],x],
  If[ProductQ[u] || SumQ[u],
    Catch[Scan[Function[If[Not[RationalFunctionQ[#,x]],Throw[False]]],u];True],
  False]]]


(* RationalFunctionFactors[u,x] returns the product of the factors of u that are rational functions of x. *)
RationalFunctionFactors[u_,x_Symbol] :=
  If[ProductQ[u],
    Map[Function[If[RationalFunctionQ[#,x],#,1]],u],
  If[RationalFunctionQ[u,x],u,1]]


(* NonrationalFunctionFactors[u,x] returns the product of the factors of u that are not rational functions of x. *)
NonrationalFunctionFactors[u_,x_Symbol] :=
  If[ProductQ[u],
    Map[Function[If[RationalFunctionQ[#,x],1,#]],u],
  If[RationalFunctionQ[u,x],1,u]]


(* u is a polynomial or rational function of x. *)
(* RationalFunctionExponents[u,x] returns a list of the exponent of the *)
(* numerator of u and the exponent of the denominator of u. *)
RationalFunctionExponents[u_,x_Symbol] :=
  If[PolynomialQ[u,x],
    {Exponent[u,x],0},
  If[IntegerPowerQ[u],
    If[u[[2]]>0,
      u[[2]]*RationalFunctionExponents[u[[1]],x],
    (-u[[2]])*Reverse[RationalFunctionExponents[u[[1]],x]]],
  If[ProductQ[u],
    RationalFunctionExponents[First[u],x]+RationalFunctionExponents[Rest[u],x],
  If[SumQ[u],
    Module[{v=Together[u]},
    If[SumQ[v],
      Module[{lst1,lst2},
      lst1=RationalFunctionExponents[First[u],x];
      lst2=RationalFunctionExponents[Rest[u],x];
      {Max[lst1[[1]]+lst2[[2]],lst2[[1]]+lst1[[2]]],lst1[[2]]+lst2[[2]]}],
    RationalFunctionExponents[v,x]]],
  {0,0}]]]]    


(* u is a polynomial or rational function of x. *)
(* RationalFunctionExpand[u,x] returns the expansion of the factors of u that are rational functions times the other factors. *)
RationalFunctionExpand[u_*v_^n_,x_Symbol] :=
  Module[{w=RationalFunctionExpand[u,x]},
  If[SumQ[w],
    Map[Function[#*v^n],w],
  w*v^n]] /;
FractionQ[n] && v=!=x

RationalFunctionExpand[u_,x_Symbol] :=
  Module[{v,w},
  v=ExpandIntegrand[u,x];
  If[v=!=u && Not[MatchQ[u, x^m_.*(c_+d_.*x)^p_/(a_+b_.*x^n_) /; FreeQ[{a,b,c,d,p},x] && IntegersQ[m,n] && m==n-1]],
    v,
  v=ExpandIntegrand[RationalFunctionFactors[u,x],x];
  w=NonrationalFunctionFactors[u,x];
  If[SumQ[v],
    Map[Function[#*w],v],
  v*w]]]


(* AlgebraicFunctionQ[u,x] returns True iff u is an algebraic of x *)
AlgebraicFunctionQ[u_,x_Symbol] :=
  If[AtomQ[u] || FreeQ[u,x],
    True,
  If[RationalPowerQ[u],
    AlgebraicFunctionQ[u[[1]],x],
  If[ProductQ[u] || SumQ[u],
    Catch[Scan[Function[If[Not[AlgebraicFunctionQ[#,x]],Throw[False]]],u];True],
  False]]]


(* AlgebraicFunctionFactors[u,x] returns the product of the factors of u that are algebraic functions of x. *)
AlgebraicFunctionFactors[u_,x_Symbol] :=
  If[ProductQ[u],
    Map[Function[If[AlgebraicFunctionQ[#,x],#,1]],u],
  If[AlgebraicFunctionQ[u,x],u,1]]


(* NonalgebraicFunctionFactors[u,x] returns the product of the factors of u that are not algebraic functions of x. *)
NonalgebraicFunctionFactors[u_,x_Symbol] :=
  If[ProductQ[u],
    Map[Function[If[AlgebraicFunctionQ[#,x],1,#]],u],
  If[AlgebraicFunctionQ[u,x],1,u]]


QuotientOfLinearsQ[u_,x_Symbol] :=
  If[ListQ[u],
    Catch[Scan[Function[If[Not[QuotientOfLinearsQ[#,x]],Throw[False]]],u]; True],
  QuotientOfLinearsP[u,x] && Function[NonzeroQ[#[[2]]] && NonzeroQ[#[[4]]]][QuotientOfLinearsParts[u,x]]]


QuotientOfLinearsP[a_*u_,x_] :=
  QuotientOfLinearsP[u,x] /;
FreeQ[a,x]

QuotientOfLinearsP[a_+u_,x_] :=
  QuotientOfLinearsP[u,x] /;
FreeQ[a,x]

QuotientOfLinearsP[1/u_,x_] :=
  QuotientOfLinearsP[u,x]

QuotientOfLinearsP[u_,x_] :=
  True /;
LinearQ[u,x]

QuotientOfLinearsP[u_/v_,x_] :=
  True /;
LinearQ[u,x] && LinearQ[v,x]

QuotientOfLinearsP[u_,x_] :=
  u===x || FreeQ[u,x]


(* If u is equivalent to an expression of the form (a+b*x)/(c+d*x), QuotientOfLinearsParts[u,x] 
	returns the list {a, b, c, d}. *)
QuotientOfLinearsParts[a_*u_,x_] :=
  Apply[Function[{a*#1, a*#2, #3, #4}], QuotientOfLinearsParts[u,x]] /;
FreeQ[a,x]

QuotientOfLinearsParts[a_+u_,x_] :=
  Apply[Function[{#1+a*#3, #2+a*#4, #3, #4}], QuotientOfLinearsParts[u,x]] /;
FreeQ[a,x]

QuotientOfLinearsParts[1/u_,x_] :=
  Apply[Function[{#3, #4, #1, #2}], QuotientOfLinearsParts[u,x]]

QuotientOfLinearsParts[u_,x_] :=
  {Coefficient[u,x,0], Coefficient[u,x,1], 1, 0} /;
LinearQ[u,x]

QuotientOfLinearsParts[u_/v_,x_] :=
  {Coefficient[u,x,0], Coefficient[u,x,1], Coefficient[v,x,0], Coefficient[v,x,1]} /;
LinearQ[u,x] && LinearQ[v,x]

QuotientOfLinearsParts[u_,x_] :=
  If[u===x,
    {0, 1, 1, 0},
  If[FreeQ[u,x],
    {u, 0, 1, 0},
  Print["QuotientOfLinearsParts error!"];
  {u, 0, 1, 0}]]


(* If u has a subexpression of the form ((a+b*x)/(c+d*x))^(m/n) where m and n>1 are integers, 
	SubstForFractionalPowerOfQuotientOfLinears[u,x] returns the list {v,n,(a+b*x)/(c+d*x),b*c-a*d} where v is u
	with subexpressions of the form ((a+b*x)/(c+d*x))^(m/n) replaced by x^m and x replaced
	by (-a+c*x^n)/(b-d*x^n), and all times x^(n-1)/(b-d*x^n)^2; else it returns False. *)
SubstForFractionalPowerOfQuotientOfLinears[u_,x_Symbol] :=
  Module[{lst=FractionalPowerOfQuotientOfLinears[u,1,False,x],n,a,b,c,d,tmp},
  If[FalseQ[lst] || FalseQ[lst[[2]]],
    False,
  n=lst[[1]];
  tmp=lst[[2]];
  lst=QuotientOfLinearsParts[tmp,x];
  a=lst[[1]];
  b=lst[[2]];
  c=lst[[3]];
  d=lst[[4]];
  If[ZeroQ[d],
    False,
  lst=x^(n-1)*SubstForFractionalPower[u,tmp,n,(-a+c*x^n)/(b-d*x^n),x]/(b-d*x^n)^2;
  lst=SplitFreeFactors[Simplify[lst],x];
  {lst[[2]],n,tmp,lst[[1]]*(b*c-a*d)}]]]


(* If the substitution x=v^(1/n) will not complicate algebraic subexpressions of u, 
	SubstForFractionalPowerQ[u,v,x] returns True; else it returns False. *)
SubstForFractionalPowerQ[u_,v_,x_Symbol] :=
  If[AtomQ[u] || FreeQ[u,x],
    True,
  If[FractionalPowerQ[u],
    SubstForFractionalPowerAuxQ[u,v,x],
  Catch[Scan[Function[If[Not[SubstForFractionalPowerQ[#,v,x]],Throw[False]]],u];True]]]

SubstForFractionalPowerAuxQ[u_,v_,x_] :=
  If[AtomQ[u],
    False,
  If[FractionalPowerQ[u] && ZeroQ[u[[1]]-v],
    True,
  Catch[Scan[Function[If[SubstForFractionalPowerAuxQ[#,v,x],Throw[True]]],u];False]]]


(* If u has a subexpression of the form ((a+b*x)/(c+d*x))^(m/n), 
	FractionalPowerOfQuotientOfLinears[u,1,False,x] returns {n,(a+b*x)/(c+d*x)}; else it returns False. *)
FractionalPowerOfQuotientOfLinears[u_,n_,v_,x_] :=
  If[AtomQ[u] || FreeQ[u,x],
    {n,v},
  If[CalculusQ[u],
    False,
  If[FractionalPowerQ[u] && QuotientOfLinearsQ[u[[1]],x] && Not[LinearQ[u[[1]],x]] && (FalseQ[v] || ZeroQ[u[[1]]-v]),
    {LCM[Denominator[u[[2]]],n],u[[1]]},
  Catch[Module[{lst={n,v}},
    Scan[Function[If[FalseQ[lst=FractionalPowerOfQuotientOfLinears[#,lst[[1]],lst[[2]],x]],Throw[False]]],u];
    lst]]]]]


(* If u has a subexpression of the form g[(a+b*x)/(c+d*x)] where g is the inverse of function h 
	and f[x,g[(a+b*x)/(c+d*x)]] equals u, SubstForInverseFunctionOfQuotientOfLinears[u,x] returns 
	the list {f[(-a+c*h[x])/(b-d*h[x]),x]*h'[x]/(b-d*h[x])^2, g[(a+b*x)/(c+d*x)], b*c-a*d} *)
SubstForInverseFunctionOfQuotientOfLinears[u_,x_Symbol] :=
  Module[{tmp=InverseFunctionOfQuotientOfLinears[u,x],h,a,b,c,d,lst},
  If[FalseQ[tmp],
    False,
  h=InverseFunction[Head[tmp]];
  lst=QuotientOfLinearsParts[tmp[[1]],x];
  a=lst[[1]];
  b=lst[[2]];
  c=lst[[3]];
  d=lst[[4]];
  {SubstForInverseFunction[u,tmp,(-a+c*h[x])/(b-d*h[x]),x]*D[h[x],x]/(b-d*h[x])^2, tmp, b*c-a*d}]]


(* If u has a subexpression of the form g[(a+b*x)/(c+d*x)] where g is an inverse function, 
	InverseFunctionOfQuotientOfLinears[u,x] returns g[(a+b*x)/(c+d*x)]; else it returns False. *)
InverseFunctionOfQuotientOfLinears[u_,x_Symbol] :=
  If[AtomQ[u] || CalculusQ[u] || FreeQ[u,x],
    False,
  If[InverseFunctionQ[u] && QuotientOfLinearsQ[u[[1]],x],
    u,
  Module[{tmp},
  Catch[
    Scan[Function[If[NotFalseQ[tmp=InverseFunctionOfQuotientOfLinears[#,x]],Throw[tmp]]],u];
    False]]]]


(* SubstForFractionalPower[u,v,n,w,x] returns u with subexpressions equal to v^(m/n) replaced 
	by x^m and x replaced by w. *)
SubstForFractionalPower[u_,v_,n_,w_,x_Symbol] :=
  If[AtomQ[u],
    If[u===x,
      w,
    u],
  If[FractionalPowerQ[u] && ZeroQ[u[[1]]-v],
    x^(n*u[[2]]),
  Map[Function[SubstForFractionalPower[#,v,n,w,x]],u]]]


(* SubstForInverseFunction[u,v,w,x] returns u with subexpressions equal to v replaced by x 
	and x replaced by w. *)
SubstForInverseFunction[u_,v_,x_Symbol] :=
(*  Module[{a=Coefficient[v[[1]],0],b=Coefficient[v[[1]],1]},
  SubstForInverseFunction[u,v,-a/b+InverseFunction[Head[v]]/b,x]] *)
  SubstForInverseFunction[u,v,
		(-Coefficient[v[[1]],x,0]+InverseFunction[Head[v]][x])/Coefficient[v[[1]],x,1],x]

SubstForInverseFunction[u_,v_,w_,x_Symbol] :=
  If[AtomQ[u],
    If[u===x,
      w,
    u],
  If[Head[u]===Head[v] && ZeroQ[u[[1]]-v[[1]]],
    x,
  Map[Function[SubstForInverseFunction[#,v,w,x]],u]]]


Gcd[m_,n_] :=
  Module[{denr=LCM[Denominator[m],Denominator[n]]},
  Sign[n]*GCD[m*denr,n*denr]/denr] /;
RationalQ[m,n]


(* If lst is a list of n terms, CommonNumericFactors[lst] returns a n+1-element list whose first
	element is the product of the numeric factors common to all terms of lst, and whose remaining
	elements are quotients of each term divided by the numeric common factor. *)
CommonNumericFactors [lst_] :=
  Module[{num=Apply[GCD,Map[NumericFactor,lst]]},
  Prepend[Map[Function[#/num],lst],num]]


(* NumericFactor[u] returns the product of the factors of u that are rational numbers. *)
NumericFactor[u_] :=
  If[NumberQ[u],
    If[ZeroQ[Im[u]],
      u,
    If[ZeroQ[Re[u]],
      Im[u],
    1]],
  If[PowerQ[u],
    If[RationalQ[u[[1]]] && FractionQ[u[[2]]],
      If[u[[2]]>0,
        1/Denominator[u[[1]]],
      1/Denominator[1/u[[1]]]],
    1],
  If[ProductQ[u],
    Map[NumericFactor,u],
  If[SumQ[u],
    Function[If[SumQ[#], 1, NumericFactor[#]]][ContentFactor[u]],
  1]]]]


(* NonnumericFactors[u] returns the product of the factors of u that are not rational numbers. *)
NonnumericFactors[u_] :=
  If[NumberQ[u],
    If[ZeroQ[Im[u]],
      1,    
    If[ZeroQ[Re[u]],
      I,
    u]],
  If[PowerQ[u],
    If[RationalQ[u[[1]]] && FractionQ[u[[2]]],
      u/NumericFactor[u],
    u],
  If[ProductQ[u],
    Map[NonnumericFactors,u],
  If[SumQ[u],
    Function[If[SumQ[#], u, NonnumericFactors[#]]][ContentFactor[u]],
  u]]]]


(* AbsurdNumberQ[u] returns True if u is an absurd number, else it returns False. *)
AbsurdNumberQ[u_] :=
  RationalQ[u]

AbsurdNumberQ[u_^v_] :=
  RationalQ[u] && u>0 && FractionQ[v]

AbsurdNumberQ[u_*v_] :=
  AbsurdNumberQ[u] && AbsurdNumberQ[v]


(* AbsurdNumberFactors[u] returns the product of the factors of u that are absurd numbers. *)
AbsurdNumberFactors[u_] :=
  If[AbsurdNumberQ[u],
    u,
  If[ProductQ[u],
    Map[AbsurdNumberFactors,u],
  NumericFactor[u]]]


(* NonabsurdNumberFactors[u] returns the product of the factors of u that are not absurd numbers. *)
NonabsurdNumberFactors[u_] :=
  If[AbsurdNumberQ[u],
    1,
  If[ProductQ[u],
    Map[NonabsurdNumberFactors,u],
  NonnumericFactors[u]]]


(* m must be an absurd number.  FactorAbsurdNumber[m] returns the prime factorization of m *) 
(* as list of base-degree pairs where the bases are prime numbers and the degrees are rational. *)
FactorAbsurdNumber[m_] :=
  If[RationalQ[m],
    FactorInteger[m],
  If[PowerQ[m],
    Map[Function[{#[[1]], #[[2]]*m[[2]]}],FactorInteger[m[[1]]]],
  CombineExponents[Sort[Flatten[Map[FactorAbsurdNumber,Apply[List,m]],1], Function[#1[[1]]<#2[[1]]]]]]]


CombineExponents[lst_] :=
  If[Length[lst]<2,
    lst,
  If[lst[[1,1]]==lst[[2,1]],
    CombineExponents[Prepend[Drop[lst,2],{lst[[1,1]],lst[[1,2]]+lst[[2,2]]}]],
  Prepend[CombineExponents[Rest[lst]],First[lst]]]]


(* m, n, ... must be absurd numbers.  AbsurdNumberGCD[m,n,...] returns the gcd of m, n, ... *) 
AbsurdNumberGCD[seq__] :=
  Module[{lst={seq}},
  If[Length[lst]==1,
    First[lst],
  AbsurdNumberGCDList[FactorAbsurdNumber[First[lst]],FactorAbsurdNumber[Apply[AbsurdNumberGCD,Rest[lst]]]]]]


(* lst1 and lst2 must be absurd number prime factorization lists. *)
(* AbsurdNumberGCDList[lst1,lst2] returns the gcd of the absurd numbers represented by lst1 and lst2. *) 
AbsurdNumberGCDList[lst1_,lst2_] :=
  If[lst1==={},
    Apply[Times,Map[Function[#[[1]]^Min[#[[2]],0]],lst2]],
  If[lst2==={},
    Apply[Times,Map[Function[#[[1]]^Min[#[[2]],0]],lst1]],
  If[lst1[[1,1]]==lst2[[1,1]],
    If[lst1[[1,2]]<=lst2[[1,2]],
      lst1[[1,1]]^lst1[[1,2]]*AbsurdNumberGCDList[Rest[lst1],Rest[lst2]],
    lst1[[1,1]]^lst2[[1,2]]*AbsurdNumberGCDList[Rest[lst1],Rest[lst2]]],
  If[lst1[[1,1]]<lst2[[1,1]],
    If[lst1[[1,2]]<0,
      lst1[[1,1]]^lst1[[1,2]]*AbsurdNumberGCDList[Rest[lst1],lst2],
    AbsurdNumberGCDList[Rest[lst1],lst2]],
  If[lst2[[1,2]]<0,
    lst2[[1,1]]^lst2[[1,2]]*AbsurdNumberGCDList[lst1,Rest[lst2]],
  AbsurdNumberGCDList[lst1,Rest[lst2]]]]]]]


(* NormalizeIntegrand[u,x] returns u in a standard form recognizable by integration rules. *) 
NormalizeIntegrand[u_,x_Symbol] :=
  Module[{v=NormalizeLeadTermSigns[NormalizeIntegrandAux[u,x]]},
  If[v===NormalizeLeadTermSigns[u],
    u,
  v]]


NormalizeIntegrandAux[u_,x_Symbol] :=
  If[SumQ[u],
    Map[Function[NormalizeIntegrandAux[#,x]],u],
  If[ProductQ[u],
    Map[Function[NormalizeIntegrandFactor[#,x]],u],
  NormalizeIntegrandFactor[u,x]]]


NormalizeIntegrandFactor[u_,x_Symbol] :=
  Module[{bas,deg,min},
  If[PowerQ[u] && FreeQ[u[[2]],x],
    bas=NormalizeIntegrandFactorBase[u[[1]],x];
    deg=u[[2]];
    If[IntegerQ[deg] && SumQ[bas],
      If[MapAnd[Function[MonomialQ[#,x]],bas],
        min=MinimumMonomialExponent[bas,x];
        x^(min*deg)*Map[Function[Simplify[#/x^min]],bas]^deg,
      bas^deg],
    bas^deg],
  If[PowerQ[u] && FreeQ[u[[1]],x],
    u[[1]]^NormalizeIntegrandFactorBase[u[[2]],x],
  bas=NormalizeIntegrandFactorBase[u,x];
  If[SumQ[bas],
    If[MapAnd[Function[MonomialQ[#,x]],bas],
      min=MinimumMonomialExponent[bas,x];
      x^min*Map[Function[#/x^min],bas],
    bas],
  bas]]]]


NormalizeIntegrandFactorBase[x_^m_.*u_,x_Symbol] :=
  NormalizeIntegrandFactorBase[Map[Function[x^m*#],u],x] /;
FreeQ[m,x] && SumQ[u]


NormalizeIntegrandFactorBase[u_,x_Symbol] :=
  If[BinomialQ[u,x],
    If[BinomialMatchQ[u,x],
      u,
    ExpandToSum[u,x]],
  If[TrinomialQ[u,x],
    If[TrinomialMatchQ[u,x],
      u,
    ExpandToSum[u,x]],
  If[ProductQ[u],
    Map[Function[NormalizeIntegrandFactor[#,x]],u],
  If[PolynomialQ[u,x] && Exponent[u,x]<=4,
    ExpandToSum[u,x],    
  If[SumQ[u],
    Module[{v=TogetherSimplify[u]},
    If[SumQ[v] || MatchQ[v, x^m_.*w_ /; FreeQ[m,x] && SumQ[w]] || LeafCount[v]>LeafCount[u]+2,
      UnifySum[u,x],
    NormalizeIntegrandFactorBase[v,x]]],
  Map[Function[NormalizeIntegrandFactor[#,x]],u]]]]]]


(* NormalizeLeadTermSigns[u] returns an expression equal u but with not more than one sum 
	factor raised to a integer degree having a lead term with a negative coefficient. *)
NormalizeLeadTermSigns[u_] :=
  Module[{lst=If[ProductQ[u], Map[SignOfFactor,u], SignOfFactor[u]]},
  If[lst[[1]]==1,
    lst[[2]],
  AbsorbMinusSign[lst[[2]]]]]


(* AbsorbMinusSign[u] returns an expression equal to -u.  If there is a factor of u of the 
	form v^m where v is a sum and m is an odd power, the minus sign is distributed over v;
	otherwise -u is returned. *)
AbsorbMinusSign[u_.*v_Plus] :=
  u*(-v)

AbsorbMinusSign[u_.*v_Plus^m_] :=
  u*(-v)^m /;
OddQ[m]

AbsorbMinusSign[u_] :=
  -u


(* NormalizeSumFactors[u] returns an expression equal u but with the numeric coefficient of 
	the lead term of sum factors made positive where possible. *)
NormalizeSumFactors[u_] :=
  If[AtomQ[u] || Head[u]===If || Head[u]===Int || HeldFormQ[u],
    u,
  If[ProductQ[u],
    Function[#[[1]]*#[[2]]][SignOfFactor[Map[NormalizeSumFactors,u]]],
  Map[NormalizeSumFactors,u]]]


(* SignOfFactor[u] returns the list {n,v} where n*v equals u, n^2 equals 1, and the lead 
	term of the sum factors of v raised to integer degrees all have positive coefficients. *)
SignOfFactor[u_] :=
  If[RationalQ[u] && u<0 || SumQ[u] && NumericFactor[First[u]]<0,
    {-1, -u},
  If[IntegerPowerQ[u] && SumQ[u[[1]]] && NumericFactor[First[u[[1]]]]<0,
    {(-1)^u[[2]], (-u[[1]])^u[[2]]},
  If[ProductQ[u],
    Map[SignOfFactor,u],
  {1, u}]]]


(* u can be square-free factored into an expression of the form (a+b*x)^m. *)
(* NormalizePowerOfLinear[u,x] returns u in the form (a+b*x)^m. *)
NormalizePowerOfLinear[u_,x_Symbol] :=
  Module[{v=FactorSquareFree[u]},
  If[PowerQ[v] && LinearQ[v[[1]],x] && FreeQ[v[[2]],x],
    ExpandToSum[v[[1]],x]^v[[2]],
  ExpandToSum[v,x]]]


(* SimplifyIntegrand[u,x] simplifies u and returns the result in a standard form recognizable by integration rules. *) 
SimplifyIntegrand[u_,x_Symbol] :=
  Module[{v},
  v=NormalizeLeadTermSigns[NormalizeIntegrandAux[Simplify[u],x]];
  If[LeafCount[v]<4/5*LeafCount[u],
    v,
  If[v=!=NormalizeLeadTermSigns[u],
    v,
  u]]]


SimplifyTerm[u_,x_Symbol] :=
  Module[{v=Simplify[u],w},
  w=Together[v];
  NormalizeIntegrand[If[LeafCount[v]<LeafCount[w],w,w],x]]


TogetherSimplify[u_] :=
  TimeConstrained[
    Module[{v},
    v=Together[Simplify[Together[u]]];
    TimeConstrained[FixSimplify[v],TimeLimit/3,v]],
  TimeLimit,u]


(* TogetherSimplify could replace SmartSimplify, but results in more complicated *)
(* antiderivatives and would require thousands of changes to test suite. *)
SmartSimplify[u_] :=
  TimeConstrained[
    Module[{v,w},
    v=Simplify[u];
    w=Factor[v];
    v=If[LeafCount[w]<LeafCount[v] (* -1 *),w,v];
    v=If[NotFalseQ[w=FractionalPowerOfSquareQ[v]] && FractionalPowerSubexpressionQ[u,w,Expand[w]],SubstForExpn[v,w,Expand[w]],v];
    v=FactorNumericGcd[v];
    TimeConstrained[FixSimplify[v],TimeLimit/3,v]],
  TimeLimit,u]


Simp[u_,x_] :=
  TimeConstrained[NormalizeSumFactors[SimpHelp[u,x]],TimeLimit,u]

SimpHelp[E^(u_.*(v_.*Log[a_]+w_)),x_] :=
  a^(u*v)*SimpHelp[E^(u*w),x]

SimpHelp[u_,x_] :=
  If[AtomQ[u],
    u,
  If[Head[u]===If || Head[u]===Int || HeldFormQ[u],
    u,
  If[FreeQ[u,x],
    Module[{v=SmartSimplify[u]},
    If[LeafCount[v]<=LeafCount[u],
      v,
    u]],
  If[ProductQ[u],
    Module[{v=FreeFactors[u,x],w=NonfreeFactors[u,x]},
    v=NumericFactor[v]*SmartSimplify[NonnumericFactors[v]*x^2]/x^2;
    w=If[ProductQ[w], Map[Function[SimpHelp[#,x]],w], SimpHelp[w,x]];
    w=FactorNumericGcd[w];
    v=MergeFactors[v,w];
    If[ProductQ[v],
      Map[Function[SimpFixFactor[#,x]],v],
    v]],
  If[SumQ[u],
    If[PolynomialQ[u,x] && Exponent[u,x]<=0,
      SimpHelp[Coefficient[u,x,0],x],
    If[PolynomialQ[u,x] && Exponent[u,x]==1 && Coefficient[u,x,0]===0,
      SimpHelp[Coefficient[u,x,1],x]*x,
    Module[{v=0,w=0},
    Scan[Function[If[FreeQ[#,x],v=#+v,w=#+w]],u];
    v=SmartSimplify[v];
    w=If[SumQ[w], Map[Function[SimpHelp[#,x]],w], SimpHelp[w,x]];
    v+w]]],
  Map[Function[SimpHelp[#,x]],u]]]]]]


(* If a subexpression of u is of the form ((v+w)^2)^n where n is a fraction, *)
(* FractionalPowerOfSquareQ[u] returns (v+w)^2; else it returns False. *)
FractionalPowerOfSquareQ[u_] :=
  If[AtomQ[u],
    False,
  If[FractionalPowerQ[u] && MatchQ[u[[1]], a_.*(b_+c_)^2 /; NonsumQ[a]],
    u[[1]],
  Module[{tmp},
  Catch[
    Scan[Function[If[NotFalseQ[tmp=FractionalPowerOfSquareQ[#]],Throw[tmp]]],u];
    False]]]]


(* If a subexpression of u is of the form w^n where n is a fraction but not equal to v, *)
(* FractionalPowerSubexpressionQ[u,v,w] returns True; else it returns False. *)
FractionalPowerSubexpressionQ[u_,v_,w_] :=
  If[AtomQ[u],
    False,
  If[FractionalPowerQ[u] && PositiveQ[u[[1]]/w],
    Not[u[[1]]===v] && LeafCount[w]<3*LeafCount[v],
  Catch[Scan[Function[If[FractionalPowerSubexpressionQ[#,v,w],Throw[True]]],u]; False]]]


Clear[FixSimplify]


FixSimplify[u_.*Complex[0,a_]*(v_.*Complex[0,b_]+w_)^n_.] :=
  (-1)^((n+1)/2)*a*u*FixSimplify[(b*v-Complex[0,1]*w)^n] /;
OddQ[n]


FixSimplify[w_.*u_^m_.*v_^n_] :=
  Module[{z=Simplify[u^(m/GCD[m,n])*v^(n/GCD[m,n])]},
  FixSimplify[w*z^GCD[m,n]]/;
 AbsurdNumberQ[z] || SqrtNumberSumQ[z]] /;
RationalQ[m] && FractionQ[n] && SqrtNumberSumQ[u] && SqrtNumberSumQ[v] && PositiveQ[u] && PositiveQ[v]


FixSimplify[w_.*u_^m_.*v_^n_] :=
  Module[{z=Simplify[u^(m/GCD[m,-n])*v^(n/GCD[m,-n])]},
  FixSimplify[w*z^GCD[m,-n]]/;
 AbsurdNumberQ[z] || SqrtNumberSumQ[z]] /;
RationalQ[m] && FractionQ[n] && SqrtNumberSumQ[u] && SqrtNumberSumQ[1/v] && PositiveQ[u] && PositiveQ[v]


FixSimplify[w_.*u_^m_.*v_^n_] :=
  Module[{z=Simplify[(-u)^(m/GCD[m,n])*v^(n/GCD[m,n])]},
  FixSimplify[-w*z^GCD[m,n]]/;
 AbsurdNumberQ[z] || SqrtNumberSumQ[z]] /;
IntegerQ[m] && FractionQ[n] && SqrtNumberSumQ[u] && SqrtNumberSumQ[v] && NegativeQ[u] && PositiveQ[v]


FixSimplify[w_.*u_^m_.*v_^n_] :=
  Module[{z=Simplify[(-u)^(m/GCD[m,-n])*v^(n/GCD[m,-n])]},
  FixSimplify[-w*z^GCD[m,-n]]/;
 AbsurdNumberQ[z] || SqrtNumberSumQ[z]] /;
IntegerQ[m] && FractionQ[n] && SqrtNumberSumQ[u] && SqrtNumberSumQ[1/v] && NegativeQ[u] && PositiveQ[v]


FixSimplify[w_.*a_^m_*(u_+b_^n_*v_.)^p_.] :=
  Module[{c=Simplify[a^(m/p)*b^n]},
  FixSimplify[w*(a^(m/p)*u+c*v)^p] /;
 RationalQ[c]] /;
RationalQ[a,b,m,n] && a>0 && b>0 && PositiveIntegerQ[p]


FixSimplify[w_.*a_^m_.*(a_^n_*u_.+b_^p_.*v_.)] :=
  FixSimplify[w*a^(m+n)*(u+(-1)^p*a^(p-n)*v)] /;
RationalQ[m] && FractionQ[n] && IntegerQ[p] && p-n>0 && a+b===0


FixSimplify[w_.*(a_+b_)^m_.*(c_+d_)^n_] :=
  Module[{q=Simplify[b/d]},
  FixSimplify[w*q^m*(c+d)^(m+n)] /;
 FreeQ[q,Plus]] /;
IntegerQ[m] && Not[IntegerQ[n]] && ZeroQ[b*c-a*d]


FixSimplify[w_.*(a_^m_.*u_.+a_^n_.*v_.)^t_.] :=
  FixSimplify[a^(m*t)*w*(u+a^(n-m)*v)^t] /;
Not[RationalQ[a]] && IntegerQ[t] && RationalQ[m,n] && 0<m<=n

FixSimplify[w_.*(a_^m_.*u_.+a_^n_.*v_.+a_^p_.*z_.)^t_.] :=
  FixSimplify[a^(m*t)*w*(u+a^(n-m)*v+a^(p-m)*z)^t] /;
Not[RationalQ[a]] && IntegerQ[t] && RationalQ[m,n,p] && 0<m<=n<=p

FixSimplify[w_.*(a_^m_.*u_.+a_^n_.*v_.+a_^p_.*z_.+a_^q_.*y_.)^t_.] :=
  FixSimplify[a^(m*t)*w*(u+a^(n-m)*v+a^(p-m)*z+a^(q-m)*y)^t] /;
Not[RationalQ[a]] && IntegerQ[t] && RationalQ[m,n,p] && 0<m<=n<=p<=q


FixSimplify[w_.*(u_.+a_.*Sqrt[v_Plus]+b_.*Sqrt[v_]+c_.*Sqrt[v_]+d_.*Sqrt[v_])] :=
  FixSimplify[w*(u+FixSimplify[a+b+c+d]*Sqrt[v])]

FixSimplify[w_.*(u_.+a_.*Sqrt[v_Plus]+b_.*Sqrt[v_]+c_.*Sqrt[v_])] :=
  FixSimplify[w*(u+FixSimplify[a+b+c]*Sqrt[v])]

FixSimplify[w_.*(u_.+a_.*Sqrt[v_Plus]+b_.*Sqrt[v_])] :=
  FixSimplify[w*(u+FixSimplify[a+b]*Sqrt[v])]


FixSimplify[u_.*a_^m_*Sqrt[b_.*(c_+d_.*Sqrt[a_])]] :=
  Sqrt[Together[b*(c*a^(2*m)+d*a^(2*m+1/2))]]*FixSimplify[u] /;
RationalQ[a,b,c,d,m] && a>0 && Denominator[m]==4

FixSimplify[u_.*a_^m_/Sqrt[b_.*(c_+d_.*Sqrt[a_])]] :=
  FixSimplify[u]/Sqrt[Together[b*(c/a^(2*m)+d/a^(2*m-1/2))]] /;
RationalQ[a,b,c,d,m] && a>0 && Denominator[m]==4


FixSimplify[u_.*v_^m_*w_^n_] :=
  -FixSimplify[u*v^(m-1)] /;
RationalQ[m] && Not[RationalQ[w]] && FractionQ[n] && n<0 && ZeroQ[v+w^(-n)]


FixSimplify[u_.*v_^m_*w_^n_.] :=
  (-1)^(n)*FixSimplify[u*v^(m+n)] /;
RationalQ[m] && Not[RationalQ[w]] && IntegerQ[n] && ZeroQ[v+w]


FixSimplify[u_.*(-v_^p_.)^m_*w_^n_.] :=
  (-1)^(n/p)*FixSimplify[u*(-v^p)^(m+n/p)] /;
RationalQ[m] && Not[RationalQ[w]] && IntegerQ[n/p] && ZeroQ[v-w]


FixSimplify[u_.*(-v_^p_.)^m_*w_^n_.] :=
  (-1)^(n+n/p)*FixSimplify[u*(-v^p)^(m+n/p)] /;
RationalQ[m] && Not[RationalQ[w]] && IntegersQ[n,n/p] && ZeroQ[v+w]


FixSimplify[u_.*(a-b)^m_.*(a+b)^m_.] :=
  u*(a^2-b^2)^m /;
IntegerQ[m]

FixSimplify[u_.*(c*d^2-e*(b*d-a*e))^m_.] :=
  u*(c*d^2-b*d*e+a*e^2)^m /;
RationalQ[m]

FixSimplify[u_.*(c*d^2+e*(-b*d+a*e))^m_.] :=
  u*(c*d^2-b*d*e+a*e^2)^m /;
RationalQ[m]

FixSimplify[u_] := u


(* SimpFixFactor[(a_.*c_ + b_.*c_)^p_.,x_] :=
  c^p*SimpFixFactor[(a+b)^p,x] /;
FreeQ[c,x] && IntegerQ[p] && c^p=!=-1 *)

SimpFixFactor[(a_.*Complex[0,c_] + b_.*Complex[0,d_])^p_.,x_] :=
  I^p*SimpFixFactor[(a*c+b*d)^p,x] /;
IntegerQ[p]

SimpFixFactor[(a_.*Complex[0,d_] + b_.*Complex[0,e_]+ c_.*Complex[0,f_])^p_.,x_] :=
  I^p*SimpFixFactor[(a*d+b*e+c*f)^p,x] /;
IntegerQ[p]


SimpFixFactor[(a_.*c_^r_ + b_.*x_^n_.)^p_.,x_] :=
  c^(r*p)*SimpFixFactor[(a+b/c^r*x^n)^p,x] /;
FreeQ[{a,b,c},x] && IntegersQ[n,p] && AtomQ[c] && RationalQ[r] && r<0

SimpFixFactor[(a_. + b_.*c_^r_*x_^n_.)^p_.,x_] :=
  c^(r*p)*SimpFixFactor[(a/c^r+b*x^n)^p,x] /;
FreeQ[{a,b,c},x] && IntegersQ[n,p] && AtomQ[c] && RationalQ[r] && r<0


SimpFixFactor[(a_.*c_^s_. + b_.*c_^r_.*x_^n_.)^p_.,x_] :=
  c^(s*p)*SimpFixFactor[(a+b*c^(r-s)*x^n)^p,x] /;
FreeQ[{a,b,c},x] && IntegersQ[n,p] && RationalQ[s,r] && 0<s<=r && c^(s*p)=!=-1

SimpFixFactor[(a_.*c_^s_. + b_.*c_^r_.*x_^n_.)^p_.,x_] :=
  c^(r*p)*SimpFixFactor[(a*c^(s-r)+b*x^n)^p,x] /;
FreeQ[{a,b,c},x] && IntegersQ[n,p] && RationalQ[s,r] && 0<r<s && c^(r*p)=!=-1

SimpFixFactor[u_,x_] := u


(* FactorNumericGcd[u] returns u with the gcd of the numeric coefficients of terms of sums factored out. *)
FactorNumericGcd[u_] :=
  If[PowerQ[u] && RationalQ[u[[2]]],
    FactorNumericGcd[u[[1]]]^u[[2]],
  If[ProductQ[u],
    Map[FactorNumericGcd,u],
  If[SumQ[u],
    Module[{g=Apply[GCD,Map[NumericFactor,Apply[List,u]]]},
    g*Map[Function[#/g],u]],
  u]]]


(* MergeFactors[u,v] returns the product of u and v, but with the mergeable factors of u merged into v. *)
MergeFactors[u_,v_] :=
  If[ProductQ[u],
    MergeFactors[Rest[u],MergeFactors[First[u],v]],
  If[PowerQ[u],
    If[MergeableFactorQ[u[[1]],u[[2]],v],
      MergeFactor[u[[1]],u[[2]],v],
    If[RationalQ[u[[2]]] && u[[2]]<-1 && MergeableFactorQ[u[[1]],-1,v],
      MergeFactors[u[[1]]^(u[[2]]+1),MergeFactor[u[[1]],-1,v]],
    u*v]],
  If[MergeableFactorQ[u,1,v],
    MergeFactor[u,1,v],
  u*v]]]


(* If MergeableFactorQ[bas,deg,v], MergeFactor[bas,deg,v] return the product of bas^deg and v, 
	but with bas^deg merged into the factor of v whose base equals bas. *)
MergeFactor[bas_,deg_,v_] :=
  If[bas===v,
    bas^(deg+1),
  If[PowerQ[v],
    If[bas===v[[1]],
      bas^(deg+v[[2]]),
    MergeFactor[bas,deg/v[[2]],v[[1]]]^v[[2]]],
  If[ProductQ[v],
    If[MergeableFactorQ[bas,deg,First[v]],
      MergeFactor[bas,deg,First[v]]*Rest[v],
    First[v]*MergeFactor[bas,deg,Rest[v]]],
  MergeFactor[bas,deg,First[v]] + MergeFactor[bas,deg,Rest[v]]]]]


(* MergeableFactorQ[bas,deg,v] returns True iff bas equals the base of a factor of v or bas is a factor of every term of v. *)
MergeableFactorQ[bas_,deg_,v_] :=
  If[bas===v,
    RationalQ[deg+1] && (deg+1>=0 || RationalQ[deg] && deg>0),
  If[PowerQ[v],
    If[bas===v[[1]],
      RationalQ[deg+v[[2]]] && (deg+v[[2]]>=0 || RationalQ[deg] && deg>0),
    SumQ[v[[1]]] && IntegerQ[v[[2]]] && (Not[IntegerQ[deg]] || IntegerQ[deg/v[[2]]]) && MergeableFactorQ[bas,deg/v[[2]],v[[1]]]],
  If[ProductQ[v],
    MergeableFactorQ[bas,deg,First[v]] || MergeableFactorQ[bas,deg,Rest[v]],
  SumQ[v] && MergeableFactorQ[bas,deg,First[v]] && MergeableFactorQ[bas,deg,Rest[v]]]]]


(* TrigSimplifyQ[u] returns True if TrigSimplify[u] actually simplifies u; else False. *)
TrigSimplifyQ[u_] :=
  ActivateTrig[u]=!=TrigSimplify[u]


(* TrigSimplify[u] returns a bottom-up trig simplification of u. *)
TrigSimplify[u_] :=
  ActivateTrig[TrigSimplifyRecur[u]]


TrigSimplifyRecur[u_] :=
  If[AtomQ[u],
    u,
  If[Head[u]===If,
    u,
  TrigSimplifyAux[Map[TrigSimplifyRecur,u]]]]

Clear[TrigSimplifyAux]


(* Basis: a*z^m+b*z^n == z^m*(a+b*z^(n-m)) *)
TrigSimplifyAux[u_.*(a_.*v_^m_.+b_.*v_^n_.)^p_] :=
  u*v^(m*p)*TrigSimplifyAux[a+b*v^(n-m)]^p /;
InertTrigQ[v] && IntegerQ[p] && RationalQ[m,n] && m<n


TrigSimplifyAux[a_.*cos[u_]^2+b_.*sin[u_]^2+v_.] := a+v /; a===b

TrigSimplifyAux[a_.*sec[u_]^2+b_.*tan[u_]^2+v_.] := a+v /; a===-b

TrigSimplifyAux[a_.*csc[u_]^2+b_.*cot[u_]^2+v_.] := a+v /; a===-b


TrigSimplifyAux[(a_.*cos[u_]^2+b_.*sin[u_]^2+v_.)^n_] := 
  ((b-a)*Sin[u]^2+a+v)^n


(* Basis: 1-Sin[z]^2 == Cos[z]^2 *)
TrigSimplifyAux[u_+v_.*sin[z_]^2+w_.] := u*Cos[z]^2+w /; u===-v

(* Basis: 1-Cos[z]^2 == Sin[z]^2 *)
TrigSimplifyAux[u_+v_.*cos[z_]^2+w_.] := u*Sin[z]^2+w /; u===-v

(* Basis: 1+Tan[z]^2 == Sec[z]^2 *)
TrigSimplifyAux[u_+v_.*tan[z_]^2+w_.] := u*Sec[z]^2+w /; u===v

(* Basis: 1+Cot[z]^2 == Csc[z]^2 *)
TrigSimplifyAux[u_+v_.*cot[z_]^2+w_.] := u*Csc[z]^2+w /; u===v

(* Basis: -1+Sec[z]^2 == Tan[z]^2 *)
TrigSimplifyAux[u_+v_.*sec[z_]^2+w_.] := v*Tan[z]^2+w /; u===-v

(* Basis: -1+Csc[z]^2 == Cot[z]^2 *)
TrigSimplifyAux[u_+v_.*csc[z_]^2+w_.] := v*Cot[z]^2+w /; u===-v


(* Basis: If a^2-b^2==0, Sin[z]^2/(a+b*Cos[z]) == 1/a-Cos[z]/b *)
TrigSimplifyAux[u_.*sin[v_]^2/(a_+b_.*cos[v_])] := u*(1/a - Cos[v]/b) /; ZeroQ[a^2-b^2]

(* Basis: If a^2-b^2==0, Cos[z]^2/(a+b*Sin[z]) == 1/a-Sin[z]/b *)
TrigSimplifyAux[u_.*cos[v_]^2/(a_+b_.*sin[v_])] := u*(1/a - Sin[v]/b) /; ZeroQ[a^2-b^2]


(* Basis: If n is an integer, Tan[z]^n/(a+b*Tan[z]^n) == 1/(b+a*Cot[z]^n) *)
TrigSimplifyAux[u_.*tan[v_]^n_./(a_+b_.*tan[v_]^n_.)] := u/(b+a*Cot[v]^n) /; PositiveIntegerQ[n] && NonsumQ[a]

(* Basis: If n is an integer, Cot[z]^n/(a+b*Cot[z]^n) == 1/(b+a*Tan[z]^n) *)
TrigSimplifyAux[u_.*cot[v_]^n_./(a_+b_.*cot[v_]^n_.)] := u/(b+a*Tan[v]^n) /; PositiveIntegerQ[n] && NonsumQ[a]

(* Basis: If n is an integer, Sec[z]^n/(a+b*Sec[z]^n) == 1/(b+a*Cos[z]^n) *)
TrigSimplifyAux[u_.*sec[v_]^n_./(a_+b_.*sec[v_]^n_.)] := u/(b+a*Cos[v]^n) /; PositiveIntegerQ[n] && NonsumQ[a]

(* Basis: If n is an integer, Csc[z]^n/(a+b*Csc[z]^n) == 1/(b+a*Sin[z]^n) *)
TrigSimplifyAux[u_.*csc[v_]^n_./(a_+b_.*csc[v_]^n_.)] := u/(b+a*Sin[v]^n) /; PositiveIntegerQ[n] && NonsumQ[a]


(* Basis: If n is an integer, Tan[z]^n/(a+b*Sec[z]^n) == Sin[z]^n/(b+a*Cos[z]^n) *)
TrigSimplifyAux[u_.*tan[v_]^n_./(a_+b_.*sec[v_]^n_.)] := u*Sin[v]^n/(b+a*Cos[v]^n) /; PositiveIntegerQ[n] && NonsumQ[a]

(* Basis: If n is an integer, Cot[z]^n/(a+b*Csc[z]^n) == Cos[z]^n/(b+a*Sin[z]^n) *)
TrigSimplifyAux[u_.*cot[v_]^n_./(a_+b_.*csc[v_]^n_.)] := u*Cos[v]^n/(b+a*Sin[v]^n) /; PositiveIntegerQ[n] && NonsumQ[a]


TrigSimplifyAux[u_.*(a_.*sec[v_]^n_.+b_.*tan[v_]^n_.)^p_.] :=
  u*Sec[v]^(n*p)*(a+b*Sin[v]^n)^p /;
IntegersQ[n,p]

TrigSimplifyAux[u_.*(a_.*csc[v_]^n_.+b_.*cot[v_]^n_.)^p_.] :=
  u*Csc[v]^(n*p)*(a+b*Cos[v]^n)^p /;
IntegersQ[n,p]


TrigSimplifyAux[u_.*(a_.*tan[v_]^n_.+b_.*sin[v_]^n_.)^p_.] :=
  u*Tan[v]^(n*p)*(a+b*Cos[v]^n)^p /;
IntegersQ[n,p]

TrigSimplifyAux[u_.*(a_.*cot[v_]^n_.+b_.*cos[v_]^n_.)^p_.] :=
  u*Cot[v]^(n*p)*(a+b*Sin[v]^n)^p /;
IntegersQ[n,p]


TrigSimplifyAux[u_.*cos[v_]^m_.*(a_.+b_.*tan[v_]^n_.+c_.*sec[v_]^n_.)^p_.] :=
  u*Cos[v]^(m-n*p)*(c+b*Sin[v]^n+a*Cos[v]^n)^p /;
IntegersQ[m,n,p]

TrigSimplifyAux[u_.*sec[v_]^m_.*(a_.+b_.*tan[v_]^n_.+c_.*sec[v_]^n_.)^p_.] :=
  u*Sec[v]^(m+n*p)*(c+b*Sin[v]^n+a*Cos[v]^n)^p /;
IntegersQ[m,n,p]

TrigSimplifyAux[u_.*sin[v_]^m_.*(a_.+b_.*cot[v_]^n_.+c_.*csc[v_]^n_.)^p_.] :=
  u*Sin[v]^(m-n*p)*(c+b*Cos[v]^n+a*Sin[v]^n)^p /;
IntegersQ[m,n,p]

TrigSimplifyAux[u_.*csc[v_]^m_.*(a_.+b_.*cot[v_]^n_.+c_.*csc[v_]^n_.)^p_.] :=
  u*Csc[v]^(m+n*p)*(c+b*Cos[v]^n+a*Sin[v]^n)^p /;
IntegersQ[m,n,p]


TrigSimplifyAux[u_.*(a_.*csc[v_]^m_.+b_.*sin[v_]^n_.)^p_.] :=
  If[ZeroQ[m+n-2] && ZeroQ[a+b],
    u*(a*Cos[v]^2/Sin[v]^m)^p,
  u*((a+b*Sin[v]^(m+n))/Sin[v]^m)^p] /;
IntegersQ[m,n]

TrigSimplifyAux[u_.*(a_.*sec[v_]^m_.+b_.*cos[v_]^n_.)^p_.] :=
  If[ZeroQ[m+n-2] && ZeroQ[a+b],
    u*(a*Sin[v]^2/Cos[v]^m)^p,
  u*((a+b*Cos[v]^(m+n))/Cos[v]^m)^p] /;
IntegersQ[m,n]


(* (* Basis: Csc[z]+Cot[z] == Cot[z/2] *)
TrigSimplifyAux[(a_.*csc[v_]+b_.*cot[v_])^n_] := a^n*Cot[v/2]^n /; EvenQ[n] && ZeroQ[a-b]

(* Basis: Csc[z]-Cot[z] == Tan[z/2] *)
TrigSimplifyAux[(a_.*csc[v_]+b_.*cot[v_])^n_] := a^n*Tan[v/2]^n /; EvenQ[n] && ZeroQ[a+b] *)


(* (* Basis: Sin[z]*(a+b*Cot[z]) == a*Sin[z] + b*Cos[z] *)
(* TrigSimplifyAux[u_*sin[v_]^m_.*(a_.+b_.*cot[v_]^2)^p_.] :=
  u*(b*Cos[v]^2+a*Sin[v]^2)^p /;
IntegersQ[m,p] && m==2*p *)

(* Basis: a+b*Cot[z] == (b*Cos[z]+a*Sin[z])/Sin[z] *)
TrigSimplifyAux[u_.*sin[v_]^m_.*(a_.+b_.*cot[v_]^n_.)^p_.] :=
  u*Sin[v]^(m-n*p)*(b*Cos[v]^n+a*Sin[v]^n)^p /;
IntegersQ[m,n,p]

(* Basis: Cos[z]*(a+b*Tan[z]) == a*Cos[z] + b*Sin[z] *)
(* TrigSimplifyAux[u_*cos[v_]^m_.*(a_.+b_.*tan[v_]^2)^p_.] :=
  u*(b*Sin[v]^2+a*Cos[v]^2)^p /;
IntegersQ[m,p] && m==2*p *)

(* Basis: a+b*Tan[z] == (b*Sin[z]+a*Cos[z])/Cos[z] *)
TrigSimplifyAux[u_.*cos[v_]^m_.*(a_.+b_.*tan[v_]^n_.)^p_.] :=
  u*Cos[v]^(m-n*p)*(b*Sin[v]^n+a*Cos[v]^n)^p /;
IntegersQ[m,n,p]

(* Basis: (a+b*Tan[z])/Sec[z] == a*Cos[z] + b*Sin[z] *)
TrigSimplifyAux[u_*sec[v_]^m_.*(a_.+b_.*tan[v_]^2)^p_.] :=
  u*(b*Sin[v]^2+a*Cos[v]^2)^p /;
IntegersQ[m,p] && m+2*p==0

(* Basis: (a+b*Cot[z])/Csc[z] == a*Sin[z] + b*Cos[z] *)
TrigSimplifyAux[u_*csc[v_]^m_.*(a_.+b_.*cot[v_]^2)^p_.] :=
  u*(b*Cos[v]^2+a*Sin[v]^2)^p /;
IntegersQ[m,p] && m+2*p==0 *)


(* (* Basis: If n is an integer, Sin[z]^(-n)*(a*Cos[z]^n+b*Sin[z]^n) == b+a*Cot[z]^n *)
TrigSimplifyAux[sin[v_]^m_.*(a_.*cos[v_]^n_.+b_.*sin[v_]^n_.)^p_] :=
  (b+a*Cot[v]^n)^p /;
IntegersQ[m,n,p] && n>0 && p<0 && m==-n*p

(* Basis: If n is an integer, Cos[z]^(-n)*(a*Cos[z]^n+b*Sin[z]^n) == a+b*Tan[z]^n *)
TrigSimplifyAux[cos[v_]^m_.*(a_.*cos[v_]^n_.+b_.*sin[v_]^n_.)^p_] :=
  (a+b*Tan[v]^n)^p /;
IntegersQ[m,n,p] && n>0 && p<0 && m==-n*p *)


(* (* Basis: If a^2+b^2=0, 1/(a*Cos[z] + b*Sin[z]) == Cos[z]/a + Sin[z]/b *)
TrigSimplifyAux[(a_.*cos[v_]+b_.*sin[v_])^n_] :=
  (Cos[v]/a + Sin[v]/b)^(-n) /;
IntegerQ[n] && n<0 && ZeroQ[a^2+b^2] *)


TrigSimplifyAux[u_] := u


(* RemoveContent[expn,x] returns expn with the factored content free of x removed. *)
RemoveContent[expn_,x_Symbol] :=
  Module[{u=NonfreeFactors[ContentFactor[expn],x]},
  If[SumQ[u] && NegQ[First[u]],
    -u,
  u]]


(* ContentFactor[expn] returns expn with the content of sum factors factored out. *)
(* Basis: a*b+a*c == a*(b+c) *)
ContentFactor[expn_] :=
  TimeConstrained[ContentFactorAux[expn],TimeLimit,expn];

ContentFactorAux[expn_] :=
  If[AtomQ[expn],
    expn,
  If[IntegerPowerQ[expn],
    If[SumQ[expn[[1]]] && NumericFactor[expn[[1,1]]]<0,
      (-1)^expn[[2]] * ContentFactorAux[-expn[[1]]]^expn[[2]],
    ContentFactorAux[expn[[1]]]^expn[[2]]],
  If[ProductQ[expn],
    Module[{num=1,tmp},
    tmp=Map[Function[If[SumQ[#] && NumericFactor[#[[1]]]<0, num=-num; ContentFactorAux[-#], ContentFactorAux[#]]], expn];
    num*UnifyNegativeBaseFactors[tmp]],
  If[SumQ[expn],
    Module[{lst=CommonFactors[Apply[List,expn]]},
    If[lst[[1]]===1 || lst[[1]]===-1,
      expn,
    lst[[1]]*Apply[Plus,Rest[lst]]]],
  expn]]]]


(* UnifyNegativeBaseFactors[u] returns u with factors of the form (-v)^m and v^n where n is an integer replaced with (-1)^n*(-v)^(m+n). *)
(* This should be done automatically by the host CAS! *)
UnifyNegativeBaseFactors[u_.*(-v_)^m_*v_^n_.] :=
  UnifyNegativeBaseFactors[(-1)^n*u*(-v)^(m+n)] /;
IntegerQ[n]

UnifyNegativeBaseFactors[u_] :=
  u


(* If lst is a list of n terms, CommonFactors[lst] returns a n+1-element list whose first
	element is the product of the factors common to all terms of lst, and whose remaining
	elements are quotients of each term divided by the common factor. *)
CommonFactors [lst_] :=
  Module[{lst1,lst2,lst3,lst4,common,base,num},
  lst1=Map[NonabsurdNumberFactors,lst];
  lst2=Map[AbsurdNumberFactors,lst];
  num=Apply[AbsurdNumberGCD,lst2];
  common=num;
  lst2=Map[Function[#/num],lst2];
  While[True,
    lst3=Map[LeadFactor,lst1];
    ( If[Apply[SameQ,lst3],
        common=common*lst3[[1]];
        lst1=Map[RemainingFactors,lst1],
      If[MapAnd[Function[LogQ[#] && IntegerQ[First[#]] && First[#]>0],lst3] &&
           MapAnd[RationalQ,lst4=Map[Function[FullSimplify[#/First[lst3]]],lst3]],
        num=Apply[GCD,lst4];
        common=common*Log[(First[lst3][[1]])^num];
        lst2=Map2[Function[#1*#2/num],lst2,lst4];
        lst1=Map[RemainingFactors,lst1],
      lst4=Map[LeadDegree,lst1];
      If[Apply[SameQ,Map[LeadBase,lst1]] && MapAnd[RationalQ,lst4],
        num=Smallest[lst4];
        base=LeadBase[lst1[[1]]];
        ( If[num!=0,
            common=common*base^num] );
        lst2=Map2[Function[#1*base^(#2-num)],lst2,lst4];
        lst1=Map[RemainingFactors,lst1],
      If[Length[lst1]==2 && ZeroQ[LeadBase[lst1[[1]]]+LeadBase[lst1[[2]]]] && 
         NonzeroQ[lst1[[1]]-1] && IntegerQ[lst4[[1]]] && FractionQ[lst4[[2]]],
        num=Min[lst4];
        base=LeadBase[lst1[[2]]];
        ( If[num!=0,
            common=common*base^num] );
        lst2={lst2[[1]]*(-1)^lst4[[1]],lst2[[2]]};
        lst2=Map2[Function[#1*base^(#2-num)],lst2,lst4];
        lst1=Map[RemainingFactors,lst1],
      If[Length[lst1]==2 && ZeroQ[LeadBase[lst1[[1]]]+LeadBase[lst1[[2]]]] && 
         NonzeroQ[lst1[[2]]-1] && IntegerQ[lst4[[2]]] && FractionQ[lst4[[1]]],
        num=Min[lst4];
        base=LeadBase[lst1[[1]]];
        ( If[num!=0,
            common=common*base^num] );
        lst2={lst2[[1]],lst2[[2]]*(-1)^lst4[[2]]};
        lst2=Map2[Function[#1*base^(#2-num)],lst2,lst4];
        lst1=Map[RemainingFactors,lst1],
      num=MostMainFactorPosition[lst3];
      lst2=ReplacePart[lst2,lst3[[num]]*lst2[[num]],num];      
      lst1=ReplacePart[lst1,RemainingFactors[lst1[[num]]],num]]]]]] );
    If[MapAnd[Function[#===1],lst1],
      Return[Prepend[lst2,common]]]]]


MostMainFactorPosition[lst_List] :=
  Module[{factor=1,num=1,i},
  Do[If[FactorOrder[lst[[i]],factor]>0,factor=lst[[i]];num=i],{i,Length[lst]}];
  num]


FactorOrder[u_,v_] :=
  If[u===1,
    If[v===1,
      0,
    -1],
  If[v===1,
    1,
  Order[u,v]]]


Smallest[num1_,num2_] :=
  If[num1>0,
    If[num2>0,
      Min[num1,num2],
    0],
  If[num2>0,
    0,
  Max[num1,num2]]]

Smallest[lst_List] :=
  Module[{num=lst[[1]]},
  Scan[Function[num=Smallest[num,#]],Rest[lst]];
  num]


(* MonomialFactor[u,x] returns the list {n,v} where x^n*v==u and n is free of x. *)
MonomialFactor[u_,x_Symbol] :=
  If[AtomQ[u],
    If[u===x,
      {1,1},
    {0,u}],
  If[PowerQ[u],
    If[IntegerQ[u[[2]]],
      Module[{lst=MonomialFactor[u[[1]],x]},
      {lst[[1]]*u[[2]],lst[[2]]^u[[2]]}],
    If[u[[1]]===x && FreeQ[u[[2]],x],
      {u[[2]],1},
    {0,u}]],
  If[ProductQ[u],
    Module[{lst1=MonomialFactor[First[u],x],lst2=MonomialFactor[Rest[u],x]},
    {lst1[[1]]+lst2[[1]],lst1[[2]]*lst2[[2]]}],
  If[SumQ[u],
    Module[{lst,deg},
    lst=Map[Function[MonomialFactor[#,x]],Apply[List,u]];
    deg=lst[[1,1]];
    Scan[Function[deg=MinimumDegree[deg,#[[1]]]],Rest[lst]];
    If[ZeroQ[deg] || RationalQ[deg] && deg<0,
      {0,u},
    {deg,Apply[Plus,Map[Function[x^(#[[1]]-deg)*#[[2]]],lst]]}]],    
  {0,u}]]]]


MinimumDegree[deg1_,deg2_] :=
  If[RationalQ[deg1],
    If[RationalQ[deg2],
      Min[deg1,deg2],
    deg1],
  If[RationalQ[deg2],
    deg2,
  Module[{deg=Simplify[deg1-deg2]},
  If[RationalQ[deg],
    If[deg>0,
      deg2,
    deg1],
  If[OrderedQ[{deg1,deg2}],
    deg1,
  deg2]]]]]


(* ConstantFactor[u,x] returns a 2-element list of the factors of u[x] free of x and the 
	factors not free of u[x].  Common constant factors of the terms of sums are also collected. *)
(* Compare with the more passive function SplitFreeFactors. *)
ConstantFactor[u_,x_Symbol] :=
  If[FreeQ[u,x],
    {u,1},
  If[AtomQ[u],
    {1,u},
  If[PowerQ[u] && FreeQ[u[[2]],x],
    Module[{lst=ConstantFactor[u[[1]],x],tmp},
    If[IntegerQ[u[[2]]],
      {lst[[1]]^u[[2]],lst[[2]]^u[[2]]},
    tmp=PositiveFactors[lst[[1]]];
    If[tmp===1,
      {1,u},
    {tmp^u[[2]],(NonpositiveFactors[lst[[1]]]*lst[[2]])^u[[2]]}]]],
  If[ProductQ[u],
    Module[{lst=Map[Function[ConstantFactor[#,x]],Apply[List,u]]},
    {Apply[Times,Map[First,lst]],Apply[Times,Map[Function[#[[2]]],lst]]}],
  If[SumQ[u],
    Module[{lst1=Map[Function[ConstantFactor[#,x]],Apply[List,u]]},
    If[Apply[SameQ,Map[Function[#[[2]]],lst1]],
      {Apply[Plus,Map[First,lst1]],lst1[[1,2]]},
    Module[{lst2=CommonFactors[Map[First,lst1]]},
    {First[lst2],Apply[Plus,Map2[Times,Rest[lst2],Map[Function[#[[2]]],lst1]]]}]]],
  {1,u}]]]]]


(* PositiveFactors[u] returns the positive factors of u *)
PositiveFactors[u_] :=
  If[ZeroQ[u],
    1,
  If[RationalQ[u],
    Abs[u],
  If[PositiveQ[u],
    u,
  If[ProductQ[u],
    Map[PositiveFactors,u],
  1]]]]


(* NonpositiveFactors[u] returns the nonpositive factors of u *)
NonpositiveFactors[u_] :=
  If[ZeroQ[u],
    u,
  If[RationalQ[u],
    Sign[u],
  If[PositiveQ[u],
    1,
  If[ProductQ[u],
    Map[NonpositiveFactors,u],
  u]]]]


PolynomialInQ[u_,v_,x_Symbol] :=
  PolynomialInAuxQ[u,NonfreeFactors[NonfreeTerms[v,x],x],x]


PolynomialInAuxQ[u_,v_,x_] :=
  If[u===v,
    True,
  If[AtomQ[u],
    u=!=x,
  If[PowerQ[u],
    If[PowerQ[v] && u[[1]]===v[[1]],
      PositiveIntegerQ[u[[2]]/v[[2]]],
    PositiveIntegerQ[u[[2]]] && PolynomialInAuxQ[u[[1]],v,x]],
  If[SumQ[u] || ProductQ[u],
    Catch[Scan[Function[If[Not[PolynomialInAuxQ[#,v,x]],Throw[False]]],u];True],
  False]]]]


ExponentIn[u_,v_,x_Symbol] :=
  ExponentInAux[u,NonfreeFactors[NonfreeTerms[v,x],x],x]


ExponentInAux[u_,v_,x_] :=
  If[u===v,
    1,
  If[AtomQ[u],
    0,
  If[PowerQ[u],
    If[PowerQ[v] && u[[1]]===v[[1]],
      u[[2]]/v[[2]],
    u[[2]]*ExponentInAux[u[[1]],v,x]],
  If[ProductQ[u],
    Apply[Plus,Map[Function[ExponentInAux[#,v,x]],Apply[List,u]]],
  Apply[Max,Map[Function[ExponentInAux[#,v,x]],Apply[List,u]]]]]]]


PolynomialInSubst[u_,v_,x_Symbol] :=
  Module[{w=NonfreeTerms[v,x]},
  ReplaceAll[PolynomialInSubstAux[u,NonfreeFactors[w,x],x],{x->(x-FreeTerms[v,x])/FreeFactors[w,x]}]]


PolynomialInSubstAux[u_,v_,x_] :=
  If[u===v,
    x,
  If[AtomQ[u],
    u,
  If[PowerQ[u],
    If[PowerQ[v] && u[[1]]===v[[1]],
      x^(u[[2]]/v[[2]]),
    PolynomialInSubstAux[u[[1]],v,x]^u[[2]]],
  Map[Function[PolynomialInSubstAux[#,v,x]],u]]]]


PolynomialDivide[u_,v_,x_Symbol] :=
  Module[{quo=PolynomialQuotient[u,v,x],rem=PolynomialRemainder[u,v,x],free,monomial},
  quo=Apply[Plus,Map[Function[Simp[Together[Coefficient[quo,x,#]*x^#],x]],Exponent[quo,x,List]]];
  rem=Together[rem];
  free=FreeFactors[rem,x];
  rem=NonfreeFactors[rem,x];
  monomial=x^Exponent[rem,x,Min];
  If[NegQ[Coefficient[rem,x,0]], monomial=-monomial];
  rem=Apply[Plus,Map[Function[Simp[Together[Coefficient[rem,x,#]*x^#/monomial],x]],Exponent[rem,x,List]]];
(*rem=Simplify[rem]; *)
  If[BinomialQ[v,x],
    quo+free*monomial*rem/ExpandToSum[v,x],
  quo+free*monomial*rem/v]]


PolynomialDivide[u_,v_,w_,x_Symbol] :=
  ReplaceAll[PolynomialDivide[PolynomialInSubst[u,w,x],PolynomialInSubst[v,w,x],x],{x->w}]


ExpandToSum[u_,v_,x_Symbol] :=
  Module[{w=ExpandToSum[v,x]},
  If[SumQ[w],
    Map[Function[u*#],w],
  u*w]]


ExpandToSum[u_,x_Symbol] :=
  If[PolynomialQ[u,x],
    Apply[Plus,Map[Function[Coefficient[u,x,#]*x^#], Exponent[u,x,List]]],
  If[BinomialQ[u,x],
    Function[#[[1]] + #[[2]]*x^#[[3]]][BinomialTest[u,x]],
  If[TrinomialQ[u,x],
    Function[#[[1]] + #[[2]]*x^#[[4]] + #[[3]]*x^(2*#[[4]])][TrinomialTest[u,x]],
  If[GeneralizedBinomialQ[u,x],
    Function[#[[1]]*x^#[[4]] + #[[2]]*x^#[[3]]][GeneralizedBinomialTest[u,x]],
  If[GeneralizedTrinomialQ[u,x],
    Function[#[[1]]*x^#[[5]] + #[[2]]*x^#[[4]] + #[[3]]*x^(2*#[[4]]-#[[5]])][GeneralizedTrinomialTest[u,x]],
  Print["Warning: Unrecogized expression for expansion ",u];
  Expand[u,x]]]]]]


ExpandTrig[u_,x_Symbol] :=
  ActivateTrig[ExpandIntegrand[u,x]]

ExpandTrig[u_,v_,x_Symbol] :=
  Module[{w=ExpandTrig[v,x],z=ActivateTrig[u]},
  If[SumQ[w],
    Map[Function[z*#],w],
  z*w]]


Clear[ExpandIntegrand];

ExpandIntegrand[u_,v_,x_Symbol] :=
  Module[{w=ExpandIntegrand[v,x]},
  If[SumQ[w],
    Map[Function[u*#],w],
  u*w]]


(* ExpandIntegrand[u_,x_Symbol] :=
  Module[{nn=FunctionOfPower[u,x]},
  ReplaceAll[ExpandIntegrand[SubstFor[x^nn,u,x],x],x->x^nn] /;
 nn!=1] *)


ExpandIntegrand[(a_.+b_.*x_)^m_.*f_^(e_.*(c_.+d_.*x_)^n_.)/(g_.+h_.*x_),x_Symbol] :=
  Module[{tmp=a*h-b*g},
  SimplifyTerm[tmp^m/h^m,x]*f^(e*(c+d*x)^n)/(g+h*x) + 
	Sum[SimplifyTerm[b*tmp^(k-1)/h^k,x]*f^(e*(c+d*x)^n)*(a+b*x)^(m-k),{k,1,m}]] /;
FreeQ[{a,b,c,d,e,f,g,h},x] && PositiveIntegerQ[m] && ZeroQ[b*c-a*d]


ExpandIntegrand[x_^m_.*(e_+f_.*x_)^p_.*F_^(b_.*(c_.+d_.*x_)^n_.),x_Symbol] :=
  If[PositiveIntegerQ[m,p] && m<=p && (OneQ[n] || ZeroQ[d*e-c*f]),
    ExpandLinearProduct[(e+f*x)^p*F^(b*(c+d*x)^n),x^m,e,f,x],
  If[PositiveIntegerQ[p],
    Distribute[x^m*F^(b*(c+d*x)^n)*Expand[(e+f*x)^p,x],Plus,Times],
  Distribute[F^(b*(c+d*x)^n)*ExpandIntegrand[x^m*(e+f*x)^p,x],Plus,Times]]] /;
FreeQ[{F,b,c,d,e,f,m,n,p},x]


ExpandIntegrand[x_^m_.*(e_+f_.*x_)^p_.*F_^(a_.+b_.*(c_.+d_.*x_)^n_.),x_Symbol] :=
  If[PositiveIntegerQ[m,p] && m<=p && (OneQ[n] || ZeroQ[d*e-c*f]),
    ExpandLinearProduct[(e+f*x)^p*F^(a+b*(c+d*x)^n),x^m,e,f,x],
  If[PositiveIntegerQ[p],
    Distribute[x^m*F^(a+b*(c+d*x)^n)*Expand[(e+f*x)^p,x],Plus,Times],
  Distribute[F^(a+b*(c+d*x)^n)*ExpandIntegrand[x^m*(e+f*x)^p,x],Plus,Times]]] /;
FreeQ[{F,a,b,c,d,e,f,m,n,p},x]


ExpandIntegrand[u_*(a_.+b_.*x_)^m_.*f_^(e_.*(c_.+d_.*x_)^n_.),x_Symbol] :=
  Module[{v=ExpandIntegrand[u*(a+b*x)^m,x]},
  Distribute[f^(e*(c+d*x)^n)*v,Plus,Times] /;
 SumQ[v]] /;
FreeQ[{a,b,c,d,e,f,m,n},x] && PolynomialQ[u,x]


ExpandIntegrand[u_*(a_.+b_.*x_)^m_.*Log[c_.*(d_.+e_.*x_^n_.)^p_.],x_Symbol] :=
  Distribute[Log[c*(d+e*x^n)^p]*ExpandIntegrand[u*(a+b*x)^m,x],Plus,Times] /; 
FreeQ[{a,b,c,d,e,m,n,p},x] && PolynomialQ[u,x]


ExpandIntegrand[u_*f_^(e_.*(c_.+d_.*x_)^n_.),x_Symbol] :=
  If[OneQ[n],
    ExpandIntegrand[f^(e*(c+d*x)^n),u,x],
  ExpandLinearProduct[f^(e*(c+d*x)^n),u,c,d,x]] /;
FreeQ[{c,d,e,f,n},x] && PolynomialQ[u,x]


ExpandIntegrand[F_[u_]^m_.*(a_+b_.*G_[u_])^n_.,x_Symbol] :=
  ReplaceAll[ExpandIntegrand[(a+b*x)^n/x^m,x],x->G[u]] /;
FreeQ[{a,b},x] && IntegersQ[m,n] && F[u]*G[u]===1


ExpandIntegrand[u_*(a_.+b_.*Log[c_.*(d_.+e_.*x_)^n_.])^p_,x_Symbol] :=
  ExpandLinearProduct[(a+b*Log[c*(d+e*x)^n])^p,u,d,e,x] /;
FreeQ[{a,b,c,d,e,n,p},x] && PolynomialQ[u,x]


ExpandIntegrand[u_*(a_.+b_.*F_[c_.+d_.*x_])^n_,x_Symbol] :=
  ExpandLinearProduct[(a+b*F[c+d*x])^n,u,c,d,x] /;
FreeQ[{a,b,c,d,n},x] && PolynomialQ[u,x] && MemberQ[{ArcSin,ArcCos,ArcSinh,ArcCosh},F]


(* ExpandIntegrand[u_.*x_^m_.*(v_+a_.*x_^n_.)^p_,x_Symbol] :=
  Distribute[(v+a*x^n)^p*ExpandIntegrand[u*x^m,x],Plus,Times] /;
FreeQ[a,x] && IntegersQ[m,n] && 0<n<=m && Not[IntegerQ[p]] && Not[LinearQ[v+a*x^n,x]] *)


ExpandIntegrand[u_.*v_^p_,x_Symbol] :=
  Distribute[NormalizeIntegrand[v^p,x]*ExpandIntegrand[u,x],Plus,Times] /;
Not[IntegerQ[p]] && Not[LinearQ[v,x]]


ExpandIntegrand[u_./(a_.*x_^n_+b_.*Sqrt[c_+d_.*x_^j_]),x_Symbol] :=
  ExpandIntegrand[u*(a*x^n-b*Sqrt[c+d*x^(2*n)])/(-b^2*c+(a^2-b^2*d)*x^(2*n)),x] /;
FreeQ[{a,b,c,d,n},x] && ZeroQ[j-2*n]


ExpandIntegrand[(a_+b_.*x_)^m_/(c_+d_.*x_),x_Symbol] :=
  If[RationalQ[a,b,c,d],
    ExpandExpression[(a+b*x)^m/(c+d*x),x],
  Module[{tmp=a*d-b*c},
  SimplifyTerm[tmp^m/d^m,x]/(c+d*x) + Sum[SimplifyTerm[b*tmp^(k-1)/d^k,x]*(a+b*x)^(m-k),{k,1,m}]]] /;
FreeQ[{a,b,c,d},x] && PositiveIntegerQ[m]


ExpandIntegrand[(a_+b_.*x_)^m_.*(A_+B_.*x_)/(c_+d_.*x_),x_Symbol] :=
  If[RationalQ[a,b,c,d,A,B],
    ExpandExpression[(a+b*x)^m*(A+B*x)/(c+d*x),x],
  Module[{tmp1,tmp2},
  tmp1=(A*d-B*c)/d;
  tmp2=ExpandIntegrand[(a+b*x)^m/(c+d*x),x];
  tmp2=If[SumQ[tmp2], Map[Function[SimplifyTerm[tmp1*#,x]],tmp2], SimplifyTerm[tmp1*tmp2,x]];
  SimplifyTerm[B/d,x]*(a+b*x)^m + tmp2]] /;
FreeQ[{a,b,c,d,A,B},x] && PositiveIntegerQ[m]


(* If u is a polynomial in x, ExpandIntegrand[u*(a+b*x)^m,x] expand u*(a+b*x)^m into a sum of terms of the form A*(a+b*x)^n. *)
ExpandIntegrand[u_*(a_.+b_.*x_)^m_,x_Symbol] :=
  Module[{tmp1,tmp2},
  tmp1=ExpandLinearProduct[(a+b*x)^m,u,a,b,x];
  If[Not[IntegerQ[m]],
    tmp1,
  tmp2=ExpandExpression[u*(a+b*x)^m,x];
  If[SumQ[tmp2] && LeafCount[tmp2]<=LeafCount[tmp1]+2,
    tmp2,
  tmp1]]] /;
FreeQ[{a,b,m},x] && PolynomialQ[u,x] && 
  Not[PositiveIntegerQ[m] && MatchQ[u,v_.*(c_+d_.*x)^n_ /; FreeQ[{c,d},x] && IntegerQ[n] && n>m]]


ExpandIntegrand[1/(a_+b_.*u_^n_),x_Symbol] :=
  Module[{r=Numerator[Rt[-a/b,n]],s=Denominator[Rt[-a/b,n]]},
  Sum[r/(a*n*(r-(-1)^(2*k/n)*s*u)),{k,1,n}]] /;
FreeQ[{a,b},x] && IntegerQ[n] && n>1


ExpandIntegrand[u_^m_./(a_+b_.*u_^n_),x_Symbol] :=
  Module[{g=GCD[m,n],r=Numerator[Rt[a/b,n/GCD[m,n]]],s=Denominator[Rt[a/b,n/GCD[m,n]]]},
  If[CoprimeQ[m+g,n],
    Sum[r*(-r/s)^(m/g)*(-1)^(-2*k*m/n)/(a*n*(r+(-1)^(2*k*g/n)*s*u^g)),{k,1,n/g}],
  Sum[r*(-r/s)^(m/g)*(-1)^(2*k*(m+g)/n)/(a*n*((-1)^(2*k*g/n)*r+s*u^g)),{k,1,n/g}]]] /;
FreeQ[{a,b},x] && IntegersQ[m,n] && 0<m<n && OddQ[n/GCD[m,n]] && PosQ[a/b]


ExpandIntegrand[u_^m_./(a_+b_.*u_^n_),x_Symbol] :=
  Module[{g=GCD[m,n],r=Numerator[Rt[-a/b,n/GCD[m,n]]],s=Denominator[Rt[-a/b,n/GCD[m,n]]]},
  If[n/g==2,
    s/(2*b*(r+s*u^g)) - s/(2*b*(r-s*u^g)),
  If[CoprimeQ[m+g,n],
    Sum[r*(r/s)^(m/g)*(-1)^(-2*k*m/n)/(a*n*(r-(-1)^(2*k*g/n)*s*u^g)),{k,1,n/g}],
  Sum[r*(r/s)^(m/g)*(-1)^(2*k*(m+g)/n)/(a*n*((-1)^(2*k*g/n)*r-s*u^g)),{k,1,n/g}]]]] /;
FreeQ[{a,b},x] && IntegersQ[m,n] && 0<m<n


ExpandIntegrand[(c_+d_.*u_^m_.)/(a_+b_.*u_^n_),x_Symbol] :=
  Module[{r=Numerator[Rt[-a/b,n]],s=Denominator[Rt[-a/b,n]]},
  Sum[(r*c+r*d*(r/s)^m*(-1)^(-2*k*m/n))/(a*n*(r-(-1)^(2*k/n)*s*u)),{k,1,n}]] /;
FreeQ[{a,b,c,d},x] && IntegersQ[m,n] && 0<m<n


ExpandIntegrand[(c_.+d_.*u_^m_.+e_.*u_^p_)/(a_+b_.*u_^n_),x_Symbol] :=
  Module[{r=Numerator[Rt[-a/b,n]],s=Denominator[Rt[-a/b,n]]},
  Sum[(r*c+r*d*(r/s)^m*(-1)^(-2*k*m/n)+r*e*(r/s)^p*(-1)^(-2*k*p/n))/(a*n*(r-(-1)^(2*k/n)*s*u)),{k,1,n}]] /;
FreeQ[{a,b,c,d,e},x] && IntegersQ[m,n,p] && 0<m<p<n


ExpandIntegrand[(c_.+d_.*u_^m_.+e_.*u_^p_+f_.*u_^q_)/(a_+b_.*u_^n_),x_Symbol] :=
  Module[{r=Numerator[Rt[-a/b,n]],s=Denominator[Rt[-a/b,n]]},
  Sum[(r*c+r*d*(r/s)^m*(-1)^(-2*k*m/n)+r*e*(r/s)^p*(-1)^(-2*k*p/n)+r*f*(r/s)^q*(-1)^(-2*k*q/n))/(a*n*(r-(-1)^(2*k/n)*s*u)),{k,1,n}]] /;
FreeQ[{a,b,c,d,e,f},x] && IntegersQ[m,n,p,q] && 0<m<p<q<n


ExpandIntegrand[1/(a_.+b_.*u_^n_.+c_.*u_^j_.),x_Symbol] :=
  Module[{q=Rt[b^2-4*a*c,2]},
  2*c/(q*(b-q+2*c*u^n)) - 2*c/(q*(b+q+2*c*u^n))] /;
FreeQ[{a,b,c,n},x] && ZeroQ[j-2*n] && NonzeroQ[b^2-4*a*c]


ExpandIntegrand[u_^m_./(a_.+b_.*u_^n_.+c_.*u_^j_.),x_Symbol] :=
  Module[{q=Rt[b^2-4*a*c,2]},
  2*c*u^m/(q*(b-q+2*c*u^n)) - 2*c*u^m/(q*(b+q+2*c*u^n))] /;
FreeQ[{a,b,c},x] && IntegersQ[m,n,j] && j==2*n && 0<m<2*n && m!=n && NonzeroQ[b^2-4*a*c]


ExpandIntegrand[(c_.+d_.*u_^n_.)/(a_+b_.*u_^j_.),x_Symbol] :=
  Module[{q=Rt[-a/b,2]},
  -(c-d*q)/(2*b*q*(q+u^n)) - (c+d*q)/(2*b*q*(q-u^n))] /;
FreeQ[{a,b,c,d,n},x] && ZeroQ[j-2*n]


ExpandIntegrand[(d_.+e_.*u_^n_.)/(a_.+b_.*u_^n_.+c_.*u_^j_.),x_Symbol] :=
  Module[{q=Rt[b^2-4*a*c,2],r},
  r=TogetherSimplify[(2*c*d-b*e)/q];
  (e+r)/(b-q+2*c*u^n) + (e-r)/(b+q+2*c*u^n)] /;
FreeQ[{a,b,c,d,e,n},x] && ZeroQ[j-2*n] && NonzeroQ[b^2-4*a*c]


ExpandIntegrand[u_/v_,x_Symbol] :=
  Module[{lst=CoefficientList[u,x]},
  lst[[-1]]*x^Exponent[u,x]/v + Sum[lst[[i]]*x^(i-1),{i,1,Exponent[u,x]}]/v] /;
PolynomialQ[u,x] && PolynomialQ[v,x] && BinomialQ[v,x] && Exponent[u,x]==Exponent[v,x]-1>=2


ExpandIntegrand[u_/v_,x_Symbol] :=
  PolynomialDivide[u,v,x] /;
PolynomialQ[u,x] && PolynomialQ[v,x] && Exponent[u,x]>=Exponent[v,x]


ExpandIntegrand[u_,x_Symbol] :=
  ExpandExpression[u,x]


ExpandExpression[u_,x_Symbol] :=
  Module[{v,w},
  v=If[AlgebraicFunctionQ[u,x] && Not[RationalFunctionQ[u,x]], ExpandAlgebraicFunction[u,x], 0];
  If[SumQ[v],
    ExpandCleanup[v,x],
  v=SmartApart[u,x];
  If[SumQ[v],
    ExpandCleanup[v,x],
  v=SmartApart[RationalFunctionFactors[u,x],x,x];
  If[SumQ[v],
    w=NonrationalFunctionFactors[u,x];
    ExpandCleanup[Map[Function[#*w],v],x],
  v=Expand[u,x];
  If[SumQ[v],
    ExpandCleanup[v,x],
  v=Expand[u];
  If[SumQ[v],
    ExpandCleanup[v,x],
  SimplifyTerm[u,x]]]]]]]


ExpandCleanup[u_,x_Symbol] :=
  Module[{v},
  v=CollectReciprocals[u,x];
  If[SumQ[v],
    v=Map[Function[SimplifyTerm[#,x]],v];
    If[SumQ[v],
      UnifySum[v,x],
    v],
  v]]


CollectReciprocals[u_.+e_/(a_+b_.*x_)+f_/(c_+d_.*x_),x_Symbol] :=
  CollectReciprocals[u+(c*e+a*f)/(a*c+b*d*x^2),x] /;
FreeQ[{a,b,c,d,e,f},x] && ZeroQ[b*c+a*d] && ZeroQ[d*e+b*f] 

CollectReciprocals[u_.+e_/(a_+b_.*x_)+f_/(c_+d_.*x_),x_Symbol] :=
  CollectReciprocals[u+(d*e+b*f)*x/(a*c+b*d*x^2),x] /;
FreeQ[{a,b,c,d,e,f},x] && ZeroQ[b*c+a*d] && ZeroQ[c*e+a*f]

CollectReciprocals[u_,x_Symbol] := u


(* SmartApart[u,x] returns the partial fraction expansion of u wrt x, avoiding the 
	strange behavior in the built-in Apart function that rationalizes denominators 
    involving fractional powers resulting in hard to integrate expressions. *)
SmartApart[u_,x_Symbol] :=
  Module[{alst=MakeAssocList[u,x]},
  KernelSubst[Apart[GensymSubst[u,x,alst]],x,alst]]

SmartApart[u_,v_,x_Symbol] :=
  Module[{alst=MakeAssocList[u,x]},
  KernelSubst[Apart[GensymSubst[u,x,alst],v],x,alst]]


(* MakeAssocList[u,x,alst] returns an association list of gensymed symbols with the nonatomic 
  parameters of a u that are not integer powers, products or sums. *)
MakeAssocList[u_,x_Symbol,alst_List:{}] :=
  If[AtomQ[u],
    alst,
  If[IntegerPowerQ[u],
    MakeAssocList[u[[1]],x,alst],
  If[ProductQ[u] || SumQ[u],
    MakeAssocList[Rest[u],x,MakeAssocList[First[u],x,alst]],
  If[FreeQ[u,x],
    Module[{tmp=Select[alst,Function[#[[2]]===u],1]},
    If[tmp==={},
      Append[alst,{Unique["Rubi"],u}],
    alst]],
  alst]]]]


(* GensymSubst[u,x,alst] returns u with the kernels in alst free of x replaced by gensymed names. *)
GensymSubst[u_,x_Symbol,alst_List] :=
  If[AtomQ[u],
    u,
  If[IntegerPowerQ[u],
    GensymSubst[u[[1]],x,alst]^u[[2]],
  If[ProductQ[u] || SumQ[u],
    Map[Function[GensymSubst[#,x,alst]],u],
  If[FreeQ[u,x],
    Module[{tmp=Select[alst,Function[#[[2]]===u],1]},
    If[tmp==={},
      u,
    tmp[[1,1]]]],
  u]]]]


(* KernelSubst[u,x,alst] returns u with the gensymed names in alst freplaced by kernels free of x. *)
KernelSubst[u_,x_Symbol,alst_List] :=
  If[AtomQ[u],
    Module[{tmp=Select[alst,Function[#[[1]]===u],1]},
    If[tmp==={},
      u,
    tmp[[1,2]]]],
  If[IntegerPowerQ[u],
    KernelSubst[u[[1]],x,alst]^u[[2]],
  If[ProductQ[u] || SumQ[u],
    Map[Function[KernelSubst[#,x,alst]],u],
  u]]]


ExpandAlgebraicFunction[u_Plus*v_,x_Symbol] :=
  Map[Function[#*v],u] /;
Not[FreeQ[u,x]]

ExpandAlgebraicFunction[u_Plus^n_*v_.,x_Symbol] :=
  Module[{w=Expand[u^n,x]},
  Map[Function[#*v],w] /;
 SumQ[w]] /;
PositiveIntegerQ[n] && Not[FreeQ[u,x]]


(* UnifySum[u,x] returns u with terms having indentical nonfree factors of x collected into a single term. *)  
UnifySum[u_,x_Symbol] :=
  If[SumQ[u],
    Apply[Plus,UnifyTerms[Apply[List,u],x]],  
  SimplifyTerm[u,x]]


(* lst is a list of terms. *)
(* UnifyTerms[lst,x] returns lst with terms collected into a single element. *)  
UnifyTerms[lst_,x_] :=
  If[lst==={},
    lst,
  UnifyTerm[First[lst],UnifyTerms[Rest[lst],x],x]]


UnifyTerm[term_,lst_,x_] :=
  If[lst==={},
    {term},
  Module[{tmp=Simplify[First[lst]/term]},
  If[FreeQ[tmp,x],
    Prepend[Rest[lst],(1+tmp)*term],
  Prepend[UnifyTerm[term,Rest[lst],x],First[lst]]]]]


(* If u is a polynomial in x, ExpandLinearProduct[v,u,a,b,x] expands v*u into a sum of terms of the form c*v*(a+b*x)^n. *)
ExpandLinearProduct[v_,u_,a_,b_,x_Symbol] :=
  Module[{lst},
  lst=CoefficientList[ReplaceAll[u,x->(x-a)/b],x];
  lst=Map[Function[SimplifyTerm[#,x]],lst];
  Sum[v*lst[[k]]*(a+b*x)^(k-1),{k,1,Length[lst]}]] /;
FreeQ[{a,b},x] && PolynomialQ[u,x]


ExpandTrigReduce[u_,v_,x_Symbol] :=
  Module[{w=ExpandTrigReduce[v,x]},
  If[SumQ[w],
    Map[Function[u*#],w],
  u*w]]


(* This is necessary, because TrigReduce expands Sinh[n+v] and Cosh[n+v] to exponential form if n is a number. *)
ExpandTrigReduce[u_.*F_[n_+v_.]^m_.,x_Symbol] :=
  Module[{nn},
  ExpandTrigReduce[u*F[nn+v]^m,x] /. nn->n]/;
MemberQ[{Sinh,Cosh},F] && IntegerQ[m] && RationalQ[n]

ExpandTrigReduce[u_,x_Symbol] :=
  ExpandTrigReduceAux[u,x]


ExpandTrigReduceAux[u_,x_Symbol] :=
  Module[{v=Expand[TrigReduce[u]]},
  If[SumQ[v],
    Map[Function[NormalizeTrig[#,x]],v],
  NormalizeTrig[v,x]]]


NormalizeTrig[a_.*F_[u_]^n_.,x_Symbol] :=
  a*F[ExpandToSum[u,x]]^n /;
FreeQ[{F,a,n},x] && PolynomialQ[u,x] && Exponent[u,x]>0

NormalizeTrig[u_,x_Symbol] := u


ExpandTrigToExp[u_,v_,x_Symbol] :=
  Module[{w=Expand[TrigToExp[v]]},
  If[SumQ[w],
    Map[Function[SimplifyIntegrand[u*#,x]],w],
  SimplifyIntegrand[u*w,x]]]


ExpandTrigToExp[u_,x_Symbol] :=
  Module[{w=Expand[TrigToExp[u]]},
  If[SumQ[w],
    Map[Function[SimplifyIntegrand[#,x]],w],
  SimplifyIntegrand[w,x]]]


(* Distrib[u,v] returns the sum of u times each term of v. *)
Distrib[u_,v_] :=
  If[SumQ[v],
    Map[Function[u*#],v],
  u*v]


(* Dist[u,v] returns the sum of u times each term of v, provided v is free of Int. *)
DownValues[Dist]={};
UpValues[Dist]={};

Dist /: Dist[u_,v_,x_]+Dist[w_,v_,x_] := 
  If[ZeroQ[u+w],
    0,
  Dist[u+w,v,x]]

Dist /: Dist[u_,v_,x_]-Dist[w_,v_,x_] := 
  If[ZeroQ[u-w],
    0,
  Dist[u-w,v,x]]

Dist /: w_*Dist[u_,v_,x_] := 
  Dist[w*u,v,x] /; 
w=!=-1

Dist[u_,Defer[Dist][v_,w_,x_],x_] := 
  Dist[u*v,w,x]

Dist[u_,v_*w_,x_] := 
  Dist[u*v,w,x] /;
ShowSteps===True && FreeQ[v,Int] && Not[FreeQ[w,Int]]

Dist[u_,v_,x_] := 
  If[u===1,
    v,
  If[u===0,
    Print["*** Warning ***:  Dist[0,",v," ",x,"]"];
    0,
  If[NumericFactor[u]<0 && NumericFactor[-u]>0,
    -Dist[-u,v,x],
  If[SumQ[v],
    Map[Function[Dist[u,#,x]],v],
  If[FreeQ[v,Int],
(*  Simp[Simp[u,x]*v,x], *)
    Simp[u*v,x],
(*If[ShowSteps=!=True,
    Simp[u*v,x],
  Module[{w=Simp[u,x]},
  If[w=!=u,
    Dist[w,v,x], *)
  Module[{w=Simp[u*x^2,x]/x^2},
  If[w=!=u && FreeQ[w,x] && w===Simp[w,x],
    Dist[w,v,x],
  If[ShowSteps=!=True,
    Simp[u*v,x],
  Defer[Dist][u,v,x]]]]]]]]]


(* FunctionOfPower[u,x] returns the gcd of the integer degrees of x in u. *)
(* FunctionOfPower[u_,x_Symbol] :=
  FunctionOfPower[u,Null,x]

FunctionOfPower[u_,n_,x_] :=
  If[FreeQ[u,x],
    n,
  If[u===x,
    1,
  If[PowerQ[u] && u[[1]]===x && IntegerQ[u[[2]]],
    If[n===Null,
      u[[2]],
    GCD[n,u[[2]]]],
  Module[{tmp=n},
    Scan[Function[tmp=FunctionOfPower[#,tmp,x]],u];
    tmp]]]] *)


(* If u (x) is equivalent to an expression of the form f (a+b*x) and not the case that a==0 and
	b==1, FunctionOfLinear[u,x] returns the list {f (x),a,b}; else it returns False. *)
FunctionOfLinear[u_,x_Symbol] :=
  Module[{lst=FunctionOfLinear[u,False,False,x,False]},
  If[FalseQ[lst] || FalseQ[lst[[1]]] || lst[[1]]===0 && lst[[2]]===1,
    False,
  {FunctionOfLinearSubst[u,lst[[1]],lst[[2]],x],lst[[1]],lst[[2]]}]]


FunctionOfLinear[u_,a_,b_,x_,flag_] :=
  If[FreeQ[u,x],
    {a,b},
  If[CalculusQ[u],
    False,
  If[LinearQ[u,x],
    If[FalseQ[a],
      {Coefficient[u,x,0],Coefficient[u,x,1]},
    Module[{lst=CommonFactors[{b,Coefficient[u,x,1]}]},
    If[ZeroQ[Coefficient[u,x,0]] && Not[flag],
      {0,lst[[1]]},
    If[ZeroQ[b*Coefficient[u,x,0]-a*Coefficient[u,x,1]],
      {a/lst[[2]],lst[[1]]},
    {0,1}]]]],
  If[PowerQ[u] && FreeQ[u[[1]],x],
    FunctionOfLinear[Log[u[[1]]]*u[[2]],a,b,x,False],
  Module[{lst},
  If[ProductQ[u] && NonzeroQ[(lst=MonomialFactor[u,x])[[1]]],
    If[False && IntegerQ[lst[[1]]] && lst[[1]]!=-1 && FreeQ[lst[[2]],x],
      If[RationalQ[LeadFactor[lst[[2]]]] && LeadFactor[lst[[2]]]<0,
        FunctionOfLinear[DivideDegreesOfFactors[-lst[[2]],lst[[1]]]*x,a,b,x,False],
      FunctionOfLinear[DivideDegreesOfFactors[lst[[2]],lst[[1]]]*x,a,b,x,False]],
    False],
  lst={a,b};
  Catch[
  Scan[Function[lst=FunctionOfLinear[#,lst[[1]],lst[[2]],x,SumQ[u]];
			If[FalseQ[lst],Throw[False]]],u];
  lst]]]]]]]


FunctionOfLinearSubst[u_,a_,b_,x_] :=
  If[FreeQ[u,x],
    u,
  If[LinearQ[u,x],
    Module[{tmp=Coefficient[u,x,1]},
    tmp=If[tmp===b, 1, tmp/b];
    Coefficient[u,x,0]-a*tmp+tmp*x],
  If[PowerQ[u] && FreeQ[u[[1]],x],
    E^FullSimplify[FunctionOfLinearSubst[Log[u[[1]]]*u[[2]],a,b,x]],
  Module[{lst},
  If[ProductQ[u] && NonzeroQ[(lst=MonomialFactor[u,x])[[1]]],
    If[RationalQ[LeadFactor[lst[[2]]]] && LeadFactor[lst[[2]]]<0,
      -FunctionOfLinearSubst[DivideDegreesOfFactors[-lst[[2]],lst[[1]]]*x,a,b,x]^lst[[1]],
    FunctionOfLinearSubst[DivideDegreesOfFactors[lst[[2]],lst[[1]]]*x,a,b,x]^lst[[1]]],
  Map[Function[FunctionOfLinearSubst[#,a,b,x]],u]]]]]]


(* DivideDegreesOfFactors[u,n] returns the product of the base of the factors of u raised to
	the degree of the factors divided by n. *)
DivideDegreesOfFactors[u_,n_] :=
  If[ProductQ[u],
    Map[Function[LeadBase[#]^(LeadDegree[#]/n)],u],
  LeadBase[u]^(LeadDegree[u]/n)]


(* If u is a function of an inverse linear binomial of the form 1/(a+b*x), 
	FunctionOfInverseLinear[u,x] returns the list {a,b}; else it returns False. *)
FunctionOfInverseLinear[u_,x_Symbol] :=
  FunctionOfInverseLinear[u,Null,x]

FunctionOfInverseLinear[u_,lst_,x_] :=
  If[FreeQ[u,x],
    lst,
  If[u===x,
    False,
  If[QuotientOfLinearsQ[u,x],
    Module[{tmp=Drop[QuotientOfLinearsParts[u,x],2]},
    If[tmp[[2]]===0,
      False,
    If[lst===Null,
      tmp,
    If[ZeroQ[lst[[1]]*tmp[[2]]-lst[[2]]*tmp[[1]]],
      lst,
    False]]]],
  If[CalculusQ[u],
    False,
  Module[{tmp=lst},Catch[
  Scan[Function[If[FalseQ[tmp=FunctionOfInverseLinear[#,tmp,x]],Throw[False]]],u];
  tmp]]]]]]


(* FunctionOfExponentialQ[u,x] returns True iff u is a function of F^v where F is a constant and v is linear in x, *)
(* and such an exponential explicitly occurs in u (i.e. not just implicitly in hyperbolic functions). *) 
FunctionOfExponentialQ[u_,x_Symbol] :=
  Block[{$base$=Null,$expon$=Null,$exponFlag$=False},
    FunctionOfExponentialTest[u,x] && $exponFlag$]


(* u is a function of F^v where v is linear in x.  FunctionOfExponential[u,x] returns F^v. *)
FunctionOfExponential[u_,x_Symbol] :=
  Block[{$base$=Null,$expon$=Null,$exponFlag$=False},
    FunctionOfExponentialTest[u,x];
    $base$^$expon$]


(* u is a function of F^v where v is linear in x.  FunctionOfExponentialFunction[u,x] returns u with F^v replaced by x. *)
FunctionOfExponentialFunction[u_,x_Symbol] :=
  Block[{$base$=Null,$expon$=Null,$exponFlag$=False},
    FunctionOfExponentialTest[u,x];
    SimplifyIntegrand[FunctionOfExponentialFunctionAux[u,x],x]]


(* u is a function of F^v where v is linear in x, and the fluid variables $base$=F and $expon$=v. *)
(* FunctionOfExponentialFunctionAux[u,x] returns u with F^v replaced by x. *)
FunctionOfExponentialFunctionAux[u_,x_] :=
  If[AtomQ[u],
    u,
  If[PowerQ[u] && FreeQ[u[[1]],x] && LinearQ[u[[2]],x],
    If[ZeroQ[Coefficient[$expon$,x,0]],
      u[[1]]^Coefficient[u[[2]],x,0]*x^FullSimplify[Log[u[[1]]]*Coefficient[u[[2]],x,1]/(Log[$base$]*Coefficient[$expon$,x,1])],
    x^FullSimplify[Log[u[[1]]]*Coefficient[u[[2]],x,1]/(Log[$base$]*Coefficient[$expon$,x,1])]],
  If[HyperbolicQ[u] && LinearQ[u[[1]],x],
    Module[{tmp},
    tmp=x^FullSimplify[Coefficient[u[[1]],x,1]/(Log[$base$]*Coefficient[$expon$,x,1])];
    If[SinhQ[u],
      tmp/2-1/(2*tmp),
    If[CoshQ[u],
      tmp/2+1/(2*tmp),
    If[TanhQ[u],    
      (tmp-1/tmp)/(tmp+1/tmp),
    If[CothQ[u],    
      (tmp+1/tmp)/(tmp-1/tmp),
    If[SechQ[u],
      2/(tmp+1/tmp),
    2/(tmp-1/tmp)]]]]]],
  If[PowerQ[u] && FreeQ[u[[1]],x] && SumQ[u[[2]]],
    FunctionOfExponentialFunctionAux[u[[1]]^First[u[[2]]],x]*FunctionOfExponentialFunctionAux[u[[1]]^Rest[u[[2]]],x],
  Map[Function[FunctionOfExponentialFunctionAux[#,x]],u]]]]]


(* FunctionOfExponentialTest[u,x] returns True iff u is a function of F^v where F is a constant and v is linear in x. *)
(* Before it is called, the fluid variables $base$ and $expon$ should be set to Null and $exponFlag$ to False. *)
(* If u is a function of F^v, $base$ and $expon$ are set to F and v, respectively. *)
(* If an explicit exponential occurs in u, $exponFlag$ is set to True. *)
FunctionOfExponentialTest[u_,x_] :=
  If[FreeQ[u,x],
    True,
  If[u===x || CalculusQ[u],
    False,
  If[PowerQ[u] && FreeQ[u[[1]],x] && LinearQ[u[[2]],x],
    $exponFlag$=True;
    FunctionOfExponentialTestAux[u[[1]],u[[2]],x],
  If[HyperbolicQ[u] && LinearQ[u[[1]],x],
    FunctionOfExponentialTestAux[E,u[[1]],x],
  If[PowerQ[u] && FreeQ[u[[1]],x] && SumQ[u[[2]]],
    FunctionOfExponentialTest[u[[1]]^First[u[[2]]],x] && FunctionOfExponentialTest[u[[1]]^Rest[u[[2]]],x],
  Catch[Scan[Function[If[Not[FunctionOfExponentialTest[#,x]],Throw[False]]],u]; True]]]]]]


FunctionOfExponentialTestAux[base_,expon_,x_] :=
  If[$base$===Null,
    $base$=base;
    $expon$=expon;
    True,
  Module[{tmp},
  tmp=FullSimplify[Log[base]*Coefficient[expon,x,1]/(Log[$base$]*Coefficient[$expon$,x,1])];
  If[Not[RationalQ[tmp]],
    False,
  If[ZeroQ[Coefficient[$expon$,x,0]] || NonzeroQ[tmp-FullSimplify[Log[base]*Coefficient[expon,x,0]/(Log[$base$]*Coefficient[$expon$,x,0])]],
    ( If[PositiveIntegerQ[base,$base$] && base<$base$,
        $base$=base;
        $expon$=expon;
        tmp=1/tmp] );
    $expon$=Coefficient[$expon$,x,1]*x/Denominator[tmp];
    If[tmp<0 && NegQ[Coefficient[$expon$,x,1]],
      $expon$=-$expon$;
      True,
    True],
  ( If[PositiveIntegerQ[base,$base$] && base<$base$,
      $base$=base;
      $expon$=expon;
      tmp=1/tmp] );
(*$expon$=If[SumQ[$expon$], Map[Function[#/Denominator[tmp]],$expon$], $expon$/Denominator[tmp]]; *)
  $expon$=$expon$/Denominator[tmp];
  If[tmp<0 && NegQ[Coefficient[$expon$,x,1]],
    $expon$=-$expon$;
    True,
  True]]]]]


(* If u is an algebraic function of trig functions of a linear function of x, 
    FunctionOfTrigOfLinearQ[u,x] returns True; else it returns False. *)
FunctionOfTrigOfLinearQ[u_,x_Symbol] :=
  (* Not[MatchQ[u, (c_.*f_[a_.+b_.*x])^p_. /; FreeQ[{a,b,c,p},x] && MemberQ[{Sin,Cos,Sec,Csc},f]]] && *)
  Not[MemberQ[{Null, False}, FunctionOfTrig[u,Null,x]]] && AlgebraicTrigFunctionQ[u,x] (* && 
    RecognizedFunctionOfTrigQ[DeactivateTrig[u,x],x] *)

(* If u is a function of trig functions of v where v is a linear function of x, 
	FunctionOfTrig[u,x] returns v; else it returns False. *)
FunctionOfTrig[u_,x_Symbol] :=
  Module[{v=FunctionOfTrig[ActivateTrig[u],Null,x]},
  If[v===Null, False, v]]

FunctionOfTrig[u_,v_,x_] :=
  If[AtomQ[u],
    If[u===x,
      False,
    v],
  If[TrigQ[u] && LinearQ[u[[1]],x],
    If[v===Null,
      u[[1]],
    Module[{a=Coefficient[v,x,0],b=Coefficient[v,x,1],
			c=Coefficient[u[[1]],x,0],d=Coefficient[u[[1]],x,1]},
    If[ZeroQ[a*d-b*c] && RationalQ[b/d],
      a/Numerator[b/d]+b*x/Numerator[b/d],
    False]]],
  If[HyperbolicQ[u] && LinearQ[u[[1]],x],
    If[v===Null,
      I*u[[1]],
    Module[{a=Coefficient[v,x,0],b=Coefficient[v,x,1],
			c=I*Coefficient[u[[1]],x,0],d=I*Coefficient[u[[1]],x,1]},
    If[ZeroQ[a*d-b*c] && RationalQ[b/d],
      a/Numerator[b/d]+b*x/Numerator[b/d],
    False]]],
  If[CalculusQ[u],
    False,
  Module[{w=v},Catch[
  Scan[Function[If[FalseQ[w=FunctionOfTrig[#,w,x]],Throw[False]]],u];
  w]]]]]]


(* If u is algebraic function of trig functions, AlgebraicTrigFunctionQ[u,x] returns True; else it returns False. *)
AlgebraicTrigFunctionQ[u_,x_Symbol] :=
  If[AtomQ[u],
    True,
  If[TrigQ[u] && LinearQ[u[[1]],x],
    True,
  If[HyperbolicQ[u] && LinearQ[u[[1]],x],
    True,
  If[PowerQ[u] && FreeQ[u[[2]],x],
    AlgebraicTrigFunctionQ[u[[1]],x],
  If[ProductQ[u] || SumQ[u],
    Catch[Scan[Function[If[Not[AlgebraicTrigFunctionQ[#,x]],Throw[False]]],u]; True],
  False]]]]]


(* If u is a function of hyperbolic trig functions of v where v is linear in x, 
	FunctionOfHyperbolic[u,x] returns v; else it returns False. *)
FunctionOfHyperbolic[u_,x_Symbol] :=
  Module[{v=FunctionOfHyperbolic[u,Null,x]},
  If[v===Null, False, v]]

FunctionOfHyperbolic[u_,v_,x_] :=
  If[AtomQ[u],
    If[u===x,
      False,
    v],
  If[HyperbolicQ[u] && LinearQ[u[[1]],x],
    If[v===Null,
      u[[1]],
    Module[{a=Coefficient[v,x,0],b=Coefficient[v,x,1],
			c=Coefficient[u[[1]],x,0],d=Coefficient[u[[1]],x,1]},
    If[ZeroQ[a*d-b*c] && RationalQ[b/d],
      a/Numerator[b/d]+b*x/Numerator[b/d],
    False]]],
  If[CalculusQ[u],
    False,
  Module[{w=v},Catch[
  Scan[Function[If[FalseQ[w=FunctionOfHyperbolic[#,w,x]],Throw[False]]],u];
  w]]]]]


(* v is a function of x.
	If u is a function of v, FunctionOfQ[v,u,x] returns True; else it returns False. *)
FunctionOfQ[v_,u_,x_Symbol,PureFlag_:False] :=
  If[FreeQ[u,x],
    False,
  If[AtomQ[v],
    True,
  If[Not[InertTrigFreeQ[u]],
    FunctionOfQ[v,ActivateTrig[u],x,PureFlag],
  If[PowerQ[v] && FreeQ[v[[2]],x] (* && NonzeroQ[v[[2]]+1] *),
    FunctionOfPowerQ[u,v[[1]],v[[2]],x],
  If[ProductQ[v] && Not[OneQ[FreeFactors[v,x]]],
    FunctionOfQ[NonfreeFactors[v,x],u,x,PureFlag],

  If[PureFlag,
    If[SinQ[v] || CscQ[v],
      PureFunctionOfSinQ[u,v[[1]],x],
    If[CosQ[v] || SecQ[v],
      PureFunctionOfCosQ[u,v[[1]],x],
    If[TanQ[v],
      PureFunctionOfTanQ[u,v[[1]],x],
    If[CotQ[v],
      PureFunctionOfCotQ[u,v[[1]],x],
    If[SinhQ[v] || CschQ[v],
      PureFunctionOfSinhQ[u,v[[1]],x],
    If[CoshQ[v] || SechQ[v],
      PureFunctionOfCoshQ[u,v[[1]],x],
    If[TanhQ[v],
      PureFunctionOfTanhQ[u,v[[1]],x],
    If[CothQ[v],
      PureFunctionOfCothQ[u,v[[1]],x],
    FunctionOfExpnQ[u,v,x]]]]]]]]],
  If[SinQ[v] || CscQ[v],
    FunctionOfSinQ[u,v[[1]],x],
  If[CosQ[v] || SecQ[v],
    FunctionOfCosQ[u,v[[1]],x],
  If[TanQ[v] || CotQ[v],
    FunctionOfTanQ[u,v[[1]],x],
  If[SinhQ[v] || CschQ[v],
    FunctionOfSinhQ[u,v[[1]],x],
  If[CoshQ[v] || SechQ[v],
    FunctionOfCoshQ[u,v[[1]],x],
  If[TanhQ[v] || CothQ[v],
    FunctionOfTanhQ[u,v[[1]],x],
  FunctionOfExpnQ[u,v,x]]]]]]]]]]]]]


FunctionOfExpnQ[u_,v_,x_] :=
  If[u===v,
    True,
  If[AtomQ[u],
    u=!=x,
  If[CalculusQ[u],
    False,
  Catch[Scan[Function[If[FunctionOfExpnQ[#,v,x],Null,Throw[False]]],u];True]]]]


FunctionOfPowerQ[u_,bas_,deg_,x_] :=
  If[AtomQ[u],
    u=!=x,
  If[CalculusQ[u],
    False,
  If[PowerQ[u] && ZeroQ[u[[1]]-bas] && FreeQ[u[[2]],x],
    If[RationalQ[deg],
      If[RationalQ[u[[2]]],
        IntegerQ[u[[2]]/deg] && (deg>0 || u[[2]]<0),
      False],
    IntegerQ[Simplify[u[[2]]/deg]]],
  Catch[Scan[Function[If[FunctionOfPowerQ[#,bas,deg,x],Null,Throw[False]]],u];True]]]]


(* If func[w]^m is a factor of u where m is odd and w is an integer multiple of v, 
	FindTrigFactor[func1,func2,u,v,True] returns the list {w,u/func[w]^n}; else it returns False. *)
(* If func[w]^m is a factor of u where m is odd and w is an integer multiple of v not equal to v, 
	FindTrigFactor[func1,func2,u,v,False] returns the list {w,u/func[w]^n}; else it returns False. *)
FindTrigFactor[func1_,func2_,u_,v_,flag_] :=
  If[u===1,
    False,
  If[(Head[LeadBase[u]]===func1 || Head[LeadBase[u]]===func2) && 
		OddQ[LeadDegree[u]] && 
		IntegerQuotientQ[LeadBase[u][[1]],v] && 
		(flag || NonzeroQ[LeadBase[u][[1]]-v]),
    {LeadBase[u][[1]], RemainingFactors[u]},
  Module[{lst=FindTrigFactor[func1,func2,RemainingFactors[u],v,flag]},
  If[FalseQ[lst],
    False,
  {lst[[1]], LeadFactor[u]*lst[[2]]}]]]]


(* If u is a pure function of Sin[v] and/or Csc[v], PureFunctionOfSinQ[u,v,x] returns True; 
	else it returns False. *)
PureFunctionOfSinQ[u_,v_,x_] :=
  If[AtomQ[u],
    u=!=x,
  If[CalculusQ[u],
    False,
  If[TrigQ[u] && ZeroQ[u[[1]]-v],
    SinQ[u] || CscQ[u],
  Catch[Scan[Function[If[Not[PureFunctionOfSinQ[#,v,x]],Throw[False]]],u];True]]]]


(* If u is a pure function of Cos[v] and/or Sec[v], PureFunctionOfCosQ[u,v,x] returns True; 
	else it returns False. *)
PureFunctionOfCosQ[u_,v_,x_] :=
  If[AtomQ[u],
    u=!=x,
  If[CalculusQ[u],
    False,
  If[TrigQ[u] && ZeroQ[u[[1]]-v],
    CosQ[u] || SecQ[u],
  Catch[Scan[Function[If[Not[PureFunctionOfCosQ[#,v,x]],Throw[False]]],u];True]]]]


(* If u is a pure function of Tan[v] and/or Cot[v], PureFunctionOfTanQ[u,v,x] returns True; 
	else it returns False. *)
PureFunctionOfTanQ[u_,v_,x_] :=
  If[AtomQ[u],
    u=!=x,
  If[CalculusQ[u],
    False,
  If[TrigQ[u] && ZeroQ[u[[1]]-v],
    TanQ[u] || CotQ[u],
  Catch[Scan[Function[If[Not[PureFunctionOfTanQ[#,v,x]],Throw[False]]],u];True]]]]


(* If u is a pure function of Cot[v], PureFunctionOfCotQ[u,v,x] returns True; 
	else it returns False. *)
PureFunctionOfCotQ[u_,v_,x_] :=
  If[AtomQ[u],
    u=!=x,
  If[CalculusQ[u],
    False,
  If[TrigQ[u] && ZeroQ[u[[1]]-v],
    CotQ[u],
  Catch[Scan[Function[If[Not[PureFunctionOfCotQ[#,v,x]],Throw[False]]],u];True]]]]


(* If u is a function of Sin[v], FunctionOfSinQ[u,v,x] returns True; else it returns False. *)
FunctionOfSinQ[u_,v_,x_] :=
  If[AtomQ[u],
    u=!=x,
  If[CalculusQ[u],
    False,
  If[TrigQ[u] && IntegerQuotientQ[u[[1]],v],
    If[OddQuotientQ[u[[1]],v],
(* Basis: If m odd, Sin[m*v]^n is a function of Sin[v]. *)
      SinQ[u] || CscQ[u],
(* Basis: If m even, Cos[m*v]^n is a function of Sin[v]. *)
    CosQ[u] || SecQ[u]],
  If[IntegerPowerQ[u] && TrigQ[u[[1]]] && IntegerQuotientQ[u[[1,1]],v],
    If[EvenQ[u[[2]]],
(* Basis: If m integer and n even, Trig[m*v]^n is a function of Sin[v]. *)
      True,
    FunctionOfSinQ[u[[1]],v,x]],
  If[ProductQ[u],
    If[CosQ[u[[1]]] && SinQ[u[[2]]] && ZeroQ[u[[1,1]]-v/2] && ZeroQ[u[[2,1]]-v/2],
      FunctionOfSinQ[Drop[u,2],v,x],
    Module[{lst},
    lst=FindTrigFactor[Sin,Csc,u,v,False];
    If[NotFalseQ[lst] && EvenQuotientQ[lst[[1]],v],
(* Basis: If m even and n odd, Sin[m*v]^n == Cos[v]*u where u is a function of Sin[v]. *)
      FunctionOfSinQ[Cos[v]*lst[[2]],v,x],
    lst=FindTrigFactor[Cos,Sec,u,v,False];
    If[NotFalseQ[lst] && OddQuotientQ[lst[[1]],v],
(* Basis: If m odd and n odd, Cos[m*v]^n == Cos[v]*u where u is a function of Sin[v]. *)
      FunctionOfSinQ[Cos[v]*lst[[2]],v,x],
    lst=FindTrigFactor[Tan,Cot,u,v,True];
    If[NotFalseQ[lst],
(* Basis: If m integer and n odd, Tan[m*v]^n == Cos[v]*u where u is a function of Sin[v]. *)
      FunctionOfSinQ[Cos[v]*lst[[2]],v,x],
    Catch[Scan[Function[If[Not[FunctionOfSinQ[#,v,x]],Throw[False]]],u];True]]]]]],
  Catch[Scan[Function[If[Not[FunctionOfSinQ[#,v,x]],Throw[False]]],u];True]]]]]]


(* If u is a function of Cos[v], FunctionOfCosQ[u,v,x] returns True; else it returns False. *)
FunctionOfCosQ[u_,v_,x_] :=
  If[AtomQ[u],
    u=!=x,
  If[CalculusQ[u],
    False,
  If[TrigQ[u] && IntegerQuotientQ[u[[1]],v],
(* Basis: If m integer, Cos[m*v]^n is a function of Cos[v]. *)
    CosQ[u] || SecQ[u],
  If[IntegerPowerQ[u] && TrigQ[u[[1]]] && IntegerQuotientQ[u[[1,1]],v],
    If[EvenQ[u[[2]]],
(* Basis: If m integer and n even, Trig[m*v]^n is a function of Cos[v]. *)
      True,
    FunctionOfCosQ[u[[1]],v,x]],
  If[ProductQ[u],
    Module[{lst},
    lst=FindTrigFactor[Sin,Csc,u,v,False];
    If[NotFalseQ[lst],
(* Basis: If m integer and n odd, Sin[m*v]^n == Sin[v]*u where u is a function of Cos[v]. *)
      FunctionOfCosQ[Sin[v]*lst[[2]],v,x],
    lst=FindTrigFactor[Tan,Cot,u,v,True];
    If[NotFalseQ[lst],
(* Basis: If m integer and n odd, Tan[m*v]^n == Sin[v]*u where u is a function of Cos[v]. *)
      FunctionOfCosQ[Sin[v]*lst[[2]],v,x],
    Catch[Scan[Function[If[Not[FunctionOfCosQ[#,v,x]],Throw[False]]],u];True]]]],
  Catch[Scan[Function[If[Not[FunctionOfCosQ[#,v,x]],Throw[False]]],u];True]]]]]]


(* If u is a function of the form f[Tan[v],Cot[v]] where f is independent of x,
	FunctionOfTanQ[u,v,x] returns True; else it returns False. *)
FunctionOfTanQ[u_,v_,x_] :=
  If[AtomQ[u],
    u=!=x,
  If[CalculusQ[u],
    False,
  If[TrigQ[u] && IntegerQuotientQ[u[[1]],v],
    TanQ[u] || CotQ[u] || EvenQuotientQ[u[[1]],v],
  If[PowerQ[u] && EvenQ[u[[2]]] && TrigQ[u[[1]]] && IntegerQuotientQ[u[[1,1]],v],
    True,
  If[ProductQ[u],
    Module[{lst=ReapList[Scan[Function[If[Not[FunctionOfTanQ[#,v,x]],Sow[#]]],u]]},
    If[lst==={},
      True,
    Length[lst]==2 && OddTrigPowerQ[lst[[1]],v,x] && OddTrigPowerQ[lst[[2]],v,x]]],
  Catch[Scan[Function[If[Not[FunctionOfTanQ[#,v,x]],Throw[False]]],u];True]]]]]]

OddTrigPowerQ[u_,v_,x_] :=
  If[SinQ[u] || CosQ[u] || SecQ[u] || CscQ[u],
    OddQuotientQ[u[[1]],v],
  If[PowerQ[u],
    OddQ[u[[2]]] && OddTrigPowerQ[u[[1]],v,x],
  If[ProductQ[u],
    Module[{lst=ReapList[Scan[Function[If[Not[FunctionOfTanQ[#,v,x]],Sow[#]]],u]]},
    If[lst==={},
      True,
    Length[lst]==1 && OddTrigPowerQ[lst[[1]],v,x]]],
(*If[SumQ[u],
    Catch[Scan[Function[If[Not[OddTrigPowerQ[#,v,x]],Throw[False]]],u];True], *)
  False]]]


(* u is a function of the form f[Tan[v],Cot[v]] where f is independent of x.
FunctionOfTanWeight[u,v,x] returns a nonnegative number if u is best considered a function
of Tan[v]; else it returns a negative number. *)
FunctionOfTanWeight[u_,v_,x_] :=
  If[AtomQ[u],
    0,
  If[CalculusQ[u],
    0,
  If[TrigQ[u] && IntegerQuotientQ[u[[1]],v],
    If[TanQ[u] && ZeroQ[u[[1]]-v],
      1,
    If[CotQ[u] && ZeroQ[u[[1]]-v],
      -1,
    0]],
  If[PowerQ[u] && EvenQ[u[[2]]] && TrigQ[u[[1]]] && IntegerQuotientQ[u[[1,1]],v],
    If[TanQ[u[[1]]] || CosQ[u[[1]]] || SecQ[u[[1]]],
      1,
    -1],
  If[ProductQ[u],
    If[Catch[Scan[Function[If[Not[FunctionOfTanQ[#,v,x]],Throw[False]]],u];True],
      Apply[Plus,Map[Function[FunctionOfTanWeight[#,v,x]],Apply[List,u]]],
    0],
  Apply[Plus,Map[Function[FunctionOfTanWeight[#,v,x]],Apply[List,u]]]]]]]]


(* If u (x) is equivalent to an expression of the form f (Sin[v],Cos[v],Tan[v],Cot[v],Sec[v],Csc[v])
	where f is independent of x, FunctionOfTrigQ[u,v,x] returns True; else it returns False. *)
FunctionOfTrigQ[u_,v_,x_Symbol] :=
  If[AtomQ[u],
    u=!=x,
  If[CalculusQ[u],
    False,
  If[TrigQ[u] && IntegerQuotientQ[u[[1]],v],
    True,
  Catch[
    Scan[Function[If[Not[FunctionOfTrigQ[#,v,x]],Throw[False]]],u];
    True]]]]


(* If u is a pure function of Sinh[v] and/or Csch[v], PureFunctionOfSinhQ[u,v,x] returns True; 
	else it returns False. *)
PureFunctionOfSinhQ[u_,v_,x_] :=
  If[AtomQ[u],
    u=!=x,
  If[CalculusQ[u],
    False,
  If[HyperbolicQ[u] && ZeroQ[u[[1]]-v],
    SinhQ[u] || CschQ[u],
  Catch[Scan[Function[If[Not[PureFunctionOfSinhQ[#,v,x]],Throw[False]]],u];True]]]]


(* If u is a pure function of Cosh[v] and/or Sech[v], PureFunctionOfCoshQ[u,v,x] returns True; 
	else it returns False. *)
PureFunctionOfCoshQ[u_,v_,x_] :=
  If[AtomQ[u],
    u=!=x,
  If[CalculusQ[u],
    False,
  If[HyperbolicQ[u] && ZeroQ[u[[1]]-v],
    CoshQ[u] || SechQ[u],
  Catch[Scan[Function[If[Not[PureFunctionOfCoshQ[#,v,x]],Throw[False]]],u];True]]]]


(* If u is a pure function of Tanh[v] and/or Coth[v], PureFunctionOfTanhQ[u,v,x] returns True; 
	else it returns False. *)
PureFunctionOfTanhQ[u_,v_,x_] :=
  If[AtomQ[u],
    u=!=x,
  If[CalculusQ[u],
    False,
  If[HyperbolicQ[u] && ZeroQ[u[[1]]-v],
    TanhQ[u] || CothQ[u],
  Catch[Scan[Function[If[Not[PureFunctionOfTanhQ[#,v,x]],Throw[False]]],u];True]]]]


(* If u is a pure function of Coth[v], PureFunctionOfCothQ[u,v,x] returns True; 
	else it returns False. *)
PureFunctionOfCothQ[u_,v_,x_] :=
  If[AtomQ[u],
    u=!=x,
  If[CalculusQ[u],
    False,
  If[HyperbolicQ[u] && ZeroQ[u[[1]]-v],
    CothQ[u],
  Catch[Scan[Function[If[Not[PureFunctionOfCothQ[#,v,x]],Throw[False]]],u];True]]]]


(* If u is a function of Sinh[v], FunctionOfSinhQ[u,v,x] returns True; else it returns False. *)
FunctionOfSinhQ[u_,v_,x_] :=
  If[AtomQ[u],
    u=!=x,
  If[CalculusQ[u],
    False,
  If[HyperbolicQ[u] && IntegerQuotientQ[u[[1]],v],
    If[OddQuotientQ[u[[1]],v],
(* Basis: If m odd, Sinh[m*v]^n is a function of Sinh[v]. *)
      SinhQ[u] || CschQ[u],
(* Basis: If m even, Cos[m*v]^n is a function of Sinh[v]. *)
    CoshQ[u] || SechQ[u]],
  If[IntegerPowerQ[u] && HyperbolicQ[u[[1]]] && IntegerQuotientQ[u[[1,1]],v],
    If[EvenQ[u[[2]]],
(* Basis: If m integer and n even, Hyper[m*v]^n is a function of Sinh[v]. *)
      True,
    FunctionOfSinhQ[u[[1]],v,x]],
  If[ProductQ[u],
    If[CoshQ[u[[1]]] && SinhQ[u[[2]]] && ZeroQ[u[[1,1]]-v/2] && ZeroQ[u[[2,1]]-v/2],
      FunctionOfSinhQ[Drop[u,2],v,x],
    Module[{lst},
    lst=FindTrigFactor[Sinh,Csch,u,v,False];
    If[NotFalseQ[lst] && EvenQuotientQ[lst[[1]],v],
(* Basis: If m even and n odd, Sinh[m*v]^n == Cosh[v]*u where u is a function of Sinh[v]. *)
      FunctionOfSinhQ[Cosh[v]*lst[[2]],v,x],
    lst=FindTrigFactor[Cosh,Sech,u,v,False];
    If[NotFalseQ[lst] && OddQuotientQ[lst[[1]],v],
(* Basis: If m odd and n odd, Cosh[m*v]^n == Cosh[v]*u where u is a function of Sinh[v]. *)
      FunctionOfSinhQ[Cosh[v]*lst[[2]],v,x],
    lst=FindTrigFactor[Tanh,Coth,u,v,True];
    If[NotFalseQ[lst],
(* Basis: If m integer and n odd, Tanh[m*v]^n == Cosh[v]*u where u is a function of Sinh[v]. *)
      FunctionOfSinhQ[Cosh[v]*lst[[2]],v,x],
    Catch[Scan[Function[If[Not[FunctionOfSinhQ[#,v,x]],Throw[False]]],u];True]]]]]],
  Catch[Scan[Function[If[Not[FunctionOfSinhQ[#,v,x]],Throw[False]]],u];True]]]]]]


(* If u is a function of Cosh[v], FunctionOfCoshQ[u,v,x] returns True; else it returns False. *)
FunctionOfCoshQ[u_,v_,x_] :=
  If[AtomQ[u],
    u=!=x,
  If[CalculusQ[u],
    False,
  If[HyperbolicQ[u] && IntegerQuotientQ[u[[1]],v],
(* Basis: If m integer, Cosh[m*v]^n is a function of Cosh[v]. *)
    CoshQ[u] || SechQ[u],
  If[IntegerPowerQ[u] && HyperbolicQ[u[[1]]] && IntegerQuotientQ[u[[1,1]],v],
    If[EvenQ[u[[2]]],
(* Basis: If m integer and n even, Hyper[m*v]^n is a function of Cosh[v]. *)
      True,
    FunctionOfCoshQ[u[[1]],v,x]],
  If[ProductQ[u],
    Module[{lst},
    lst=FindTrigFactor[Sinh,Csch,u,v,False];
    If[NotFalseQ[lst],
(* Basis: If m integer and n odd, Sinh[m*v]^n == Sinh[v]*u where u is a function of Cosh[v]. *)
      FunctionOfCoshQ[Sinh[v]*lst[[2]],v,x],
    lst=FindTrigFactor[Tanh,Coth,u,v,True];
    If[NotFalseQ[lst],
(* Basis: If m integer and n odd, Tanh[m*v]^n == Sinh[v]*u where u is a function of Cosh[v]. *)
      FunctionOfCoshQ[Sinh[v]*lst[[2]],v,x],
    Catch[Scan[Function[If[Not[FunctionOfCoshQ[#,v,x]],Throw[False]]],u];True]]]],
  Catch[Scan[Function[If[Not[FunctionOfCoshQ[#,v,x]],Throw[False]]],u];True]]]]]]


(* If u is a function of the form f[Tanh[v],Coth[v]] where f is independent of x,
	FunctionOfTanhQ[u,v,x] returns True; else it returns False. *)
FunctionOfTanhQ[u_,v_,x_] :=
  If[AtomQ[u],
    u=!=x,
  If[CalculusQ[u],
    False,
  If[HyperbolicQ[u] && IntegerQuotientQ[u[[1]],v],
    TanhQ[u] || CothQ[u] || EvenQuotientQ[u[[1]],v],
  If[PowerQ[u] && EvenQ[u[[2]]] && HyperbolicQ[u[[1]]] && IntegerQuotientQ[u[[1,1]],v],
    True,
  If[ProductQ[u],
    Module[{lst=ReapList[Scan[Function[If[Not[FunctionOfTanhQ[#,v,x]],Sow[#]]],u]]},
    If[lst==={},
      True,
    Length[lst]==2 && OddHyperbolicPowerQ[lst[[1]],v,x] && OddHyperbolicPowerQ[lst[[2]],v,x]]],
  Catch[Scan[Function[If[Not[FunctionOfTanhQ[#,v,x]],Throw[False]]],u];True]]]]]]

OddHyperbolicPowerQ[u_,v_,x_] :=
  If[SinhQ[u] || CoshQ[u] || SechQ[u] || CschQ[u],
    OddQuotientQ[u[[1]],v],
  If[PowerQ[u],
    OddQ[u[[2]]] && OddHyperbolicPowerQ[u[[1]],v,x],
  If[ProductQ[u],
    Module[{lst=ReapList[Scan[Function[If[Not[FunctionOfTanhQ[#,v,x]],Sow[#]]],u]]},
    If[lst==={},
      True,
    Length[lst]==1 && OddHyperbolicPowerQ[lst[[1]],v,x]]],
(*If[SumQ[u],
    Catch[Scan[Function[If[Not[OddHyperbolicPowerQ[#,v,x]],Throw[False]]],u];True], *)
  False]]]


(* u is a function of the form f[Tanh[v],Coth[v]] where f is independent of x.
FunctionOfTanhWeight[u,v,x] returns a nonnegative number if u is best considered a function
of Tanh[v]; else it returns a negative number. *)
FunctionOfTanhWeight[u_,v_,x_] :=
  If[AtomQ[u],
    0,
  If[CalculusQ[u],
    0,
  If[HyperbolicQ[u] && IntegerQuotientQ[u[[1]],v],
    If[TanhQ[u] && ZeroQ[u[[1]]-v],
      1,
    If[CothQ[u] && ZeroQ[u[[1]]-v],
      -1,
    0]],
  If[PowerQ[u] && EvenQ[u[[2]]] && HyperbolicQ[u[[1]]] && IntegerQuotientQ[u[[1,1]],v],
    If[TanhQ[u[[1]]] || CoshQ[u[[1]]] || SechQ[u[[1]]],
      1,
    -1],
  If[ProductQ[u],
    If[Catch[Scan[Function[If[Not[FunctionOfTanhQ[#,v,x]],Throw[False]]],u];True],
      Apply[Plus,Map[Function[FunctionOfTanhWeight[#,v,x]],Apply[List,u]]],
    0],
  Apply[Plus,Map[Function[FunctionOfTanhWeight[#,v,x]],Apply[List,u]]]]]]]]


(* If u (x) is equivalent to a function of the form f (Sinh[v],Cosh[v],Tanh[v],Coth[v],Sech[v],Csch[v])
	where f is independent of x, FunctionOfHyperbolicQ[u,v,x] returns True; else it returns False. *)
FunctionOfHyperbolicQ[u_,v_,x_Symbol] :=
  If[AtomQ[u],
    u=!=x,
  If[CalculusQ[u],
    False,
  If[HyperbolicQ[u] && IntegerQuotientQ[u[[1]],v],
    True,
  Catch[Scan[Function[If[FunctionOfHyperbolicQ[#,v,x],Null,Throw[False]]],u];True]]]]


(* If u/v is an integer, IntegerQuotientQ[u,v] returns True; else it returns False. *)
IntegerQuotientQ[u_,v_] :=
(* u===v || ZeroQ[u-v] || IntegerQ[u/v] *)
  IntegerQ[Simplify[u/v]]

(* If u/v is odd, OddQuotientQ[u,v] returns True; else it returns False. *)
OddQuotientQ[u_,v_] :=
(* u===v || ZeroQ[u-v] || OddQ[u/v] *)
  OddQ[Simplify[u/v]]

(* If u/v is even, EvenQuotientQ[u,v] returns True; else it returns False. *)
EvenQuotientQ[u_,v_] :=
  EvenQ[Simplify[u/v]]


(* If all occurrences of x in u (x) are in dense polynomials, FunctionOfDensePolynomialsQ[u,x]
	returns True; else it returns False. *)
FunctionOfDensePolynomialsQ[u_,x_Symbol] :=
  If[FreeQ[u,x],
    True,
  If[PolynomialQ[u,x],
    Length[Exponent[u,x,List]]>1,
  Catch[
  Scan[Function[If[FunctionOfDensePolynomialsQ[#,x],Null,Throw[False]]],u];
  True]]]


(* If u (x) is equivalent to an expression of the form f (Log[a*x^n]), FunctionOfLog[u,x] returns
	the list {f (x),a*x^n,n}; else it returns False. *)
FunctionOfLog[u_,x_Symbol] :=
  Module[{lst=FunctionOfLog[u,False,False,x]},
  If[FalseQ[lst] || FalseQ[lst[[2]]],
    False,
  lst]]


FunctionOfLog[u_,v_,n_,x_] :=
  If[AtomQ[u],
    If[u===x,
      False,
    {u,v,n}],
  If[CalculusQ[u],
    False,
  Module[{lst},
  If[LogQ[u] && NotFalseQ[lst=BinomialTest[u[[1]],x]] && ZeroQ[lst[[1]]],
    If[FalseQ[v] || u[[1]]===v,
      {x,u[[1]],lst[[3]]},
    False],
  lst={0,v,n};
  Catch[
    {Map[Function[lst=FunctionOfLog[#,lst[[2]],lst[[3]],x];
				  If[FalseQ[lst],Throw[False],lst[[1]]]],
			u],lst[[2]],lst[[3]]}]]]]]


(* If m is an integer, u is an expression of the form f[(c*x)^n] and g=GCD[m,n]>1,
   PowerVariableExpn[u,m,x] returns the list {x^(m/g)*f[(c*x)^(n/g)],g,c}; else it returns False. *)
PowerVariableExpn[u_,m_,x_Symbol] :=
  If[IntegerQ[m],
    Module[{lst=PowerVariableDegree[u,m,1,x]},
    If[FalseQ[lst],
      False,
    {x^(m/lst[[1]])*PowerVariableSubst[u,lst[[1]],x], lst[[1]], lst[[2]]}]],
  False]


PowerVariableDegree[u_,m_,c_,x_Symbol] :=
  If[FreeQ[u,x],
    {m, c},
  If[AtomQ[u] || CalculusQ[u],
    False,
  If[PowerQ[u] && FreeQ[u[[1]]/x,x],
    If[ZeroQ[m] || m===u[[2]] && c===u[[1]]/x,
      {u[[2]], u[[1]]/x},
    If[IntegerQ[u[[2]]] && IntegerQ[m] && GCD[m,u[[2]]]>1 && c===u[[1]]/x,
      {GCD[m,u[[2]]], c},
    False]],
  Catch[Module[{lst={m, c}},
  Scan[Function[lst=PowerVariableDegree[#,lst[[1]],lst[[2]],x];If[FalseQ[lst],Throw[False]]],u];
  lst]]]]]


PowerVariableSubst[u_,m_,x_Symbol] :=
  If[FreeQ[u,x] || AtomQ[u] ||CalculusQ[u],
    u,
  If[PowerQ[u] && FreeQ[u[[1]]/x,x],
    x^(u[[2]]/m),
  Map[Function[PowerVariableSubst[#,m,x]],u]]]


EulerIntegrandQ[(a_.*x_+b_.*u_^n_)^p_,x_Symbol] :=
  True /;
FreeQ[{a,b},x] && IntegerQ[n+1/2] && QuadraticQ[u,x] && (Not[RationalQ[p]] || NegativeIntegerQ[p] && Not[BinomialQ[u,x]])


EulerIntegrandQ[v_^m_.*(a_.*x_+b_.*u_^n_)^p_,x_Symbol] :=
  True /;
FreeQ[{a,b},x] && ZeroQ[u-v] && IntegersQ[2*m,n+1/2] && QuadraticQ[u,x] && 
  (Not[RationalQ[p]] || NegativeIntegerQ[p] && Not[BinomialQ[u,x]])


EulerIntegrandQ[v_^m_.*(a_.*x_+b_.*u_^n_)^p_,x_Symbol] :=
  True /;
FreeQ[{a,b},x] && ZeroQ[u-v] && IntegersQ[2*m,n+1/2] && QuadraticQ[u,x] && 
  (Not[RationalQ[p]] || NegativeIntegerQ[p] && Not[BinomialQ[u,x]])


EulerIntegrandQ[u_^n_*v_^p_,x_Symbol] :=
  True /;
NegativeIntegerQ[p] && IntegerQ[n+1/2] && QuadraticQ[u,x] && QuadraticQ[v,x] && Not[BinomialQ[v,x]]

EulerIntegrandQ[u_,x_Symbol] :=
  False


(*
Euler substitution #2:
  If u is an expression of the form f (Sqrt[a+b*x+c*x^2],x), f (x,x) is a rational function, and
	PosQ[c], FunctionOfSquareRootOfQuadratic[u,x] returns the 3-element list {
		f ((a*Sqrt[c]+b*x+Sqrt[c]*x^2)/(b+2*Sqrt[c]*x),(-a+x^2)/(b+2*Sqrt[c]*x))*
		  (a*Sqrt[c]+b*x+Sqrt[c]*x^2)/(b+2*Sqrt[c]*x)^2,
		Sqrt[c]*x+Sqrt[a+b*x+c*x^2], 2 };

Euler substitution #1:
  If u is an expression of the form f (Sqrt[a+b*x+c*x^2],x), f (x,x) is a rational function, and
	PosQ[a], FunctionOfSquareRootOfQuadratic[u,x] returns the two element list {
		f ((c*Sqrt[a]-b*x+Sqrt[a]*x^2)/(c-x^2),(-b+2*Sqrt[a]*x)/(c-x^2))*
		  (c*Sqrt[a]-b*x+Sqrt[a]*x^2)/(c-x^2)^2,
		(-Sqrt[a]+Sqrt[a+b*x+c*x^2])/x, 1 };

Euler substitution #3:
  If u is an expression of the form f (Sqrt[a+b*x+c*x^2],x), f (x,x) is a rational function, and
	NegQ[a] and NegQ[c], FunctionOfSquareRootOfQuadratic[u,x] returns the two element list {
		-Sqrt[b^2-4*a*c]*
		f (-Sqrt[b^2-4*a*c]*x/(c-x^2),-(b*c+c*Sqrt[b^2-4*a*c]+(-b+Sqrt[b^2-4*a*c])*x^2)/(2*c*(c-x^2)))*
		  x/(c-x^2)^2,
		2*c*Sqrt[a+b*x+c*x^2]/(b-Sqrt[b^2-4*a*c]+2*c*x), 3 };

  else it returns False. *)

FunctionOfSquareRootOfQuadratic[u_,x_Symbol] :=
  If[MatchQ[u,x^m_.*(a_+b_.*x^n_.)^p_ /; FreeQ[{a,b,m,n,p},x]],
    False,
  Module[{tmp=FunctionOfSquareRootOfQuadratic[u,False,x]},
  If[FalseQ[tmp] || FalseQ[tmp[[1]]],
    False,
  tmp=tmp[[1]];
  Module[{a=Coefficient[tmp,x,0],b=Coefficient[tmp,x,1],c=Coefficient[tmp,x,2],sqrt,q,r},
  If[ZeroQ[a] && ZeroQ[b] || ZeroQ[b^2-4*a*c],
    False,
  If[PosQ[c],
    sqrt=Rt[c,2];
    q=a*sqrt+b*x+sqrt*x^2;
    r=b+2*sqrt*x;
    {Simplify[SquareRootOfQuadraticSubst[u,q/r,(-a+x^2)/r,x]*q/r^2],
     Simplify[sqrt*x+Sqrt[tmp]],
     2},
  If[PosQ[a],
    sqrt=Rt[a,2];
    q=c*sqrt-b*x+sqrt*x^2;
    r=c-x^2;
    {Simplify[SquareRootOfQuadraticSubst[u,q/r,(-b+2*sqrt*x)/r,x]*q/r^2],
     Simplify[(-sqrt+Sqrt[tmp])/x],
     1},
  sqrt=Rt[b^2-4*a*c,2];
  r=c-x^2;
  {Simplify[-sqrt*SquareRootOfQuadraticSubst[u,-sqrt*x/r,-(b*c+c*sqrt+(-b+sqrt)*x^2)/(2*c*r),x]*x/r^2],
   FullSimplify[2*c*Sqrt[tmp]/(b-sqrt+2*c*x)],
   3}]]]]]]]


FunctionOfSquareRootOfQuadratic[u_,v_,x_Symbol] :=
  If[AtomQ[u] || FreeQ[u,x],
    {v},
  If[PowerQ[u] && FreeQ[u[[2]],x],
    If[FractionQ[u[[2]]] && Denominator[u[[2]]]==2 && PolynomialQ[u[[1]],x] && Exponent[u[[1]],x]==2,
      If[(FalseQ[v] || u[[1]]===v),
        {u[[1]]},
      False],
    FunctionOfSquareRootOfQuadratic[u[[1]],v,x]],
  If[ProductQ[u] || SumQ[u],
    Catch[Module[{lst={v}},
    Scan[Function[lst=FunctionOfSquareRootOfQuadratic[#,lst[[1]],x];If[FalseQ[lst],Throw[False]]],u];
    lst]],
  False]]]


(* SquareRootOfQuadraticSubst[u,vv,xx,x] returns u with fractional powers replaced by vv raised
	to the power and x replaced by xx. *)
SquareRootOfQuadraticSubst[u_,vv_,xx_,x_Symbol] :=
  If[AtomQ[u] || FreeQ[u,x],
    If[u===x,
      xx,
    u],
  If[PowerQ[u] && FreeQ[u[[2]],x],
    If[FractionQ[u[[2]]] && Denominator[u[[2]]]==2 && PolynomialQ[u[[1]],x] && Exponent[u[[1]],x]==2,
      vv^Numerator[u[[2]]],
    SquareRootOfQuadraticSubst[u[[1]],vv,xx,x]^u[[2]]],
  Map[Function[SquareRootOfQuadraticSubst[#,vv,xx,x]],u]]]


(* Subst[u,x,w] returns u with x replaced by w and resulting constant terms replaced by 0. *) 
Subst[u_,x_Symbol,w_] :=
  SimplifyAntiderivative[SubstAux[u,x,w],x]

Subst[u_,x_,w_] :=
  SubstAux[u,x,w]


(* Subst[u,v,w] returns u with all nondummy occurences of v replaced by w *)
SubstAux[u_,v_,w_] :=
  If[u===v,
    w,
  If[AtomQ[u],
    u,
  If[PowerQ[u],
    If[PowerQ[v] && u[[1]]===v[[1]] && SumQ[u[[2]]],
      SubstAux[u[[1]]^First[u[[2]]],v,w]*SubstAux[u[[1]]^Rest[u[[2]]],v,w],
    SubstAux[u[[1]],v,w]^SubstAux[u[[2]],v,w]],
  If[Head[u]===Defer[Subst],
    If[u[[2]]===v || FreeQ[u[[1]],v],
      SubstAux[u[[1]],u[[2]],SubstAux[u[[3]],v,w]],
    Defer[Subst][u,v,w]],
  If[Head[u]===Defer[Dist],
    Defer[Dist][SubstAux[u[[1]],v,w],SubstAux[u[[2]],v,w],u[[3]]],
  If[CalculusQ[u] && Not[FreeQ[v,u[[2]]]] || HeldFormQ[u] && Head[u]=!=Defer[AppellF1],
    Defer[Subst][u,v,w],
  Map[Function[SubstAux[#,v,w]],u]]]]]]]


SimplifyAntiderivative[c_*u_,x_Symbol] :=
  c*SimplifyAntiderivative[u,x] /;
FreeQ[c,x]


SimplifyAntiderivative[Log[c_*u_],x_Symbol] :=
  SimplifyAntiderivative[Log[u],x] /;
FreeQ[c,x]


SimplifyAntiderivative[Log[u_^n_],x_Symbol] :=
  n*SimplifyAntiderivative[Log[u],x] /;
FreeQ[n,x]


SimplifyAntiderivative[Log[f_^u_],x_Symbol] :=
  Log[f]*SimplifyAntiderivative[u,x] /;
FreeQ[f,x]


SimplifyAntiderivative[ArcTan[Tan[u_]],x_Symbol] :=
  SimplifyAntiderivative[u,x]

SimplifyAntiderivative[ArcTan[Cot[u_]],x_Symbol] :=
  -SimplifyAntiderivative[u,x]


SimplifyAntiderivative[ArcTan[Complex[0,n_]*Tanh[u_]],x_Symbol] :=
  Complex[0,n]*SimplifyAntiderivative[u,x] /;
OneQ[n^2]

SimplifyAntiderivative[ArcTan[Complex[0,n_]*Coth[u_]],x_Symbol] :=
  Complex[0,n]*SimplifyAntiderivative[u,x] /;
OneQ[n^2]


SimplifyAntiderivative[ArcCot[Tan[u_]],x_Symbol] :=
  -SimplifyAntiderivative[u,x]

SimplifyAntiderivative[ArcCot[Cot[u_]],x_Symbol] :=
  SimplifyAntiderivative[u,x]


SimplifyAntiderivative[ArcCot[Complex[0,n_]*Tanh[u_]],x_Symbol] :=
  -Complex[0,n]*SimplifyAntiderivative[u,x] /;
OneQ[n^2]

SimplifyAntiderivative[ArcCot[Complex[0,n_]*Coth[u_]],x_Symbol] :=
  -Complex[0,n]*SimplifyAntiderivative[u,x] /;
OneQ[n^2]


SimplifyAntiderivative[ArcTanh[Tanh[u_]],x_Symbol] :=
  SimplifyAntiderivative[u,x]

SimplifyAntiderivative[ArcTanh[Coth[u_]],x_Symbol] :=
  SimplifyAntiderivative[u,x]


SimplifyAntiderivative[ArcCoth[Tanh[u_]],x_Symbol] :=
  SimplifyAntiderivative[u,x]

SimplifyAntiderivative[ArcCoth[Coth[u_]],x_Symbol] :=
  SimplifyAntiderivative[u,x]


SimplifyAntiderivative[u_,x_Symbol] :=
  If[FreeQ[u,x],
    0,
  If[LogQ[u],
    Log[RemoveContent[u[[1]],x]],
  If[SumQ[u],
    Map[Function[SimplifyAntiderivative[#,x]],u],
  u]]]


(* u is a function of v.  SubstFor[w,v,u,x] returns w times u with v replaced by x. *)
SubstFor[w_,v_,u_,x_] :=
  SimplifyIntegrand[w*SubstFor[v,u,x],x]


(* u is a function of v.  SubstFor[v,u,x] returns u with v replaced by x. *)
SubstFor[v_,u_,x_] :=
  If[AtomQ[v],
    Subst[u,v,x],
  If[Not[InertTrigFreeQ[u]],
    SubstFor[v,ActivateTrig[u],x],
  If[PowerQ[v] && FreeQ[v[[2]],x] (* && NonzeroQ[v[[2]]+1] *),
    SubstForPower[u,v[[1]],v[[2]],x],
  If[Not[OneQ[FreeFactors[v,x]]],
    SubstFor[NonfreeFactors[v,x],u,x/FreeFactors[v,x]],

  If[SinQ[v],
    SubstForTrig[u,x,Sqrt[1-x^2],v[[1]],x],
  If[CosQ[v],
    SubstForTrig[u,Sqrt[1-x^2],x,v[[1]],x],
  If[TanQ[v],
    SubstForTrig[u,x/Sqrt[1+x^2],1/Sqrt[1+x^2],v[[1]],x],
  If[CotQ[v],
    SubstForTrig[u,1/Sqrt[1+x^2],x/Sqrt[1+x^2],v[[1]],x],
  If[SecQ[v],
    SubstForTrig[u,1/Sqrt[1-x^2],1/x,v[[1]],x],
  If[CscQ[v],
    SubstForTrig[u,1/x,1/Sqrt[1-x^2],v[[1]],x],

  If[SinhQ[v],
    SubstForHyperbolic[u,x,Sqrt[1+x^2],v[[1]],x],
  If[CoshQ[v],
    SubstForHyperbolic[u,Sqrt[-1+x^2],x,v[[1]],x],
  If[TanhQ[v],
    SubstForHyperbolic[u,x/Sqrt[1-x^2],1/Sqrt[1-x^2],v[[1]],x],
  If[CothQ[v],
    SubstForHyperbolic[u,1/Sqrt[-1+x^2],x/Sqrt[-1+x^2],v[[1]],x],
  If[SechQ[v],
    SubstForHyperbolic[u,1/Sqrt[-1+x^2],1/x,v[[1]],x],
  If[CschQ[v],
    SubstForHyperbolic[u,1/x,1/Sqrt[1+x^2],v[[1]],x],

  SubstForExpn[u,v,x]]]]]]]]]]]]]]]]]


SubstForExpn[u_,v_,w_] :=
  If[u===v,
    w,
  If[AtomQ[u],
    u,
  Map[Function[SubstForExpn[#,v,w]],u]]]


SubstForPower[u_,bas_,deg_,x_] :=
  If[AtomQ[u],
    u,
  If[PowerQ[u] && ZeroQ[u[[1]]-bas] && FreeQ[u[[2]],x] && IntegerQ[Simplify[u[[2]]/deg]]
		(* && (u[[2]]/deg>0 || FractionQ[deg]) *),
    x^(u[[2]]/deg),
  Map[Function[SubstForPower[#,bas,deg,x]],u]]]


(* u (v) is an expression of the form f (Sin[v],Cos[v],Tan[v],Cot[v],Sec[v],Csc[v]). *)
(* SubstForTrig[u,sin,cos,v,x] returns the expression f (sin,cos,sin/cos,cos/sin,1/cos,1/sin). *)
SubstForTrig[u_,sin_,cos_,v_,x_] :=
  If[AtomQ[u],
    u,
  If[TrigQ[u] && IntegerQuotientQ[u[[1]],v],
    If[u[[1]]===v || ZeroQ[u[[1]]-v],
      If[SinQ[u],
        sin,
      If[CosQ[u],
        cos,
      If[TanQ[u],
        sin/cos,
      If[CotQ[u],
        cos/sin,
      If[SecQ[u],
        1/cos,
      1/sin]]]]],
    Map[Function[SubstForTrig[#,sin,cos,v,x]],
			ReplaceAll[TrigExpand[Head[u][Simplify[u[[1]]/v]*x]],x->v]]],
  If[ProductQ[u] && CosQ[u[[1]]] && SinQ[u[[2]]] && ZeroQ[u[[1,1]]-v/2] && ZeroQ[u[[2,1]]-v/2],
    sin/2*SubstForTrig[Drop[u,2],sin,cos,v,x],
  Map[Function[SubstForTrig[#,sin,cos,v,x]],u]]]]


(* u (v) is an expression of the form f (Sinh[v],Cosh[v],Tanh[v],Coth[v],Sech[v],Csch[v]). *)
(* SubstForHyperbolic[u,sinh,cosh,v,x] returns the expression
		f (sinh,cosh,sinh/cosh,cosh/sinh,1/cosh,1/sinh). *)
SubstForHyperbolic[u_,sinh_,cosh_,v_,x_] :=
  If[AtomQ[u],
    u,
  If[HyperbolicQ[u] && IntegerQuotientQ[u[[1]],v],
    If[u[[1]]===v || ZeroQ[u[[1]]-v],
      If[SinhQ[u],
        sinh,
      If[CoshQ[u],
        cosh,
      If[TanhQ[u],
        sinh/cosh,
      If[CothQ[u],
        cosh/sinh,
      If[SechQ[u],
        1/cosh,
      1/sinh]]]]],
    Map[Function[SubstForHyperbolic[#,sinh,cosh,v,x]],
			ReplaceAll[TrigExpand[Head[u][Simplify[u[[1]]/v]*x]],x->v]]],
  If[ProductQ[u] && CoshQ[u[[1]]] && SinhQ[u[[2]]] && ZeroQ[u[[1,1]]-v/2] && ZeroQ[u[[2,1]]-v/2],
    sinh/2*SubstForHyperbolic[Drop[u,2],sinh,cosh,v,x],
  Map[Function[SubstForHyperbolic[#,sinh,cosh,v,x]],u]]]]


(* If u has a subexpression of the form (a+b*x)^(m/n) where m and n>1 are integers, 
	SubstForFractionalPowerOfLinear[u,x] returns the list {v,n,a+b*x,1/b} where v is u
	with subexpressions of the form (a+b*x)^(m/n) replaced by x^m and x replaced
	by -a/b+x^n/b, and all times x^(n-1); else it returns False. *)
SubstForFractionalPowerOfLinear[u_,x_Symbol] :=
  Module[{lst=FractionalPowerOfLinear[u,1,False,x],n,a,b,tmp},
  If[FalseQ[lst] || FalseQ[lst[[2]]],
    False,
  n=lst[[1]];
  a=Coefficient[lst[[2]],x,0];
  b=Coefficient[lst[[2]],x,1];
  tmp=x^(n-1)*SubstForFractionalPower[u,lst[[2]],n,-a/b+x^n/b,x];
  tmp=SplitFreeFactors[Simplify[tmp],x];
  {tmp[[2]],n,lst[[2]],tmp[[1]]/b}]]


(* If u has a subexpression of the form (a+b*x)^(m/n), 
	FractionalPowerOfLinear[u,1,False,x] returns {n,a+b*x}; else it returns False. *)
FractionalPowerOfLinear[u_,n_,v_,x_] :=
  If[AtomQ[u] || FreeQ[u,x],
    {n,v},
  If[CalculusQ[u],
    False,
  If[FractionalPowerQ[u] && LinearQ[u[[1]],x] && (FalseQ[v] || ZeroQ[u[[1]]-v]),
    {LCM[Denominator[u[[2]]],n],u[[1]]},
  Catch[Module[{lst={n,v}},
    Scan[Function[If[FalseQ[lst=FractionalPowerOfLinear[#,lst[[1]],lst[[2]],x]],Throw[False]]],u];
    lst]]]]]


(* If u has a subexpression of the form g[a+b*x] where g is an inverse function, 
	InverseFunctionOfLinear[u,x] returns g[a+b*x]; else it returns False. *)
InverseFunctionOfLinear[u_,x_Symbol] :=
  If[AtomQ[u] || CalculusQ[u] || FreeQ[u,x],
    False,
  If[InverseFunctionQ[u] && LinearQ[u[[1]],x],
    u,
  Module[{tmp},
  Catch[
    Scan[Function[If[NotFalseQ[tmp=InverseFunctionOfLinear[#,x]],Throw[tmp]]],u];
    False]]]]


TryPureTanSubst[u_,x_Symbol] :=
(*  Not[MatchQ[u,Log[v_]]] &&
  Not[MatchQ[u,f_[v_]^2 /; LinearQ[v,x]]] &&
  Not[MatchQ[u,ArcTan[a_.*Tan[v_]] /; FreeQ[a,x]]] &&
  Not[MatchQ[u,ArcTan[a_.*Cot[v_]] /; FreeQ[a,x]]] &&
  Not[MatchQ[u,ArcCot[a_.*Tan[v_]] /; FreeQ[a,x]]] &&
  Not[MatchQ[u,ArcCot[a_.*Cot[v_]] /; FreeQ[a,x]]] &&
  u===ExpandIntegrand[u,x] *)
  Not[MatchQ[u,F_[c_.*(a_.+b_.*G_[v_])] /; FreeQ[{a,b,c},x] && MemberQ[{ArcTan,ArcCot,ArcTanh,ArcCoth},F] && MemberQ[{Tan,Cot,Tanh,Coth},G] && LinearQ[v,x]]]


TryTanhSubst[u_,x_Symbol] :=
  FalseQ[FunctionOfLinear[u,x]] &&
  Not[MatchQ[u,r_.*(s_+t_)^n_. /; IntegerQ[n] && n>0]] &&
(*Not[MatchQ[u,Log[f_[x]^2] /; SinhCoshQ[f]]]  && *)
  Not[MatchQ[u,Log[v_]]]  &&
  Not[MatchQ[u,1/(a_+b_.*f_[x]^n_) /; SinhCoshQ[f] && IntegerQ[n] && n>2]] &&
  Not[MatchQ[u,f_[m_.*x]*g_[n_.*x] /; IntegersQ[m,n] && SinhCoshQ[f] && SinhCoshQ[g]]] &&
  Not[MatchQ[u,r_.*(a_.*s_^m_)^p_ /; FreeQ[{a,m,p},x] && Not[m===2 && (s===Sech[x] || s===Csch[x])]]] &&
  u===ExpandIntegrand[u,x]


TryPureTanhSubst[u_,x_Symbol] :=
  Not[MatchQ[u,Log[v_]]]  &&
  Not[MatchQ[u,ArcTanh[a_.*Tanh[v_]] /; FreeQ[a,x]]] &&
  Not[MatchQ[u,ArcTanh[a_.*Coth[v_]] /; FreeQ[a,x]]] &&
  Not[MatchQ[u,ArcCoth[a_.*Tanh[v_]] /; FreeQ[a,x]]] &&
  Not[MatchQ[u,ArcCoth[a_.*Coth[v_]] /; FreeQ[a,x]]] &&
  u===ExpandIntegrand[u,x]


InertTrigQ[f_] := MemberQ[{sin,cos,tan,cot,sec,csc},f]

InertTrigQ[f_,g_] := 
  If[f===g,
    InertTrigQ[f],
  InertReciprocalQ[f,g] || InertReciprocalQ[g,f]]

InertTrigQ[f_,g_,h_] := InertTrigQ[f,g] && InertTrigQ[g,h]


InertReciprocalQ[f_,g_] := f===sin && g===csc || f===cos && g===sec || f===tan && g===cot


InertTrigFreeQ[u_] := FreeQ[u,sin] && FreeQ[u,cos] && FreeQ[u,tan] && FreeQ[u,cot] && FreeQ[u,sec] && FreeQ[u,csc]


ActivateTrig[u_] :=
  ReplaceAll[u,{sin->Sin,cos->Cos,tan->Tan,cot->Cot,sec->Sec,csc->Csc}]


(* u is a function of trig functions of a linear function of x. *)
(* DeactivateTrig[u,x] returns u with the trig functions replaced with inert trig functions. *)
DeactivateTrig[u_,x_] :=
  FixInertTrigFunction[DeactivateTrigAux[u,x],x]


DeactivateTrigAux[u_,x_] :=
  If[AtomQ[u],
    u,
  If[TrigQ[u] && LinearQ[u[[1]],x],
    Module[{v=ExpandToSum[u[[1]],x]},
    If[SinQ[u],
      sin[v],
    If[CosQ[u],
      cos[v],
    If[TanQ[u],
      tan[v],
    If[CotQ[u],
      cot[v],
    If[SecQ[u],
      sec[v],
    csc[v]]]]]]],
  If[HyperbolicQ[u] && LinearQ[u[[1]],x],
    Module[{v=ExpandToSum[I*u[[1]],x]},
    If[SinhQ[u],
      -I*sin[v],
    If[CoshQ[u],
      cos[v],
    If[TanhQ[u],
      -I*tan[v],
    If[CothQ[u],
      I*cot[v],
    If[SechQ[u],
      sec[v],
    I*csc[v]]]]]]],
  Map[Function[DeactivateTrigAux[#,x]],u]]]]


Clear[FixInertTrigFunction]

FixInertTrigFunction[a_*u_,x_] :=
  a*FixInertTrigFunction[u,x] /;
FreeQ[a,x]


FixInertTrigFunction[sec[v_]^m_.*(c_.*sin[w_])^n_.,x_] :=
  FixInertTrigFunction[cos[v]^(-m)*(c*sin[w])^n,x] /;
FreeQ[{c,n},x] && IntegerQ[m]

FixInertTrigFunction[csc[v_]^m_.*(c_.*sin[w_])^n_.,x_] :=
  FixInertTrigFunction[sin[v]^(-m)*(c*sin[w])^n,x] /;
FreeQ[{c,n},x] && IntegerQ[m]

FixInertTrigFunction[sec[v_]^m_.*(c_.*cos[w_])^n_.,x_] :=
  FixInertTrigFunction[cos[v]^(-m)*(c*cos[w])^n,x] /;
FreeQ[{c,n},x] && IntegerQ[m]

FixInertTrigFunction[csc[v_]^m_.*(c_.*cos[w_])^n_.,x_] :=
  FixInertTrigFunction[sin[v]^(-m)*(c*cos[w])^n,x] /;
FreeQ[{c,n},x] && IntegerQ[m]

FixInertTrigFunction[sec[v_]^m_.*sec[w_]^n_.,x_] :=
  FixInertTrigFunction[cos[v]^(-m)*cos[w]^(-n),x] /;
IntegersQ[m,n]

FixInertTrigFunction[csc[v_]^m_.*csc[w_]^n_.,x_] :=
  FixInertTrigFunction[sin[v]^(-m)*sin[w]^(-n),x] /;
IntegersQ[m,n]


(* FixInertTrigFunction[u_.*csc[v_]^m_.*sec[v_]^n_.,x_] :=
  FixInertTrigFunction[u*sin[v]^(-m)*cos[v]^(-n),x] /;
FreeQ[{c,d},x] && IntegersQ[m,n] *)


FixInertTrigFunction[cot[v_]^m_.*(a_+b_.*(c_.*sin[w_])^p_.)^n_.,x_] :=
  FixInertTrigFunction[tan[v]^(-m)*(a+b*(c*sin[w])^p)^n,x] /;
FreeQ[{a,b,c,n,p},x] && IntegerQ[m]

FixInertTrigFunction[u_*tan[v_]^m_.*(a_+b_.*sin[w_])^n_.,x_] :=
  FixInertTrigFunction[u*sin[v]^m/cos[v]^m*(a+b*sin[w])^n,x] /;
FreeQ[{a,b,n},x] && IntegerQ[m]

FixInertTrigFunction[u_*cot[v_]^m_.*(a_+b_.*sin[w_])^n_.,x_] :=
  FixInertTrigFunction[u*cos[v]^m/sin[v]^m*(a+b*sin[w])^n,x] /;
FreeQ[{a,b,n},x] && IntegerQ[m]

FixInertTrigFunction[u_.*sec[v_]^m_.*w_,x_] :=
  FixInertTrigFunction[u*cos[v]^(-m)*w,x] /;
InertTrigSumQ[w,sin,x] && IntegerQ[m]

FixInertTrigFunction[u_.*csc[v_]^m_.*w_,x_] :=
  FixInertTrigFunction[u*sin[v]^(-m)*w,x] /;
InertTrigSumQ[w,sin,x] && IntegerQ[m]


FixInertTrigFunction[tan[v_]^m_.*(a_+b_.*(c_.*cos[w_])^p_.)^n_.,x_] :=
  FixInertTrigFunction[cot[v]^(-m)*(a+b*(c*cos[w])^p)^n,x] /;
FreeQ[{a,b,c,n,p},x] && IntegerQ[m]

FixInertTrigFunction[u_*tan[v_]^m_.*(a_+b_.*cos[w_])^n_.,x_] :=
  FixInertTrigFunction[u*sin[v]^m/cos[v]^m*(a+b*cos[w])^n,x] /;
FreeQ[{a,b,n},x] && IntegerQ[m]

FixInertTrigFunction[u_*cot[v_]^m_.*(a_+b_.*cos[w_])^n_.,x_] :=
  FixInertTrigFunction[u*cos[v]^m/sin[v]^m*(a+b*cos[w])^n,x] /;
FreeQ[{a,b,n},x] && IntegerQ[m]

FixInertTrigFunction[u_.*sec[v_]^m_.*w_,x_] :=
  FixInertTrigFunction[u*cos[v]^(-m)*w,x] /;
InertTrigSumQ[w,cos,x] && IntegerQ[m]

FixInertTrigFunction[u_.*csc[v_]^m_.*w_,x_] :=
  FixInertTrigFunction[u*sin[v]^(-m)*w,x] /;
InertTrigSumQ[w,cos,x] && IntegerQ[m]


FixInertTrigFunction[u_.*cot[v_]^m_.*w_,x_] :=
  FixInertTrigFunction[u*tan[v]^(-m)*w,x] /;
InertTrigSumQ[w,tan,x] && IntegerQ[m]

FixInertTrigFunction[u_.*sec[v_]^m_.*w_,x_] :=
  FixInertTrigFunction[u*cos[v]^(-m)*w,x] /;
InertTrigSumQ[w,tan,x] && IntegerQ[m]

FixInertTrigFunction[u_.*csc[v_]^m_.*w_,x_] :=
  FixInertTrigFunction[u*sin[v]^(-m)*w,x] /;
InertTrigSumQ[w,tan,x] && IntegerQ[m]


FixInertTrigFunction[u_.*tan[v_]^m_.*w_,x_] :=
  FixInertTrigFunction[u*cot[v]^(-m)*w,x] /;
InertTrigSumQ[w,cot,x] && IntegerQ[m]

FixInertTrigFunction[u_.*sec[v_]^m_.*w_,x_] :=
  FixInertTrigFunction[u*cos[v]^(-m)*w,x] /;
InertTrigSumQ[w,cot,x] && IntegerQ[m]

FixInertTrigFunction[u_.*csc[v_]^m_.*w_,x_] :=
  FixInertTrigFunction[u*sin[v]^(-m)*w,x] /;
InertTrigSumQ[w,cot,x] && IntegerQ[m]


FixInertTrigFunction[u_.*cos[v_]^m_.*w_,x_] :=
  FixInertTrigFunction[u*sec[v]^(-m)*w,x] /;
InertTrigSumQ[w,sec,x] && IntegerQ[m]

FixInertTrigFunction[u_.*cot[v_]^m_.*w_,x_] :=
  FixInertTrigFunction[u*tan[v]^(-m)*w,x] /;
InertTrigSumQ[w,sec,x] && IntegerQ[m]

FixInertTrigFunction[u_.*csc[v_]^m_.*w_,x_] :=
  FixInertTrigFunction[u*sin[v]^(-m)*w,x] /;
InertTrigSumQ[w,sec,x] && IntegerQ[m]


FixInertTrigFunction[u_.*sin[v_]^m_.*w_,x_] :=
  FixInertTrigFunction[u*csc[v]^(-m)*w,x] /;
InertTrigSumQ[w,csc,x] && IntegerQ[m]

FixInertTrigFunction[u_.*tan[v_]^m_.*w_,x_] :=
  FixInertTrigFunction[u*cot[v]^(-m)*w,x] /;
InertTrigSumQ[w,csc,x] && IntegerQ[m]

FixInertTrigFunction[u_.*sec[v_]^m_.*w_,x_] :=
  FixInertTrigFunction[u*cos[v]^(-m)*w,x] /;
InertTrigSumQ[w,csc,x] && IntegerQ[m]


FixInertTrigFunction[u_.*tan[v_]^m_.*(a_.*sin[v_]+b_.*cos[v_])^n_.,x_] :=
  FixInertTrigFunction[u*sin[v]^m*cos[v]^(-m)*(a*sin[v]+b*cos[v])^n,x] /;
FreeQ[{a,b,n},x] && IntegerQ[m]

FixInertTrigFunction[u_.*cot[v_]^m_.*(a_.*sin[v_]+b_.*cos[v_])^n_.,x_] :=
  FixInertTrigFunction[u*cos[v]^m*sin[v]^(-m)*(a*sin[v]+b*cos[v])^n,x] /;
FreeQ[{a,b,n},x] && IntegerQ[m]

FixInertTrigFunction[u_.*sec[v_]^m_.*(a_.*sin[v_]+b_.*cos[v_])^n_.,x_] :=
  FixInertTrigFunction[u*cos[v]^(-m)*(a*sin[v]+b*cos[v])^n,x] /;
FreeQ[{a,b,n},x] && IntegerQ[m]

FixInertTrigFunction[u_.*csc[v_]^m_.*(a_.*sin[v_]+b_.*cos[v_])^n_.,x_] :=
  FixInertTrigFunction[u*sin[v]^(-m)*(a*sin[v]+b*cos[v])^n,x] /;
FreeQ[{a,b,n},x] && IntegerQ[m]


FixInertTrigFunction[f_[v_]^m_.*(A_.+B_.*g_[v_]+C_.*g_[v_]^2),x_] :=
  g[v]^(-m)*(A+B*g[v]+C*g[v]^2) /;
FreeQ[{A,B,C},x] && IntegerQ[m] && (InertReciprocalQ[f,g] || InertReciprocalQ[g,f])

FixInertTrigFunction[f_[v_]^m_.*(A_.+C_.*g_[v_]^2),x_] :=
  g[v]^(-m)*(A+C*g[v]^2) /;
FreeQ[{A,C},x] && IntegerQ[m] && (InertReciprocalQ[f,g] || InertReciprocalQ[g,f])


FixInertTrigFunction[f_[v_]^m_.*(A_.+B_.*g_[v_]+C_.*g_[v_]^2)*(a_.+b_.*g_[v_])^n_.,x_] :=
  g[v]^(-m)*(A+B*g[v]+C*g[v]^2)*(a+b*g[v])^n /;
FreeQ[{a,b,A,B,C,n},x] && IntegerQ[m] && (InertReciprocalQ[f,g] || InertReciprocalQ[g,f])

FixInertTrigFunction[f_[v_]^m_.*(A_.+C_.*g_[v_]^2)*(a_.+b_.*g_[v_])^n_.,x_] :=
  g[v]^(-m)*(A+C*g[v]^2)*(a+b*g[v])^n /;
FreeQ[{a,b,A,C,n},x] && IntegerQ[m] && (InertReciprocalQ[f,g] || InertReciprocalQ[g,f])


FixInertTrigFunction[u_,x_] := u


InertTrigSumQ[u_,func_,x_] :=
  MatchQ[u, (a_+b_.*(c_.*func[w_])^p_.)^n_. /; FreeQ[{a,b,c,n,p},x]] || 
  MatchQ[u, (a_.+b_.*(d_.*func[w_])^p_.+c_.*(d_.*func[w_])^q_.)^n_. /; FreeQ[{a,b,c,d,n,p,q},x]]


(* If the derivative of u wrt x is a constant wrt x, PiecewiseLinearQ[u,x] returns True;
	else it returns False. *)
PiecewiseLinearQ[u_,v_,x_Symbol] :=
  PiecewiseLinearQ[u,x] && PiecewiseLinearQ[v,x]

PiecewiseLinearQ[u_,x_Symbol] :=
  LinearQ[u,x] (* && Not[MonomialQ[u,x]] *) || 
  MatchQ[u,Log[c_.*F_^(v_)] /; FreeQ[{F,c},x] && LinearQ[v,x]] || 
  MatchQ[u,F_[G_[v_]] /; LinearQ[v,x] && MemberQ[{
	{ArcTanh,Tanh},{ArcTanh,Coth},{ArcCoth,Coth},{ArcCoth,Tanh},
	{ArcTan,Tan},{ArcTan,Cot},{ArcCot,Cot},{ArcCot,Tan}
   },{F,G}]]


(* If u divided by y is free of x, Divides[y,u,x] returns the quotient; else it returns False. *)
Divides[y_,u_,x_Symbol] :=
  Module[{v=Simplify[u/y]},
  If[FreeQ[v,x],
    v,
  False]]


(* If y not equal to x, y is easy to differentiate wrt x, and u divided by the derivative of y 
  is free of x, DerivativeDivides[y,u,x] returns the quotient; else it returns False. *)
DerivativeDivides[y_,u_,x_Symbol] :=
  If[MatchQ[y,a_.*x /; FreeQ[a,x]],
    False,
  If[If[PolynomialQ[y,x], PolynomialQ[u,x] && Exponent[u,x]==Exponent[y,x]-1, EasyDQ[y,x]],
    Module[{v=Block[{ShowSteps=False}, D[y,x]]},
    If[ZeroQ[v],
      False,
    v=Simplify[u/v];
    If[FreeQ[v,x],
      v,
    False]]],
  False]]


(* If u is easy to differentiate wrt x, EasyDQ[u,x] returns True; else it returns False. *)
EasyDQ[u_.*x_^m_.,x_Symbol] :=
  EasyDQ[u,x] /;
FreeQ[m,x]

EasyDQ[u_,x_Symbol] :=
  If[AtomQ[u] || FreeQ[u,x] || Length[u]==0,
    True,
  If[CalculusQ[u],
    False,
  If[Length[u]==1,
    EasyDQ[u[[1]],x],
  If[BinomialQ[u,x] || ProductOfLinearPowersQ[u,x],
    True,
  If[RationalFunctionQ[u,x] && RationalFunctionExponents[u,x]==={1,1},
    True,
  If[ProductQ[u],
    If[FreeQ[First[u],x],
      EasyDQ[Rest[u],x],
    If[FreeQ[Rest[u],x],
      EasyDQ[First[u],x],
    False]],
  If[SumQ[u],
    EasyDQ[First[u],x] && EasyDQ[Rest[u],x],
  If[Length[u]==2,
    If[FreeQ[u[[1]],x],
      EasyDQ[u[[2]],x],
    If[FreeQ[u[[2]],x],
      EasyDQ[u[[1]],x],
    False]],
  False]]]]]]]]


(* ProductOfLinearPowersQ[u,x] returns True iff u is a product of factors of the form v^n where v is linear in x. *)
ProductOfLinearPowersQ[u_,x_Symbol] :=
  FreeQ[u,x] ||
  MatchQ[u, v_^n_. /; LinearQ[v,x] && FreeQ[n,x]] || 
  ProductQ[u] && ProductOfLinearPowersQ[First[u],x] && ProductOfLinearPowersQ[Rest[u],x]


Clear[Rt,RtAux];


Rt[u_,n_Integer] :=
  RtAux[TogetherSimplify[u],n]


RtAux[u_^m_,n_] :=
  1/RtAux[u^-m,n] /;
RationalQ[m] && m<0

RtAux[v_.*u_^w_,n_] :=
  Module[{m=Numerator[NumericFactor[w]]},
  RtAux[v,n]*RtAux[u^(w/m),n/GCD[m,n]]^(m/GCD[m,n]) /;
 m>1] /;
Not[NegativeOrZeroQ[v]]


RtAux[u_,n_] :=
  Map[Function[RtAux[#,n]],u] /;
ProductQ[u] && OddQ[n]

RtAux[u_,n_] :=
  Module[{i}, Catch[
  Do[If[PositiveQ[u[[i]]],
       Throw[RtAux[u[[i]],n]*RtAux[Delete[u,i],n]]],
    {i,1,Length[u]}];
  Do[If[NegativeQ[u[[i]]] && NonzeroQ[u[[i]]+1],
       Throw[RtAux[-u[[i]],n]*RtAux[-Delete[u,i],n]]],
    {i,1,Length[u]}];
  If[u[[1]]===-1,
    Do[If[SumQ[u[[i]]] && (NegQ[u[[i,1]]] || NegQ[u[[i,2]]]),
         Throw[RtAux[-First[u[[i]]] - Rest[u[[i]]],n]*RtAux[-Delete[u,i],n]]],
      {i,2,Length[u]}];
    Do[If[PowerQ[u[[i]]] && OddQ[u[[i,2]]] && SumQ[u[[i,1]]] && (NegQ[u[[i,1,1]]] || NegQ[u[[i,1,2]]]),
         Throw[RtAux[(-First[u[[i,1]]] - Rest[u[[i,1]]])^u[[i,2]],n]*RtAux[-Delete[u,i],n]]],
      {i,2,Length[u]}];
    Do[If[AtomQ[u[[i]]],
         Throw[RtAux[-u[[i]],n]*RtAux[-Delete[u,i],n]]],
      {i,2,Length[u]}];
    RtAux[-u[[2]],n]*RtAux[Drop[u,2],n],
  Do[If[Not[FreeQ[Delete[u,i],RtAux[-u[[i]],n]]],
       Throw[RtAux[-u[[i]],n]*RtAux[-Delete[u,i],n]]],
    {i,1,Length[u]}];
  Map[Function[RtAux[#,n]],u]]]] /;
ProductQ[u] && EvenQ[n] && Not[u[[1]]===-1 && Length[u]==2]


RtAux[u_,n_] :=
  -RtAux[-u,n] /;
OddQ[n] && NegativeQ[u]

RtAux[u_,n_] :=
  u^(1/n)


(* If u is free of x or of the form c*(a+b*x)^m, IntSum[u,x] returns the antiderivative of u wrt x; 
	else it returns d*Int[v,x] where d*v=u and d is free of x. *)
IntSum[u_,x_Symbol] :=
  Simp[FreeTerms[u,x]*x,x] + IntTerm[NonfreeTerms[u,x],x]


(* If u is of the form c*(a+b*x)^m, IntTerm[u,x] returns the antiderivative of u wrt x; 
	else it returns d*Int[v,x] where d*v=u and d is free of x. *)
IntTerm[c_./v_,x_Symbol] :=
  Simp[c*Log[RemoveContent[v,x]]/Coefficient[v,x,1],x] /;
FreeQ[c,x] && LinearQ[v,x]

IntTerm[c_.*v_^m_.,x_Symbol] :=
  Simp[c*v^(m+1)/(Coefficient[v,x,1]*(m+1)),x] /;
FreeQ[{c,m},x] && NonzeroQ[m+1] && LinearQ[v,x]

IntTerm[u_,x_Symbol] :=
  Map[Function[IntTerm[#,x]],u] /;
SumQ[u]

IntTerm[u_,x_Symbol] :=
  Dist[FreeFactors[u,x], Int[NonfreeFactors[u,x],x], x]


(* SimplerIntegrandQ[u,v,x] returns True iff u is simpler to integrate wrt x than v. *)
SimplerIntegrandQ[u_,v_,x_Symbol] :=
  Module[{lst=CancelCommonFactors[u,v],u1,v1},
  u1=lst[[1]];
  v1=lst[[2]];
(*If[Head[u1]===Head[v1] && Length[u1]==Length[v1]==1,
    SimplerIntegrandQ[u1[[1]],v1[[1]],x], *)
  If[LeafCount[u1]<3/4*LeafCount[v1],
    True,
  If[RationalFunctionQ[u1,x],
    If[RationalFunctionQ[v1,x],
      Apply[Plus,RationalFunctionExponents[u1,x]]<Apply[Plus,RationalFunctionExponents[v1,x]],
    True],
  False]]]


(* CancelCommonFactors[u,v] returns {u',v'} are the noncommon factors of u and v respectively. *)
CancelCommonFactors[u_,v_] :=
  If[ProductQ[u],
    If[ProductQ[v],
      If[MemberQ[v,First[u]],
        CancelCommonFactors[Rest[u],DeleteCases[v,First[u],1,1]],
      Function[{First[u]*#[[1]],#[[2]]}][CancelCommonFactors[Rest[u],v]]],
    If[MemberQ[u,v],
      {DeleteCases[u,v,1,1],1},
    {u,v}]],
  If[ProductQ[v],
    If[MemberQ[v,u],
      {1,DeleteCases[v,u,1,1]},
    {u,v}],
  {u,v}]]


(* SumSimplerQ[u,v] returns True iff for every term w of v there is a term of u
	equal to n*w where n<-1/2. Therefore if True, u+v will be simpler than u. *)
SumSimplerQ[u_,v_] :=
  If[RationalQ[u,v],
    If[v==0,
      False,
    If[v>0,
      u<-1,
    u>=-v]],
  SumSimplerAuxQ[Expand[u],Expand[v]]]


SumSimplerAuxQ[u_,v_] :=
  (RationalQ[First[v]] || SumSimplerAuxQ[u,First[v]]) && 
  (RationalQ[Rest[v]] || SumSimplerAuxQ[u,Rest[v]]) /;
SumQ[v]

SumSimplerAuxQ[u_,v_] :=
  SumSimplerAuxQ[First[u],v] || SumSimplerAuxQ[Rest[u],v] /;
SumQ[u]

SumSimplerAuxQ[u_,v_] :=
  v=!=0 && 
  NonnumericFactors[u]===NonnumericFactors[v] && 
  (NumericFactor[u]/NumericFactor[v]<-1/2 || NumericFactor[u]/NumericFactor[v]==-1/2 && NumericFactor[u]<0)  


(* SimplerSqrtQ[u,v] returns True iff Rt[u,2] is simpler than Rt[v,2]. *)
SimplerSqrtQ[u_,v_] :=
  Module[{sqrtu=Rt[u,2],sqrtv=Rt[v,2]},
  If[IntegerQ[sqrtu],
    If[IntegerQ[sqrtv],
      sqrtu<sqrtv,
    True],
  If[IntegerQ[sqrtv],
    False,
  If[RationalQ[Rt[sqrtu]],
    If[RationalQ[sqrtv],
      sqrtu<sqrtv,
    True],
  If[RationalQ[sqrtv],
    False,
  If[PosQ[u],
    If[PosQ[v],
      LeafCount[sqrtu]<LeafCount[sqrtv],
    True],
  If[PosQ[v],
    False,
  LeafCount[sqrtu]<LeafCount[sqrtv]]]]]]]]


ClearAll[FixIntRules,FixIntRule,FixRhsIntRule]


FixIntRules[] :=
  (DownValues[Int]=FixIntRules[DownValues[Int]]; Null)


FixIntRules[rulelist_] :=
  Module[{IntDownValues=DownValues[Int],SubstDownValues=DownValues[Subst],
	SimpDownValues=DownValues[Simp],DistDownValues=DownValues[Dist],lst,object},
  object=PrintTemporary[Row[{"Modifying ",Length[rulelist]," integration rules to distribute coefficients over sums..."}]];
  Clear[Int,Subst,Simp,Dist];
  SetAttributes[{Simp,Dist,Int,Subst},HoldAll];
  lst=Map[Function[FixIntRule[#,#[[1,1,2,1]]]],rulelist];
  DownValues[Int]=IntDownValues;
  DownValues[Subst]=SubstDownValues;
  DownValues[Simp]=SimpDownValues;
  DownValues[Dist]=DistDownValues;
  ClearAttributes[{Simp,Dist,Int,Subst},HoldAll];
  NotebookDelete[object];
  lst]


FixIntRule[RuleDelayed[lhs_,F_[G_[list_,F_[u_+v_,test2_]],test1_]],x_] :=
  ReplacePart[RuleDelayed[lhs,Condition[Module[list,Condition[u+v,test2]],test1]],{{2,1,2,1,1}->FixRhsIntRule[u,x],{2,1,2,1,2}->FixRhsIntRule[v,x]}] /;
F===Condition && G===Module

FixIntRule[RuleDelayed[lhs_,G_[list_,F_[u_+v_,test2_]]],x_] :=
  ReplacePart[RuleDelayed[lhs,Module[list,Condition[u+v,test2]]],{{2,2,1,1}->FixRhsIntRule[u,x],{2,2,1,2}->FixRhsIntRule[v,x]}] /;
F===Condition && G===Module

FixIntRule[RuleDelayed[lhs_,F_[G_[list_,u_+v_],test_]],x_] :=
  ReplacePart[RuleDelayed[lhs,Condition[Module[list,u+v],test]],{{2,1,2,1}->FixRhsIntRule[u,x],{2,1,2,2}->FixRhsIntRule[v,x]}] /;
F===Condition && G===Module

FixIntRule[RuleDelayed[lhs_,G_[list_,u_+v_]],x_] :=
  ReplacePart[RuleDelayed[lhs,Module[list,u+v]],{{2,2,1}->FixRhsIntRule[u,x],{2,2,2}->FixRhsIntRule[v,x]}] /;
G===Module

FixIntRule[RuleDelayed[lhs_,F_[u_+v_,test_]],x_] :=
  ReplacePart[RuleDelayed[lhs,Condition[u+v,test]],{{2,1,1}->FixRhsIntRule[u,x],{2,1,2}->FixRhsIntRule[v,x]}] /;
F===Condition

FixIntRule[RuleDelayed[lhs_,u_+v_],x_] :=
  ReplacePart[RuleDelayed[lhs,u+v],{{2,1}->FixRhsIntRule[u,x],{2,2}->FixRhsIntRule[v,x]}]


FixIntRule[RuleDelayed[lhs_,F_[G_[list1_,F_[G_[list2_,u_],test2_]],test1_]],x_] :=
  ReplacePart[RuleDelayed[lhs,Condition[Module[list1,Condition[Module[list2,u],test2]],test1]],{2,1,2,1,2}->FixRhsIntRule[u,x]] /;
F===Condition && G===Module

FixIntRule[RuleDelayed[lhs_,F_[G_[list_,F_[H_[str1_,str2_,str3_,J_[u_]],test2_]],test1_]],x_] :=
  ReplacePart[RuleDelayed[lhs,Condition[Module[list,Condition[ShowStep[str1,str2,str3,Hold[u]],test2]],test1]],{2,1,2,1,4,1}->FixRhsIntRule[u,x]] /;
F===Condition && G===Module && H===ShowStep && J===Hold

FixIntRule[RuleDelayed[lhs_,F_[G_[list_,F_[u_,test2_]],test1_]],x_] :=
  ReplacePart[RuleDelayed[lhs,Condition[Module[list,Condition[u,test2]],test1]],{2,1,2,1}->FixRhsIntRule[u,x]] /;
F===Condition && G===Module

FixIntRule[RuleDelayed[lhs_,G_[list_,F_[u_,test2_]]],x_] :=
  ReplacePart[RuleDelayed[lhs,Module[list,Condition[u,test2]]],{2,2,1}->FixRhsIntRule[u,x]] /;
F===Condition && G===Module

FixIntRule[RuleDelayed[lhs_,F_[G_[list_,u_],test_]],x_] :=
  ReplacePart[RuleDelayed[lhs,Condition[Module[list,u],test]],{2,1,2}->FixRhsIntRule[u,x]] /;
F===Condition && G===Module

FixIntRule[RuleDelayed[lhs_,G_[list_,u_]],x_] :=
  ReplacePart[RuleDelayed[lhs,Module[list,u]],{2,2}->FixRhsIntRule[u,x]] /;
G===Module

FixIntRule[RuleDelayed[lhs_,F_[u_,test_]],x_] :=
  ReplacePart[RuleDelayed[lhs,Condition[u,test]],{2,1}->FixRhsIntRule[u,x]] /;
F===Condition

FixIntRule[RuleDelayed[lhs_,u_],x_] :=
  ReplacePart[RuleDelayed[lhs,u],{2}->FixRhsIntRule[u,x]]


SetAttributes[FixRhsIntRule,HoldAll];

FixRhsIntRule[u_+v_,x_] :=
  FixRhsIntRule[u,x]+FixRhsIntRule[v,x]

FixRhsIntRule[u_-v_,x_] :=
  FixRhsIntRule[u,x]-FixRhsIntRule[v,x]

FixRhsIntRule[-u_,x_] :=
  -FixRhsIntRule[u,x]

FixRhsIntRule[a_*u_,x_] :=
  Dist[a,u,x] /;
MemberQ[{Int,Subst},Head[Unevaluated[u]]]

FixRhsIntRule[u_,x_] :=
  If[Head[Unevaluated[u]]===Dist && Length[Unevaluated[u]]==2,
    Insert[Unevaluated[u],x,3],
  If[MemberQ[{Int,Subst,Defer[Int],Simp,Dist},Head[Unevaluated[u]]],
    u,
  Simp[u,x]]]
