/**
 Name:      FunctionCallMapping.playground
 Purpose:   Example of a string-based function call mapping for use in RPC calls, e.g. REST web services or JSON-RPC.
 Version:   2.0 (10-03-2020)
 Language:  Swift
 Author:    Matthias M. Schneider
 Copyright: IDC (I don't care)
 */
/*:
 # Function Call Mapping Using the Beauty of the Swift Language
 
 The purpose of this playground is to showcase a very common problem in programming where a statically typed compiled language envirnonment should provide an ability to dynamically call functions (or methods) which might be added during the livecyle of the application. Situations include but are not limited to plug-in mechanisms, dynamic loading of code portions, non-deterministic calls to methods or functions from external triggers (CGI and alike), where the **method or function name will be passed in as a data type and not as a pointer to the method or function**.

 Defining an `enum`eration helps sanitise the state of a function call either if things go wrong or even if a function isn't defined and therefore can fail gracefully. In addition the beauty of binding values to a case elegantly allows for argument passing back to the caller.
 */
enum Status {
    case OK(String?)
    case MethodNotDefined
    case InvalidParameter
    case ServerError
}
/*:
 We're using a dictionary to define a function name as a `String` and a closure with one input parameter as `String` which returns a `Status`. The dictionary is flexible enough to implement a very simple way of routing jump table which is used, for example, in web and applications servers.

 Using a `typealias` makes life easier when repeatedly dealing with complex data type definitions.
*/
typealias CallDictionary = Dictionary<String, (_ environment: [Any]) -> Status>
/*:
 Set up a dictionary of functions using two very simple demos:
 1. The `/hello` function just prints the passed parameter string out to the console.
 2. The `/echo` function returns the passed parameter with a prefix of `Echo: `.
 3. The `/add` function adds two given numbers of type `Int` passed as parameter.
 *Note:* The `/add` function is defined not as inline closure but instead as a regular function to show how functions with the corresponding signature can be easily added to the dictionary during execution.
 */
var funcDict: CallDictionary = [
    "/hello" : {
        environment in print(environment[0])
        return .OK(nil)
    },
    "/echo" : {
        environment in return .OK("Echo: \(environment[0])")
    }
]

func add(environment: [Any]) -> Status {
//: The following guard statement makes shows the beauties of Swift in regards to robustness and type safety. It not only checks that there are at least two parameters in the environment array, but also makes sure that the two parameters are of type `Int` in order to allow for safe type casting in the `return` statement. Great! ☺️
    guard environment.count > 1 && type(of: environment[0]) == Int.self && type(of: environment[1]) == Int.self else {
        return .InvalidParameter
    }
//: Now we can return the sum of safely cast `Int`s from an array of `Any`s. I love it. 🥰
    return .OK(String((environment[0] as! Int) + (environment[1] as! Int)))
}
//: The `call` function just tries to call the function referenced by its string. We guard that the function name exists in the dictionary and then return the result of the function all which is of type `Status`.
func call(_ fn: String, withEnvironment environment: [Any]) -> Status {
    guard funcDict[fn] != nil else {
        return .MethodNotDefined
    }
    
    return funcDict[fn]!(environment)
}

print(call("/hello", withEnvironment: ["message from hello"]))

let res = call("/echo", withEnvironment: ["message from echo"])
switch res {
case .OK(let r):
    print("Result ->", r ?? "<empty>") 
default:
    print(res) 
}

if case .OK(let r2) = call("/echo", withEnvironment: ["message 2 from echo"]) {
    print(r2 ?? "<empty>")
}

if case let .OK(r3) = call("/hello", withEnvironment: ["message 3 from echo"]) {
    print(r3 ?? "<empty>")
}
//: Put the `/add` function into the dictionary lazily and then call it.
funcDict["/add"] = add
if case let .OK(sum) = call("/add", withEnvironment: [19, 23]) {
    print("Sum is \(sum ?? "ndef'd")")
} else {
    print("Error: add function didn't return with status OK")
}
