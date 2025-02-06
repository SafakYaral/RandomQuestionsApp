//
//  AnswersView.swift
//  QuizAppCursor
//
//  Created by Safak Yaral on 17.01.2025.
//

import SwiftUI

struct AnswersView: View {
    let answer: Answer
    let action: () -> Void
    let selectedAnswer: Answer?
    
    private var backgroundColor: Color {
        guard let selectedAnswer = selectedAnswer else { return .blue }
        
        if selectedAnswer.id == answer.id {
            return answer.isCorrect ? .green : .red
        } else if answer.isCorrect {
            return .green
        }
        return .blue
    }
    
    var body: some View {
        Button(action: action) {
            Text(answer.text)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(backgroundColor)
                .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
        .disabled(selectedAnswer != nil)
    }
}

#Preview {
    AnswersView(
        answer: Answer(text: "Sample Answer", isCorrect: true),
        action: {},
        selectedAnswer: nil
    )
}
