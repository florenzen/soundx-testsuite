module LetPairExtensionTest02

test01 = \ a : Nat . \ a : Nat . \ b : Nat . \ s : Nat -> Nat -> Nat . s a b a a
1 ;
test02 = \ l : Nat . \ r : Nat . \ s : Nat . s r + l test01 \ a : Nat . \ b :
Nat . a test01 \ a : Nat . \ b : Nat . b ;