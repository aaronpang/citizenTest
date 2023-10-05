//
//  ContentView.swift
//  CitizenInterview
//
//  Created by Aaron Pang on 8/25/23.
//

import SwiftUI

struct FlashcardView: View {
    @State private var showAnswer = false
    @State private var question = ""
    @State private var answer = ""

    @State private var questionCounter = 0
    @State private var shuffleQuestionsAlreadySeen: Set<Int> = []
    @State private var questionsSeenOrdered: [Int] = []

    @State private var questions: [QuestionModel] = []
    @Binding var answerModel: DynamicAnswerResultsModel?
    @Binding var isAbove65: Bool
    @Binding var orderedQuestionsUnranked: Bool

    init(isAbove65: Binding<Bool>, answerModel: Binding<DynamicAnswerResultsModel?>, orderedQuestionsUnranked: Binding<Bool>) {
        self._answerModel = answerModel
        self._isAbove65 = isAbove65
        self._orderedQuestionsUnranked = orderedQuestionsUnranked
        self._questions = State(initialValue: QuestionManager.getQuestionOrderedByScore(showOnly65AboveQuestions: isAbove65.wrappedValue, orderedQuestionsUnranked: orderedQuestionsUnranked.wrappedValue))
        let initialQuestion = questions[questionCounter]
        self._question = State(initialValue: initialQuestion.question)
        self._answer = State(initialValue: DynamicAnswerParser.parseAnswersIntoString(answers: initialQuestion.answers, answerModel: answerModel.wrappedValue))
    }

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text(String(format: "Question #%d", questions[questionCounter].question_id)).fontWeight(.bold)
                Text(question).padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
                if showAnswer {
                    Text(String("Answer")).fontWeight(.bold)
                    ScrollView {
                        VStack(alignment: .leading) {
                            Text(answer)
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }.frame(maxHeight: .infinity, alignment: .top)
            if !showAnswer {
                Button {
                    showAnswer = true
                } label: {
                    Text("Show Answer")
                        .frame(maxWidth: .infinity, minHeight: 40)
                }
                .buttonStyle(.borderedProminent)
                .frame(alignment: .bottom)
            } else {
                HStack {
                    Button {
                        QuestionManager.updateQuestionScore(questionID: questions[questionCounter].question_id, scoreDifference: -1)
                        showNextQuestion()
                    } label: {
                        Text("Got it Wrong")
                            .frame(maxWidth: .infinity, minHeight: 40)
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(alignment: .bottom)
                    .tint(Color.red)
                    Button {
                        QuestionManager.updateQuestionScore(questionID: questions[questionCounter].question_id, scoreDifference: 1)
                        showNextQuestion()
                    } label: {
                        Text("Got it Right")
                            .frame(maxWidth: .infinity, minHeight: 40)
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(alignment: .bottom)
                    .tint(Color.green)
                }
            }
            Button {
                guard let previousQuestion = questionsSeenOrdered.last else { return }
                showAnswer = false
                questionCounter = previousQuestion
                questionsSeenOrdered.removeLast()
                updateQuestionAndAnswer()

            } label: {
                Text("Previous Question")
                    .frame(maxWidth: .infinity, minHeight: 30)
            }
            .buttonStyle(.borderless)
            .frame(alignment: .bottom)
            .disabled(questionsSeenOrdered.count <= 0)
        }
        .padding()
        .frame(maxWidth: .infinity, // Full Screen Width
               maxHeight: .infinity, // Full Screen Height
               alignment: .topLeading)
        .navigationBarTitle(Text("Quiz Flashcards"))
        .onAppear {
            questions = QuestionManager.getQuestionOrderedByScore(showOnly65AboveQuestions: isAbove65, orderedQuestionsUnranked: orderedQuestionsUnranked)
            questionCounter = 0
            updateQuestionAndAnswer()
        }
    }

    func updateQuestionAndAnswer() {
        question = questions[questionCounter].question
        answer = DynamicAnswerParser.parseAnswersIntoString(answers: questions[questionCounter].answers, answerModel: answerModel)
    }

    func showNextQuestion() {
        questionsSeenOrdered.append(questionCounter)
        showAnswer = false
        shuffleQuestionsAlreadySeen.insert(questionCounter)
        questionCounter += 1
        // If we go through all the questions, then get the new list of sorted questions and start again
        if questionCounter >= questions.count {
            questions = QuestionManager.getQuestionOrderedByScore(showOnly65AboveQuestions: isAbove65, orderedQuestionsUnranked: orderedQuestionsUnranked)
            questionCounter = 0
        }
        updateQuestionAndAnswer()
    }
}
