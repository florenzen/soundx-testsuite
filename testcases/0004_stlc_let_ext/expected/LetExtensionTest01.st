module LetExtensionTest01

test01 = \ a : Nat . \ b : Nat . a + b 2 1 ;
test02 = 1 + \ f : Nat -> Nat . f 2 \ x : Nat . x ;