//
//  QuizModel.swift
//  QuizAppCursor
//
//  Created by Safak Yaral on 17.01.2025.
//

import Foundation

struct Question: Identifiable {
    let id = UUID()
    let text: String
    let answers: [Answer]
    let category: String
}

struct Answer: Identifiable {
    let id = UUID()
    let text: String
    let isCorrect: Bool
}

struct TriviaResponse: Codable {
    let responseCode: Int
    let results: [TriviaQuestion]
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case results
    }
}

struct TriviaQuestion: Codable {
    let category: String
    let type: String
    let difficulty: String
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    
    enum CodingKeys: String, CodingKey {
        case category
        case type
        case difficulty
        case question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
}
