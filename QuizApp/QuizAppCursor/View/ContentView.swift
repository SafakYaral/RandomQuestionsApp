//
//  ContentView.swift
//  QuizAppCursor
//
//  Created by Safak Yaral on 17.01.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = QuizViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView("Loading questions...")
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                            .padding()
                        
                        Button("Try Again") {
                            viewModel.fetchQuestions()
                        }
                        .padding()
                    }
                } else if viewModel.questions.isEmpty {
                    Text("No questions available")
                        .padding()
                } else {
                    VStack(spacing: 20) {
                        // Progress and Score
                        HStack {
                            Text("Score: \(viewModel.score)")
                                .font(.headline)
                            Spacer()
                            Text("Question: \(viewModel.currentQuestionIndex + 1)/\(viewModel.questions.count)")
                                .font(.headline)
                        }
                        .padding()
                        
                        // Progress Bar
                        ProgressView(value: viewModel.progress)
                            .tint(.blue)
                            .padding(.horizontal)
                        
                        // Question
                        Text(viewModel.currentQuestion.text)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        
                        // Answers
                        VStack(spacing: 12) {
                            ForEach(viewModel.currentQuestion.answers) { answer in
                                AnswersView(
                                    answer: answer,
                                    action: {
                                        withAnimation {
                                            viewModel.checkAnswer(answer)
                                        }
                                    },
                                    selectedAnswer: viewModel.selectedAnswer
                                )
                            }
                        }
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("Quiz App")
            .alert("Quiz Complete!", isPresented: $viewModel.isGameOver) {
                Button("Play Again", action: viewModel.resetQuiz)
            } message: {
                Text("Your final score is \(viewModel.score) out of \(viewModel.questions.count)")
            }
        }
    }
}

#Preview {
    ContentView()
}
