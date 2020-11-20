/**
Name:      Tail Recursion.playground
Purpose:   Demonstrate the differences between "classic" and tail recursions.
Version:   1.0 (11-06-2020)
Language:  Swift
Author:    Matthias M. Schneider
Copyright: IDC (I don't care)
*/
/*:
 # Using Tail Recursions — And Why
 
 In computing history the method of using recursive functions to solve certain types of problems has a long tradition. One of the most cited use of recursions in computer sience seems to be the [Ackermann function](https://en.wikipedia.org/wiki/Ackermann_function). But any other function like the factorial function or the [Fibonacci number](https://en.wikipedia.org/wiki/Fibonacci_number) are good and well known examples of recursive functions. This playground demonstrates — yet again — the beauty of Swift for one type of implementation.
 
 # Understanding tail recursions
 A "classic" recursion on a computer system will use what's called a [stack](https://en.wikipedia.org/wiki/Stack_(abstract_data_type)) to push the previous iteration of the complete function onto a pile (a memory location in your computer). This type of recursion then has to be [unwound](https://en.wikipedia.org/wiki/Call_stack#Unwinding) when the recursion hits its last iteration. Now, a stack cannot be physically infinit, they are limited by the operating system, the runtime environment and the programming language you are using. It is safe to say that for educational numbers of iterations almost any computer system will execute a recursive algorithm just fine withour running out of memory and throwing nasty error messages at you. But if things get more enthusiastic this might not hold true. Also, using a stack can pose a quite big impact on the performance, and even security, of a computer system (see [stack overflow](https://en.wikipedia.org/wiki/Stack_overflow)). Visualizing a recursion using a call stack for a given function
 
 _f_(_n_) = _f_(_n_ – 1) for _n_ > 0
 
 would look something like this:
 
    f(f(f(f(4))))
 
 Rewriting it on separate lines it would result in this:
 
    f(
      f(
        f(
          f(4)
         )
       )
     )
 
 We can therefore asume that each indentation which represents an iteration causes the memory usage to increase and the performance to decrease as at the last iteration the call stack has to be unwound to replace the result into its predecessing function calls.
 
 The [tail recursion](https://en.wikipedia.org/wiki/Tail_call) — or tail call — still uses a stack, but instead of saving the complete function for each iteration and then having to use unwinding to climb up the call stack it can just execute the function for an iteration in form of a simple list replacing values in the list, thus saving memory and having far less impact on performance for large amouts of recursions (deep recursions).
 
 The stack of the same function would look something like this:
 
    f(n)
       replace n with n - 1
       replace n - 1 with n - 2
       replace n - 2 with n - 3
       replace n - 3 with n - 4
       return n - 4
 
 In terms of indentations we used just one and therefore we spare us the hassle of unwinding.
 
 The following two functions implement the factorial and the Fibonacci numbers using tail recursion. Swift makes the implementation very clean and understandable as we can write the theory of tail recursion using `switch` statemens and pattern matching `case` statements. Beautiful. ❤️
 
 ## Factorial
 
 We use the initialised parameter `p` to save us from having to supply this arbitrary value when calling the function. This function has one special case where we return the product (the end result) as soon as `n` becomes a value of `1`. Otherwise the function will `let` the parameters and return a factorial based on the `n - 1`th iteration with `p` holding the product of both `n ` and the value of `p_prev` which is ***the already calculated*** product of the previous iteration.
  */
func factorial(_ n: Int, p: Int = 1) -> Int {
    switch (n, p) {
        case (1, let p): return p
        case (let n, let p_prev): return factorial(n - 1, p: n * p_prev)
    }
}

factorial(4) // results in 24
/*:
 ## Fibonacci
 
 The implementation of the Fibonacci function also uses a `switch` statement, but here we just use simple `case ` statements to deal with two special cases when parameter `n ` equals `0` or `1`. Now, this function uses a tuple `t` as second parameter which makes the behaviour more clear. We also use an initialisation of the tuple so we can omit it as parameter when calling the function. Really nice.
 */
func fibonacci(_ n: Int, _ t: (a: Int, b: Int) = (0, 1)) -> Int {
    switch n {
        case 0: return t.a
        case 1: return t.b
        default: return fibonacci(n - 1, (t.b, t.a + t.b))
    }
}

fibonacci(7) // results in 13
/*:
 You might also want to watch the [Computerphile video](https://www.youtube.com/watch?v=_JtPhF8MshA) of Nottingham University's Graham Hutton for an in-depth explanation of how tail recursions work.
 */
