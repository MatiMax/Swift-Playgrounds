/**
 Name:      SyntaxTree.playground
 Purpose:   Demonstrate the basics of an object tree.
 Version:   1.0 (09-03-2020)
 Language:  Swift
 Author:    Matthias M. Schneider & Thorsten Altenkirch, University of Nottingham (Python version)
 Copyright: IDC (I don't care)
 */

/*:
 # Syntax Tree — An example of building a tree of objects
 First of all, why should you be interested in this playground? If you ever asked yourself the question, "How can or should I build an evaluating parser with the least effort?" then this playground should give you a good starting point.
 
 - Note: This playground is based on Thorsten Altenkirch's Python version. If you want to enjoy Thorsten's explanations please see his video on [Computerphile's YouTube channel](https://www.youtube.com/watch?v=7tCNu4CnjVc).
 
 ## Introduction to trees
 Creating trees of objects has its roots (pun intended 😉) in the idea of decomposing the problem of reading a linearly arranged grammar and putting it in a form so that a computer can do something useful with it. Let's have a look at an example which will be used to build this playground upon.
 
 - Example: *Two expressions to be evaluated* \
  (i)  3 • (y + x)\
  (ii) 3 • y + x
  
 Say, we want to sove the two mathematical expressions using some algorithmic approach. As you can see there is the slightest difference in the two: The first expression uses paranthesis to prioritise the addition before the multiplication. If we would like to visualise the expressions in form of trees, we could for example use the operators as branches and the operands as leaves. This would lead to a tree like this for expression (i):
 
      [*]
     /   \
    3     \
          [+]
         /   \
        y     x
 
 In contrast, applying the same principles to expression (ii) would result in the following tree:
 
          [+]
         /   \
        /     \
      [*]      x
     /   \
    3     y
 
 ## Data model of a tree
 Coming from the visual approach we can now make some assumptions how to generalise the model of a tree. For a good example showing the power of an object tree we use five ingredients:
 1. Expression with evaluation function
 2. Operators
 3. Operands, which are represented by
    1. Constants
    2. Variables

 This leeds to a fairly complete model which allows the parsing of simple mathematical expressions like the two examples mentioned earlier.

 So let's start with the code.
*/

/*:
 We declare `Expression` as the base class of wich we will derive the representation of operators and operands, i.e constants and variables. The class uses a `typealias` for the `Environment` which is used to store variables and their corresponding values; it is a `Dictionary` with a `String` as its key and a `Double` as its value, and we're constraing it to this type just for clarity and readability. The class conforms to the `CustomStringConvertible` protocol so that we can print a nice representation of the expression to the console or make it readable in a viewer; we then have to add the `description` variable and return a `String` which represents the decriptive value of the expression, in case of the base class we just return a placeholder text. The `evaluate` function returns the value of the evaluated expression depending on the meanding of its subclass, and we will see this in detail later on. The base class just produces a value of 0 for satisfying the requirement to return a `Double` value as a result. This base class has no dedicated `init`ialiser.
 
 - Note: Throughout this playground we make use of Swift 5's language feature of implicit `return` statements. If there is **_one, and only one_** statement as an expression which results in a type conformant returnable value you may omit the `return ` keyword.
 */
class Expression: CustomStringConvertible {
    typealias Environment = Dictionary<String, Double>
    var description: String { "Empty Expression" } //: No `return` keyword needed
    
    func evaluate(withEnvironment environment: Environment) -> Double {
        0 //: Neither here
    }
}

/*:
 The `Times` operator is an `Expression` which uses a left-hand-side operand and a right-hand-side operand as multiplicands. It returns the product of both multiplicands when evaluated. The `init`ialiser just takes the left-hand-side and right-hand-side operands which themselves are of type `Expression`. The `evaluate` function then uses the multiplication operator of Swift to multiply left- and right-hand-side operands, and returns the result as a `Double` value implicitly (omitting the `return` keyword). To be able to evaluate an expression which uses variables we have to supply the `Environment` which holds the variable declarations and their corresponding values. Remember: The base class `Expression` requires an `Environment ` in the `evaluate` function as a (the only) parameter, and any subclass which overrides the function must then make use of it, too.
 */
class Times: Expression {
    let lhs: Expression
    let rhs: Expression
    override var description: String { "(\(lhs) \u{00d7} \(rhs))" } //: Unicode character 0x00d7 represents the mathematical multiplication sign × which is hard to come by on the keyboard

//: A simple initialisation of the left- and right-hand-side operands as `Expression`s.
    init(_ lhs: Expression, _ rhs: Expression) {
        self.lhs = lhs
        self.rhs = rhs
    }
    
    override func evaluate(withEnvironment environment: Environment) -> Double {
        lhs.evaluate(withEnvironment: environment) * rhs.evaluate(withEnvironment: environment)
    }
}

/*:
 The `Plus` operator, like `Times`, is an `Expression` which uses a left-hand-side operand and a right-hand-side operand as summands. It returns the sum of both summands when evaluated. The `init`ialiser just takes the left-hand-side and right-hand-side operands which themselves are of type `Expression`. The `evaluate` function then uses the addition operator of Swift to add left- and right-hand-side operands, and returns the result as a `Double` value implicitly.
 */
class Plus: Expression {
    let lhs: Expression
    let rhs: Expression
    override var description: String { "(\(lhs) + \(rhs))" }
    
    init(_ rhs: Expression, _ lhs: Expression) {
        self.lhs = lhs
        self.rhs = rhs
    }
    
    override func evaluate(withEnvironment environment: Environment) -> Double {
        lhs.evaluate(withEnvironment: environment) + rhs.evaluate(withEnvironment: environment)
    }
}

/*:
 The `Const` operand stores a value of type `Double`. That's basically all it does. When evaluating this `Expression` it simply returns the stored value, again implicitly.
 */
class Const: Expression {
    let val: Double
    override var description: String { "\(val)" }
    
    init(_ val: Double) {
        self.val = val
    }
    
    override func evaluate(withEnvironment environment: Environment) -> Double {
        val
    }
}

/*:
 The `Var` operand stores the variable name as a `String`. This operator is interesting as it uses the dictionary `Environment` during the call of the function `evaluate` to substitute the variable name with the according `Double` value found in the dictionary. The function is fail safe in the sense that if the variable does not exist in the dictionary it returns a value of zero (which many interpreted programming languages do).
 */
class Var: Expression {
    let name: String
    override var description: String { "\(name)" }
    
    init(_ name: String) {
        self.name = name
    }
    
    override func evaluate(withEnvironment environment: Environment) -> Double {
        environment[name] ?? 0
    }
}

//: Create an empty expression for inspection in the playground.
let e = Expression() //: Should result in "Empty Expression"

//: Let's construct the expression `3 * (y + x)` using the classes we created.
let e1 = Times(Const(3), Plus(Var("y"), Var("x")))
//: And now let's try the expression `3 * y + x` using the classes we created.
let e2 = Plus(Times(Const(3), Var("y")), Var("x"))

//: Set the environment to include specific values for the variable names.
let environment = ["x": 2.0, "y": 4.0]

//: Let's inspect the expressions.
e1
e2

//: Here comes the magic: Let's call the `evaluate` function on both expressions and see which values we get.
e1.evaluate(withEnvironment: environment) //: Should result in 18.0
e2.evaluate(withEnvironment: environment) //: Should result in 14.0
