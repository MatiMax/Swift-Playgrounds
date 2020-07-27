/**
 Name:      IPHostAddressResolution5.playground
 Purpose:   Example of a using Standard C Library function calls to retrieve *all* host names from a given IP address.
 Version:   2.1 (05-06-2020)
 Language:  Swift
 Author:    Matthias M. Schneider
 Copyright: IDC (I don't care)
 */
//: # How to retrieve a host name and associated aliases from an IP address
//: The `Foundation` framework incorporates the Standard C Library and can be used on any platform.
import Foundation
//: ## Using the C `struct`s in Swift
//: We can safely use a Swift `String` for storing the IP address in character format as Swift supports toll-fee bridging to C strings.
let ip = "17.172.224.47" // Apple
//: We create an empty fully initialized `in_addr` C structure by using the convenience initializer.
var addr: in_addr = in_addr()
//: To store the host names in a plain Swift array of `String`s we use the following variable.
var host_aliases: [String] = []
//: ## Using the C Standard Library
//: The C Standard Library function `inet_pton` converts an IP address from a string representation to a network number. `AF_INET` tells the function to expect an IP4 address.
//: Caveat: Some functions require the `AF_...` constants to be wrapped around an `sa_family_t()` type cast.
inet_pton(AF_INET, ip, &addr)
//: Now we can all the legacy `gethostbyaddr` C function which returns an optional pointer to a `hostent` structure.
/*: We use `guard let` to check that the call actually returns a non-nil value structure. After that we can safely use the `pointee` to reference the contents of the structure—which is derived from the C pointer to the `hostent` struct.
 Also, we do a nicer and safer type conversion using `socklen_t` to map the size of the `in_addr` struct from `Int` to the corresponding acceptable type for the C function (which essentially is a `UInt32`, declared as `typealias` in the Darwin C headers).
 */
guard let he = gethostbyaddr(&addr, socklen_t(MemoryLayout<in_addr>.size), AF_INET) else {
    print("\n\u{1b}[1;41mCannot resolve IP address \(ip) \u{1b}[7m[gethostaddr returned nil]\u{1b}[27m. Exiting now.\u{1b}[0m\n")
    exit(1)
}
//: The first resolved host name is present as a null-terminated C string in `hostent`'s member `h_name`.
//: Just print it out, and then append it to the `host_aliases` array of `String`s.
print("First canonical host name: \(String(cString: he.pointee.h_name))")
host_aliases.append(String(cString: he.pointee.h_name))
//: For convenience, we assign the pointer to the list of C strings containing the alias names of the host to a constant name if and only if there actually is a non-nil pointer to the list of alias names again using the `guard let` statement.
guard let host_list = he.pointee.h_aliases else {
    print("\n\u{1b}[1;41mNo aliases for IP address \(ip) \u{1b}[7m[gethostaddr returned nil for h_aliases]\u{1b}[27m. Exiting now.\u{1b}[0m\n")
    exit(2)
}

//: ## Converting the list of C strings to a Swift `String` array.
if host_list[0] != nil {
    var i = 1
/*:
This is the beauty of Swift's toll-free C-bridging at a max: We can simply refer to the list of C strings using the standard Swift array accessor.

In the `while` loop we get a very concise expression for iterating over the nil-terminated list, converting the null-terminated C strings into `String`s and and packing the `String`s into the Swift array of `String`s.

We skip the first alias name as it represents the RARP address pointer (`47.224.172.17.in-addr.arpa`) which is of no use to us.
*/
    while let h = host_list[i] {
        host_aliases.append(String(cString: h))
        i += 1
    }
//: ## The result
//: Having now a Swift array of `String`s filled up with the host names, working with it in either the Playground or in code is nice and clean.
    print("Found \(host_aliases.count) hosts for IP address \(ip):")
    for host in host_aliases {
        print(host)
    }
} else {
    print("No aliases.")
}
