/**
Name:      IPHostAddressResolution5 SwiftUI.playground
Purpose:   Example of a using Standard C Library function calls to retrieve *all* host names from a given IP address.
Version:   1.0 (05-06-2020)
Language:  Swift
Author:    Matthias M. Schneider
Copyright: IDC (I don't care)
*/

import Foundation
import SwiftUI
import PlaygroundSupport

struct ResolveIP: View {
    @State private var ip = "17.172.224.47"
    @State private var hostNames: [String] = []
    @State private var ipResolved = true

    var body: some View {
        VStack(alignment: .center) {
            Text("Resolve IP Address")
                .font(.largeTitle)
            HStack {
                TextField("IP4 Address",
                          text: $ip,
                          onCommit: {
                            self.resolve(withIPAddress: self.ip)
                })
                .foregroundColor(ipResolved ? .primary : .red)
                .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: {
                    self.resolve(withIPAddress: self.ip)
                }) {
                    Text("Resolve")
                }
            }

            ScrollView(.vertical) {
                ForEach(hostNames, id: \.self) { hostName in
                    Text(hostName)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(height: 500)
        }
        .padding(16)
    }

    func resolve(withIPAddress ip: String) {
        var addr: in_addr = in_addr()
        hostNames = []
        inet_pton(AF_INET, ip, &addr)

        guard let he = gethostbyaddr(&addr, socklen_t(MemoryLayout<in_addr>.size), AF_INET) else {
            hostNames.append("Cannot resolve this address.\n[gethostaddr returned nil]")
            ipResolved = false
            return
        }
        
        hostNames.append(String(cString: he.pointee.h_name))
        guard let host_list = he.pointee.h_aliases else {
            hostNames.append("No aliases for this address.\n[gethostaddr returned nil for h_aliases]")
            ipResolved = false
            return
        }
        
        if host_list[0] != nil {
            var i = 1

            while let h = host_list[i] {
                hostNames.append(String(cString: h))
                i += 1
            }
            
            hostNames = hostNames.sorted()
            ipResolved = true
        } else {
            hostNames.append("No host names resolvable for this address.")
            ipResolved = false
        }
    }
}

PlaygroundPage.current.setLiveView(ResolveIP())
