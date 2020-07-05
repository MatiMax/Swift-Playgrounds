/**
Name:      Factorial.playground
Purpose:   Demonstrate a "classic" recursion.
Version:   1.0 (11-06-2020)
Language:  Swift
Author:    Matthias M. Schneider
Copyright: IDC (I don't care)
*/

func factorial(_ factor: Int) -> Int {
     guard factor >= 0 else {
         print("\u{1b}[37;41m Error: \u{1b}[0m Will not calculate factorial of negative numbers, returning zero instead. Thanks and good bye.")
         return 0
     }
     switch factor {
         case 0, 1:
             return 1
         default:
             return factor * factorial(factor - 1)
     }
 }

print("Fact(5) = \(factorial(5))")
print("Fact(-42) = \(factorial(-42))")
