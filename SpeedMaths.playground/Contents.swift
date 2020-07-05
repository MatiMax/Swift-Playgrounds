/**
Name:      SpeedMaths.playground
Purpose:   Quick maths test without fuss, but with SwiftUI.
Version:   1.0 (19-03-2020)
Language:  Swift
Author:    Matthias M. Schneider & Paul Hudson
Copyright: IDC (I don't care)
*/

import SwiftUI
import PlaygroundSupport

enum Position {
    case current, answered, upcoming
}

struct Question {
    let challenge: Int
    let text: String
    let actualAnswer: String
    var userAnswer = ""
    
    init(challenge nr: Int = -1) {
        let left = Int.random(in: 1...10)
        let right = Int.random(in: 1...10)
        
        challenge = nr
        text = "\(left) \u{00d7} \(right) = "
        actualAnswer = "\(left * right)"
    }
}

struct QuestionRow: View {
    @State var question: Question
    @State var position: Position
    
    var positionColor: Color {
        if position == .answered {
            if question.actualAnswer == question.userAnswer {
                return Color.green.opacity(0.8)
            } else {
                return Color.red.opacity(0.8)
            }
        } else if position == .upcoming {
            return Color.white.opacity(0.1)
        } else {
            return .gray
        }
    }
    
    var body: some View {
        HStack {
            Text("Challenge #\(question.challenge)")
                .font(.system(size: 12))
                .foregroundColor(.accentColor)
                .frame(width: 100)
            Text(question.text)
                .padding([.top, .bottom, .leading])
                .frame(width: 300, alignment: .trailing)
                
            ZStack {
                Text(" ")
                .padding()
                .frame(width: 150)
                .overlay(
                    RoundedRectangle(cornerRadius: 10).fill(positionColor)
                )
                .overlay(
                    TextField("?",
                              text: $question.userAnswer,
                              onEditingChanged: {
                                editing in
                                if editing == true {
                                    self.position = .current
                                } else {
                                    if self.question.userAnswer != "" {
                                        self.position = .answered
                                    } else {
                                        self.position = .upcoming
                                    }
                                }
                    }, onCommit: {})
                    .padding()
                    .keyboardType(.numberPad)
                )
            }
        }
        .font(.system(size: 48, weight: .regular, design: .monospaced))
        .foregroundColor(.white)
        .background(Color(.black))
        .frame(height: 108)
    }
}

struct ContentView: View {
    @State private var questions = [Question(challenge: 1)]
    @State private var number = -1
    
    var body: some View {
        ScrollView(.vertical) {
            ForEach(0..<questions.count, id: \.self) { index in
                QuestionRow(question: self.questions[index], position: self.position(for: index))
                }
        }
        .frame(width: 800)
        .onAppear(perform: createQuestions)
    }
    
    func createQuestions() {
        for nr in 2...50 {
            questions.append(Question(challenge: nr))
        }
    }
    
    func position(for index: Int) -> Position {
        if index < number {
            return .answered
        } else if index == number {
            return .current
        } else {
            return .upcoming
        }
    }
}

let speedMaths = ContentView()

PlaygroundPage.current.setLiveView(speedMaths)
