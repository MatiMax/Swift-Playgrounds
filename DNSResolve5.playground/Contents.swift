//: # How to retrieve a host name and associated aliases from an IP address using Core Fondation's `CFHost` in Swift 5

import Foundation
import PlaygroundSupport
//: In order to get the callback working we use a simple class to implement the showcase.
class DNSResolve {
//: The IP address may be a Swift `String` thanks to the toll-free bridging to C strings.
    let ip = "17.172.224.47"
//: We use an optional `CFHost` variable because CFHost neither comes with an initializer nor is conforming to the Nullable protocol.
    var host: CFHost?
//: We use this array of `String`s to store the resolved host names.
    var names: [String] = []
    
    func resolve() {
//: Let's set up the `sockaddr_in` C structure using the initializer.
        var sin = sockaddr_in(
            sin_len: UInt8(MemoryLayout<sockaddr_in>.size),
            sin_family: sa_family_t(AF_INET),
            sin_port: in_port_t(0),
            sin_addr: in_addr(s_addr: inet_addr(ip)),
            sin_zero: (0,0,0,0,0,0,0,0)
        )
//: Now convert the structure into a `Data` object. Using the `Data` object is much less pain than fiddling around with the `CFData` variant using the `CFDataCreate` function which requires nasty un-Swift-ly pointer-type casting.
        let data = Data(bytes: &sin, count: MemoryLayout<sockaddr_in>.size)
//: Create the `CFHostRef` with the `Data` object and store the unretained value for later use.
        let hostref = CFHostCreateWithAddress(kCFAllocatorDefault, data as CFData)
        self.host = hostref.takeUnretainedValue()
//: For the callback to work we have to create a client context.
        var ctx = CFHostClientContext(
            version: 0,
            info: unsafeBitCast(self, to: UnsafeMutableRawPointer.self),
            retain: nil,
            release: nil,
            copyDescription: unsafeBitCast(kCFAllocatorDefault, to: CFAllocatorCopyDescriptionCallBack.self)
        )
//: We can now set up the client for the callback using the `CFHostClientCallBack` signature for the closure.
        CFHostSetClient(host!, { (host, infoType, error, info) in
            let dnsResolve = unsafeBitCast(info, to: DNSResolve.self)
            print("Resolving …")
            dnsResolve.namesResolved()
        }, &ctx)
//: Now schedule the runloop for the host.
        CFHostScheduleWithRunLoop(host!, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue);
//: Create a `CFStreamError` object for use with the info resolution using `CFHostStartInfoResolution`.
        var error = CFStreamError()
//: Start the info resolution.
        let started = CFHostStartInfoResolution(host!, .names, &error)
        print("Name resolution started: \(started)")
        
        hostref.autorelease()
    }
    
//: This function is attachted as `CFHostClientCallBack` in `CFHostSetClient` which should get called during the info resolution.
    func namesResolved() {
        print("namesResolved: Resolving …")
//: Create a boolean pointer `DarwinBoolean` for use with the function `CFHostGetNames`.
        var resolved: DarwinBoolean = false
//: Now get the results of the info resolution.
        let cfNames = CFHostGetNames(host!, &resolved)!.takeRetainedValue()
        print("namesResolved: Names resolved: \(cfNames)")
//: We can force a cast to `[String]`. Thank you, Swift.
        self.names = cfNames as! [String]
        
//: **Oh dear—we see only one host name here and no aliases. Stuck again …  😔**
        print("CFArray reports \(CFArrayGetCount(cfNames)) elements, [String] reports \(self.names.count) elements.")
        self.listNames()
        
//: After the info resolution clean up either way.
        CFHostSetClient(host!, nil, nil);
        CFHostCancelInfoResolution(host!, .names)
        CFHostUnscheduleFromRunLoop(host!, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
    }
    
    func listNames() {
        print(self.names)
    }
}
//: OK, let's create an instance of our `DNSResolve` class and run the `resolve()` method.
let dnsRes = DNSResolve()
dnsRes.resolve()
//: In order to see the callback working we have to set Playground's execution to take on forever.
PlaygroundPage.current.needsIndefiniteExecution = true
