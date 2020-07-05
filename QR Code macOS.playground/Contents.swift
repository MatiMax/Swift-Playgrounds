/**
 Name:      QR Code macOS.playground
 Purpose:   Generate a QR code from a string using SwiftUI and CoreImage
 Version:   1.0 (29-04-2020)
 Language:  Swift
 Author:    Matthias M. Schneider
 Copyright: IDC (I don't care)
 */

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins
import PlaygroundSupport

struct QRView: View {
    static private var width: CGFloat = 200
    static private var height: CGFloat = 200
    @State private var message = "Hello, Swift!"
    @GestureState private var scaleQR: CGFloat = 1
    
    var body: some View {
        VStack {
            HStack {
                Text("QR Code String")
                    .foregroundColor(.accentColor)
            
                TextField("Enter string", text: $message, onEditingChanged: {_ in }, onCommit: {})
            }
            Spacer()
            Text("QR Code")
                .font(.system(size: 24))
                .foregroundColor(.accentColor)
            
            Image(nsImage: qrCodeGenerator().nsImage)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: QRView.width, height: QRView.height)
                .onTapGesture {
                    if let ciImage = self.qrCodeGenerator().ciImage {
                        NSPasteboard.general.clearContents()
                        
                        let nsImage = NSImage()
                        let nsImageRep = NSBitmapImageRep(ciImage: ciImage.transformed(by: CGAffineTransform(scaleX: 8, y: 8)))
                        nsImage.addRepresentation(nsImageRep)
                        
                        NSPasteboard.general.writeObjects([nsImage])
                    } else {
                        print("Cannot copy to clipboard.")
                    }
                }
            .gesture(MagnificationGesture().updating($scaleQR) { currentState, gestureState, transaction in
                gestureState = currentState
            })
            
            Text("Please scan to verify.")
                .font(.system(size: 12))
        }
        .frame(width: QRView.width * 2, height: QRView.height * 2)
        .padding()
}
    
    func qrCodeGenerator() -> (nsImage: NSImage, ciImage: CIImage?) {
        let context = CIContext()
        let qrCode = CIFilter.qrCodeGenerator()
        let xMarkCircle = NSImage(byReferencingFile: "xmark.circle") ?? NSImage(named: "empty")
        
        qrCode.message = Data(message.utf8)
        
        if let outputImage = qrCode.outputImage {
            if let cgImg = context.createCGImage(qrCode.outputImage!, from: qrCode.outputImage!.extent) {
                return (NSImage(cgImage: cgImg, size: CGSize(width: QRView.width, height: QRView.height)), outputImage)
            } else {
                return (xMarkCircle!, nil)
            }
        } else {
            return (xMarkCircle!, nil)
        }
    }
}

PlaygroundPage.current.setLiveView(QRView())
