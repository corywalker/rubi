(* ::Package:: *)

(************************************************************************)
(* This file was generated automatically by the Mathematica front end.  *)
(* It contains Initialization cells from a Notebook file, which         *)
(* typically will have the same name as this file except ending in      *)
(* ".nb" instead of ".m".                                               *)
(*                                                                      *)
(* This file is intended to be loaded into the Mathematica kernel using *)
(* the package loading commands Get or Needs.  Doing so is equivalent   *)
(* to using the Evaluate Initialization Cells menu command in the front *)
(* end.                                                                 *)
(*                                                                      *)
(* DO NOT EDIT THIS FILE.  This entire file is regenerated              *)
(* automatically each time the parent Notebook file is saved in the     *)
(* Mathematica front end.  Any changes you make to this file will be    *)
(* overwritten.                                                         *)
(************************************************************************)



(* ::Code:: *)
(* Int[u_.*(v_+w_)^p_.,x_Symbol] :=
  Int[u*w^p,x] /;
FreeQ[p,x] && ZeroQ[v] *)


(* ::Code:: *)
Int[u_.*(a_+b_.*x_^n_.)^p_.,x_Symbol] :=
  Int[u*(b*x^n)^p,x] /;
FreeQ[{a,b,n,p},x] && ZeroQ[a]


(* ::Code:: *)
Int[u_.*(a_.+b_.*x_^n_.)^p_.,x_Symbol] :=
  Int[u*a^p,x] /;
FreeQ[{a,b,n,p},x] && ZeroQ[b]


(* ::Code:: *)
Int[u_.*(a_+b_.*x_^n_.+c_.*x_^j_.)^p_.,x_Symbol] :=
  Int[u*(b*x^n+c*x^(2*n))^p,x] /;
FreeQ[{a,b,c,n,p},x] && ZeroQ[j-2*n] && ZeroQ[a]


(* ::Code:: *)
Int[u_.*(a_.+b_.*x_^n_.+c_.*x_^j_.)^p_.,x_Symbol] :=
  Int[u*(a+c*x^(2*n))^p,x] /;
FreeQ[{a,b,c,n,p},x] && ZeroQ[j-2*n] && ZeroQ[b]


(* ::Code:: *)
Int[u_.*(a_.+b_.*x_^n_.+c_.*x_^j_.)^p_.,x_Symbol] :=
  Int[u*(a+b*x^n)^p,x] /;
FreeQ[{a,b,c,n,p},x] && ZeroQ[j-2*n] && ZeroQ[c]


(* ::Code:: *)
(* Int[u_.*v_^m_,x_Symbol] :=
  Int[u/v,x] /;
ZeroQ[m+1] && m=!=-1 *)


(* ::Code:: *)
Int[u_.*x_^m_,x_Symbol] :=
  Int[u/x,x] /;
ZeroQ[m+1] && m=!=-1


(* ::Code:: *)
Int[a_,x_Symbol] :=
   a*x /;
FreeQ[a,x]


(* ::Code:: *)
Int[a_*(b_+c_.*x_),x_Symbol] :=
  a*(b+c*x)^2/(2*c) /;
FreeQ[{a,b,c},x]


(* ::Code:: *)
Int[-u_,x_Symbol] :=
  Identity[-1]*Int[u,x]


(* ::Code:: *)
Int[Complex[0,a_]*u_,x_Symbol] :=
  Complex[Identity[0],a]*Int[u,x] /;
FreeQ[a,x] && OneQ[a^2]


(* ::Code:: *)
Int[a_*u_,x_Symbol] :=
  a*Int[u,x] /;
FreeQ[a,x] && Not[MatchQ[u, b_*v_ /; FreeQ[b,x]]]


(* ::Code:: *)
If[ShowSteps,

Int[u_,x_Symbol] :=
  ShowStep["","Int[a*u + b*v + \[CenterEllipsis],x]","a*Integrate[u,x] + b*Integrate[v,x] + \[CenterEllipsis]",Hold[
  IntSum[u,x]]] /;
SimplifyFlag && SumQ[u],

Int[u_,x_Symbol] :=
  IntSum[u,x] /;
SumQ[u]]


(* ::Code:: *)
Int[u_.*(a_+b_.*x_^n_.)^m_.*(c_+d_.*x_^n_.)^p_.,x_Symbol] :=
  (b/d)^m*Int[u*(c+d*x^n)^(m+p),x] /;
FreeQ[{a,b,c,d,m,n,p},x] && ZeroQ[b*c-a*d] && (IntegerQ[m] || PositiveQ[b/d]) && 
  (Not[IntegerQ[p]] || LeafCount[c+d*x]<=LeafCount[a+b*x])


(* ::Code:: *)
Int[u_.*(a_+b_.*x_^n_.)^m_.*(c_+d_.*x_^n_.)^p_.,x_Symbol] :=
  (a+b*x^n)^m/(c+d*x^n)^m*Int[u*(c+d*x^n)^(m+p),x] /;
FreeQ[{a,b,c,d,m,n,p},x] && ZeroQ[b*c-a*d] && Not[IntegerQ[m] || IntegerQ[p] || PositiveQ[b/d]]


(* ::Code:: *)
Int[u_.*(a_+b_.*x_^n_.)^m_.*(c_+d_.*x_^q_.)^p_.,x_Symbol] :=
  (d/a)^p*Int[u*(a+b*x^n)^(m+p)/x^(n*p),x] /;
FreeQ[{a,b,c,d,m,n},x] && ZeroQ[n+q] && IntegerQ[p] && ZeroQ[a*c-b*d] && Not[IntegerQ[m] && NegQ[n]]


(* ::Code:: *)
Int[u_.*(a_+b_.*x_^n_.)^m_.*(c_+d_.*x_^j_)^p_.,x_Symbol] :=
  (-b^2/d)^m*Int[u*(a-b*x^n)^(-m),x] /;
FreeQ[{a,b,c,d,m,n,p},x] && ZeroQ[j-2*n] && ZeroQ[m+p] && ZeroQ[b^2*c+a^2*d] && PositiveQ[a] && NegativeQ[d]


(* ::Code:: *)
Int[u_.*(c_.*(a_.+b_.* x_)^n_)^p_,x_Symbol] :=
  c^(p-1/2)*Sqrt[c*(a+b*x)^n]/(a+b*x)^(n/2)*Int[u*(a+b*x)^(n*p),x] /;
FreeQ[{a,b,c,n,p},x] && PositiveIntegerQ[p+1/2]


(* ::Code:: *)
Int[u_.*(c_.*(a_.+b_.* x_)^n_)^p_,x_Symbol] :=
  c^(p+1/2)*(a+b*x)^(n/2)/Sqrt[c*(a+b*x)^n]*Int[u*(a+b*x)^(n*p),x] /;
FreeQ[{a,b,c,n,p},x] && NegativeIntegerQ[p-1/2]


(* ::Code:: *)
Int[u_.*(c_.*(a_.+b_.* x_)^n_)^p_,x_Symbol] :=
  (c*(a+b*x)^n)^p/((a+b*x)^(n*p))*Int[u*(a+b*x)^(n*p),x] /;
FreeQ[{a,b,c,n,p},x] && Not[IntegerQ[2*p]]


(* ::Code:: *)
Int[u_.*(a_.*(b_*x_)^p_)^q_,x_Symbol] :=
  (a*(b*x)^p)^q/x^(p*q)*Int[u*x^(p*q),x] /;
FreeQ[{a,b,p,q},x] && Not[IntegerQ[p]] && Not[IntegerQ[q]]


(* ::Code:: *)
Int[u_.*(a_.*(b_.*x_^n_)^p_)^q_,x_Symbol] :=
  (a*(b*x^n)^p)^q/x^(n*p*q)*Int[u*x^(n*p*q),x] /;
FreeQ[{a,b,n,p,q},x] && Not[IntegerQ[p]] && Not[IntegerQ[q]]


(* ::Code:: *)
Int[u_.*(a_.*x_^r_.+b_.*x_^s_.)^m_.,x_Symbol] :=
  Int[u*x^(m*r)*(a+b*x^(s-r))^m,x] /;
FreeQ[{a,b,m,r,s},x] && IntegerQ[m] && PosQ[s-r]



