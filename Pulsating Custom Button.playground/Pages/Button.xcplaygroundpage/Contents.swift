/**
Name:      Pulsating Custom Button.playground
Purpose:   Create a custom button with a simulated pulsating LED.
Version:   1.0 (12-04-2020)
Language:  Swift
Author:    Matthias M. Schneider & Brian Advent
Copyright: IDC (I don't care)
*/

import SwiftUI
import PlaygroundSupport

struct SpecialButton: View {
    static let buttonCornerRadius: CGFloat = 5
    static let buttonWidth: CGFloat = 150
    static let buttonHeight: CGFloat = 55
    
    @State private var blink = false
    
    let buttonText = "Button"
    let buttonColour = Color(#colorLiteral(red: 0.803921568627451, green: 0.803921568627451, blue: 0.803921568627451, alpha: 1.0))
    let buttonIndicatorColour = Color(#colorLiteral(red: 0.9254901960784314, green: 0.23529411764705882, blue: 0.10196078431372549, alpha: 1.0))
    let buttonIndicatorColourDimmed = Color(#colorLiteral(red: 0.9254901960784314, green: 0.23529411764705882, blue: 0.10196078431372549, alpha: 0.1))
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: SpecialButton.buttonCornerRadius)
                .frame(width: SpecialButton.buttonWidth, height: SpecialButton.buttonHeight)
                .foregroundColor(buttonColour)
            
            Text(buttonText)
                .bold()
            
            LeftIndicator()
                .trim(from: 0.41, to: 0.59)
                .fill(blink ? buttonIndicatorColour : buttonIndicatorColourDimmed)
                .frame(width: SpecialButton.buttonWidth, height: SpecialButton.buttonHeight)
                .animation(blink ? Animation.linear(duration: 0.5).repeatForever() : Animation.linear)
        }
        .onAppear {
            self.blink.toggle()
        }
        .onTapGesture {
            print("Button tapped. Thanks and have a nice day.")
            self.blink.toggle()
        }
    }
}

struct LeftIndicator: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRoundedRect(in: rect, cornerSize: CGSize(width: SpecialButton.buttonCornerRadius, height: SpecialButton.buttonCornerRadius))
        return path
    }
}

struct SpecialButton_Previews: PreviewProvider {
    static var previews: some View {
        SpecialButton()
    }
}

let s = SpecialButton()

PlaygroundPage.current.setLiveView(s)
