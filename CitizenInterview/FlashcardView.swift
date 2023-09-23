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

    init(answerModel: Binding<DynamicAnswerResultsModel?>) {
        self._answerModel = answerModel
        self._questions = State(initialValue: QuestionManager.getQuestionOrderedByScore())
        let initialQuestion = questions[questionCounter]
        self._question = State(initialValue: initialQuestion.question)
        self._answer = State(initialValue: parseAnswersIntoString(answers: initialQuestion.answers))
    }

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text(String(format: "Question #%d", questions[questionCounter].question_id)).fontWeight(.bold)
                Text(question).padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
                if showAnswer {
                    Text(String("Answer")).fontWeight(.bold)
                    Text(answer)
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
            questions = QuestionManager.getQuestionOrderedByScore()
            questionCounter = 0
            updateQuestionAndAnswer()
        }
    }

    private func parseAnswersIntoString(answers: [String]) -> String {
        var answerString = ""
        let appendHyphen = answers.count > 1
        answers.forEach { answer in
            // Convert answer tokens from dynamic answer model
            let convertedAnswer = convertAnswerTokens(answer: answer)
            // If answer is a certain key then pull the dynamic data that way
            answerString.append((appendHyphen ? " - " : "") + convertedAnswer.localizedCapitalized + "\n")
        }
        return answerString
    }

//    let senators: [String]
//    let representatives: [String]

    private func convertAnswerTokens(answer: String) -> String {
        guard let answerModel else { return answer }
        let newAnswer = answer
            .replacingOccurrences(of: "$president", with: answerModel.president)
            .replacingOccurrences(of: "$vice_president", with: answerModel.vicePresident)
            .replacingOccurrences(of: "$party_of_president", with: answerModel.presidentPoliticalParty)
            .replacingOccurrences(of: "$governor", with: answerModel.governor)
            .replacingOccurrences(of: "$capital", with: answerModel.capital)
            .replacingOccurrences(of: "$speaker_of_house", with: answerModel.speakerOfHouse)
            .replacingOccurrences(of: "$number_supreme_court_justices", with: String(answerModel.numberOfSupremeCourtJustices))
            .replacingOccurrences(of: "$chief_justice", with: String(answerModel.chiefJustice))
        if newAnswer.count <= 0 {
            newAnswer = "Unable to "
        }
        return newAnswer
    }

    func updateQuestionAndAnswer() {
        question = questions[questionCounter].question
        answer = parseAnswersIntoString(answers: questions[questionCounter].answers)
    }

    func showNextQuestion() {
        questionsSeenOrdered.append(questionCounter)
        showAnswer = false
        shuffleQuestionsAlreadySeen.insert(questionCounter)
        questionCounter += 1
        // If we go through all the questions, then get the new list of sorted questions and start again
        if questionCounter >= questions.count {
            questions = QuestionManager.getQuestionOrderedByScore()
            questionCounter = 0
        }
        updateQuestionAndAnswer()
    }
}
