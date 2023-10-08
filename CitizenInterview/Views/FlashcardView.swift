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
    @State private var showAlert: Bool = false

    @State private var questionIndex = 0
    @State private var questionsAnsweredCorrectly: [Int] = []
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
        let initialQuestion = questions[questionIndex]
        self._question = State(initialValue: initialQuestion.question)
        self._answer = State(initialValue: DynamicAnswerParser.parseAnswersIntoString(answers: initialQuestion.answers, answerModel: answerModel.wrappedValue))
    }

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text(String(format: "Question #%d", questions[questionIndex].question_id))
                    .font(.title2)
                    .bold()
                Text(question)
                    .padding(.bottom)
                    .font(.title3)
                if showAnswer {
                    Text(String("Answer"))
                        .font(.title2)
                        .bold()
                    ScrollView {
                        VStack(alignment: .leading) {
                            Text(answer)
                                .font(.title3)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }.frame(maxHeight: .infinity, alignment: .top)
            Text(String(format: "Questions Answered Correctly: (%d/%d)", questionsAnsweredCorrectly.count, questionsSeenOrdered.count))
            if !showAnswer {
                Button {
                    showAnswer = true
                } label: {
                    Text("Show Answer")
                        .frame(maxWidth: .infinity, minHeight: 40)
                }
                .buttonStyle(.borderedProminent)
                .frame(alignment: .bottom)
                .padding(.bottom)
            } else {
                HStack {
                    Button {
                        QuestionManager.updateQuestionScore(questionID: questions[questionIndex].question_id, scoreDifference: -1)
                        showNextQuestion()
                    } label: {
                        Text("Got it Wrong")
                            .frame(maxWidth: .infinity, minHeight: 40)
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(alignment: .bottom)
                    .tint(Color.red)
                    Button {
                        QuestionManager.updateQuestionScore(questionID: questions[questionIndex].question_id, scoreDifference: 1)
                        showNextQuestion()
                        questionsAnsweredCorrectly.append(questions[questionIndex].question_id)
                    } label: {
                        Text("Got it Right")
                            .frame(maxWidth: .infinity, minHeight: 40)
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(alignment: .bottom)
                    .tint(Color.green)
                }
                .padding(.bottom)
            }
            Button {
                guard let previousQuestionIndex = questionsSeenOrdered.last else { return }
                // Check if we answered the last question correctly, if so, remove it from the array
                if questionsAnsweredCorrectly.last == questions[questionIndex].question_id {
                    questionsAnsweredCorrectly.removeLast()
                }
                showAnswer = false
                questionIndex = previousQuestionIndex
                questionsSeenOrdered.removeLast()
                updateQuestionAndAnswer()
            } label: {
                Text("Previous Question")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderless)
            .frame(alignment: .bottom)
            .disabled(questionsSeenOrdered.count <= 0)
        }
        .padding()
        .frame(maxWidth: .infinity, // Full Screen Width
               maxHeight: .infinity, // Full Screen Height
               alignment: .topLeading)
        .navigationBarTitle(Text("Civic Questions"))
        .onAppear {
            questions = QuestionManager.getQuestionOrderedByScore(showOnly65AboveQuestions: isAbove65, orderedQuestionsUnranked: orderedQuestionsUnranked)
            questionIndex = 0
            updateQuestionAndAnswer()
        }
        .alert("Completed all questions", isPresented: $showAlert) {
            Button("Don't show this again") {
                UserDefaults.standard.set(true, forKey: "alert_when_hit_100")
            }
            Button("Okay", role: .cancel) {}
        } message: {
            Text("You have completed all the questions in the question pool, we will now show questions you've seen before/")
        }
    }

    func updateQuestionAndAnswer() {
        question = questions[questionIndex].question
        answer = DynamicAnswerParser.parseAnswersIntoString(answers: questions[questionIndex].answers, answerModel: answerModel)
    }

    func showNextQuestion() {
        questionsSeenOrdered.append(questionIndex)
        showAnswer = false
        shuffleQuestionsAlreadySeen.insert(questionIndex)
        questionIndex += 1
        // If we go through all the questions, then get the new list of sorted questions and start again
        if questionIndex >= questions.count {
            // Show alert dialog
            if !UserDefaults.standard.bool(forKey: "alert_when_hit_100") {
                showAlert = true
            }
            questions = QuestionManager.getQuestionOrderedByScore(showOnly65AboveQuestions: isAbove65, orderedQuestionsUnranked: orderedQuestionsUnranked)
            questionIndex = 0
        }
        updateQuestionAndAnswer()
    }
}
