module PairExtensionTest01

point1 = \ a : Nat . \ b : Nat . \ s : Nat -> Nat -> Nat . s a b 1 2 ;
point2 = \ a : Nat . \ b : Nat . \ s : Nat -> Nat -> Nat . s a b 2 3 ;
n = point2 \ a : Nat . \ b : Nat . a + point1 \ a : Nat . \ b : Nat . b ;