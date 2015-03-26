module LetPairExtensionTest01

test01 = \ a : Nat . a 1 ;
test02 = \ f : Nat . \ s : Nat . f + s \ a : Nat . \ b : Nat . \ s : Nat -> Nat
-> Nat . s a b 1 2 \ a : Nat . \ b : Nat . a \ a : Nat . \ b : Nat . \ s : Nat
-> Nat -> Nat . s a b 1 2 \ a : Nat . \ b : Nat . b ;
test03 = \ a : Nat . \ b : Nat . \ s : Nat -> Nat -> Nat . s a b 4 7 + 0 ;
test04 = \ x : Nat . \ y : Nat . \ a : Nat . \ b : Nat . \ s : Nat -> Nat -> Nat
. s a b y x test03 \ a : Nat . \ b : Nat . a test03 \ a : Nat . \ b : Nat . b ;