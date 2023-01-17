//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Harish on 20/12/22.
//

import SwiftUI

struct ConditionalRotationModifier: ViewModifier {
    let condition: Bool
    let angle: Angle
    let axis: (CGFloat, CGFloat, CGFloat)
    
    func body(content: Content) -> some View {
        if condition {
            content
                .rotation3DEffect(angle, axis: axis)
        } else {
            content
        }
    }
}

extension View {
    func conditionalRotationModifier(condition: Bool, angle: Angle, axis: (CGFloat, CGFloat, CGFloat)) -> some View {
        self.modifier(ConditionalRotationModifier(condition: condition, angle: angle, axis: axis))
    }
}

struct ContentView: View {
    @State private var showingScore: Bool = false
    @State private var showingReset: Bool = false
    @State private var scoreTitle: String = ""
    @State private var animationDegree = 0.0
    @State private var opacity = 1.0
    
    @State private var selectionIndex:Int = 4
    
    @State private var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Russia", "Spain", "UK", "US"].shuffled()
    @State private var correctAnswer = Int.random(in: 0...2)
    @State private var score: Int = 0
    @State private var questionsAsked: Int = 0
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.blue, .black]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                Text("Guess The Flag")
                    .font(.title.weight(.bold))
                    .foregroundColor(.white)
                
                VStack(spacing: 20) {
                    VStack {
                        Text("Tap the flag for")
                            .font(.subheadline.weight(.heavy))
                            .foregroundStyle(.secondary)
                        
                        Text(countries[correctAnswer])
                            .font(.largeTitle.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    
                    ForEach(0..<3) { number in
                        Button {
                            flagTapped(number)
                        } label: {
                            Image(countries[number])
                                .renderingMode(.original)
                                .clipShape(Capsule())
                                .shadow(radius: 7)
                            //Custom modifier: Only applied if condition is true
                                .conditionalRotationModifier(condition: selectionIndex == number, angle: .degrees(animationDegree), axis: (0,1,0))
                                .opacity(selectionIndex != number ? opacity : 1)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Spacer()
                Spacer()
                
                Text("Your Score: \(score)/\(questionsAsked)")
                    .font(.title2.weight(.bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding()
        }
        .alert(scoreTitle, isPresented: $showingScore) {
            Button("OK", action: askQuestion)
        } message: {
            Text("Your score is \(score)")
        }
        .alert("Game Over", isPresented: $showingReset) {
            Button("Reset", action: reset)
        } message: {
            Text("Your Final Score: \(score)/\(questionsAsked)")
        }
    }
    
    func flagTapped(_ number: Int) {
        selectionIndex = number
        
        withAnimation(.interpolatingSpring(stiffness: 5, damping: 2)) {
            animationDegree += 360.0
            opacity = 0.25
        }
        
        questionsAsked += 1
        
        if number == correctAnswer {
            scoreTitle = "Correct Answer"
            score += 1
        } else {
            scoreTitle = "Wrong Answer"
        }
        
        if questionsAsked >= 8 {
            showingReset = true
            return
        }
        
        showingScore = true
    }
    
    func askQuestion() {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        selectionIndex = 4
        animationDegree = 0
        opacity = 1
    }
    
    func reset() {
        score = 0
        questionsAsked = 0
        selectionIndex = 4
        animationDegree = 0
        opacity = 1
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
