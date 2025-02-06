//
//  QuizViewModel.swift
//  QuizAppCursor
//
//  Created by Safak Yaral on 17.01.2025.
//

import Foundation

import SwiftUI

class QuizViewModel: ObservableObject {
    @Published var currentQuestionIndex = 0
    @Published var score = 0
    @Published var isGameOver = false
    @Published var progress: Double = 0
    @Published var selectedAnswer: Answer?
    @Published var canProceed = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published private(set) var questions: [Question] = []
    
    init() {
        fetchQuestions()
    }
    
    func fetchQuestions() {
        isLoading = true
        errorMessage = nil
        
        // You can customize the URL parameters:
        // amount: number of questions (1-50)
        // difficulty: easy, medium, hard
        // type: multiple (for multiple choice questions)
        let urlString = "https://opentdb.com/api.php?amount=10&type=multiple"
        
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "No data received"
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let triviaResponse = try decoder.decode(TriviaResponse.self, from: data)
                    
                    // Convert TriviaQuestion to our Question model
                    self?.questions = triviaResponse.results.map { triviaQuestion in
                        let correctAnswer = Answer(
                            text: triviaQuestion.correctAnswer.htmlDecoded(),
                            isCorrect: true
                        )
                        
                        let incorrectAnswers = triviaQuestion.incorrectAnswers.map {
                            Answer(text: $0.htmlDecoded(), isCorrect: false)
                        }
                        
                        // Combine and shuffle answers
                        let allAnswers = (incorrectAnswers + [correctAnswer]).shuffled()
                        
                        return Question(
                            text: triviaQuestion.question.htmlDecoded(),
                            answers: allAnswers,
                            category: triviaQuestion.category
                        )
                    }
                } catch {
                    self?.errorMessage = "Failed to decode data: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    // Add this extension to decode HTML entities
    private func decodeHTMLEntities(_ text: String) -> String {
        guard let data = text.data(using: .utf8) else { return text }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            return attributedString.string
        }
        return text
    }
    
    var currentQuestion: Question {
        questions[currentQuestionIndex]
    }
    
    func checkAnswer(_ answer: Answer) {
        selectedAnswer = answer
        canProceed = true
        
        if answer.isCorrect {
            score += 1
        }
        
        // Add automatic progression after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if !self.isGameOver {  // Only proceed if the game isn't over
                self.nextQuestion()
            }
        }
    }
    
    func nextQuestion() {
        if currentQuestionIndex + 1 < questions.count {
            currentQuestionIndex += 1
            withAnimation {
                progress = Double(currentQuestionIndex) / Double(questions.count - 1)
            }
        } else {
            isGameOver = true
        }
        
        // Reset for next question
        selectedAnswer = nil
        canProceed = false
    }
    
    func resetQuiz() {
        currentQuestionIndex = 0
        score = 0
        progress = 0
        isGameOver = false
        fetchQuestions() // Fetch new questions when resetting
    }
}

// Add this extension to help decode HTML entities
extension String {
    func htmlDecoded() -> String {
        guard let data = self.data(using: .utf8) else { return self }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            return attributedString.string
        }
        return self
    }
}
