//
//  ContentView.swift
//  CitizenInterview
//
//  Created by Aaron Pang on 8/25/23.
//

import SwiftUI

struct AllQuestionsView: View {
    var answerModel: DynamicAnswerResultsModel?
    let questions: [QuestionModel] = QuestionManager.getQuestionOrderedByScore(showOnly65AboveQuestions: false, orderedQuestionsUnranked: true)

    var body: some View {
        List(questions) { question in AllQuestionView(questionModel: question, answerModel: answerModel) }
            .frame(maxWidth: .infinity, // Full Screen Width
                   maxHeight: .infinity, // Full Screen Height
                   alignment: .topLeading)
            .navigationBarTitle(Text("All Questions"))
    }
}

struct AllQuestionView: View {
    var questionModel: QuestionModel
    var answerModel: DynamicAnswerResultsModel?

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(String(questionModel.question_id) + ". " + questionModel.question)
                .foregroundColor(.primary)
                .font(.headline)
            Text(DynamicAnswerParser.parseAnswersIntoString(answers: questionModel.answers, answerModel: answerModel))
                .foregroundColor(.secondary)
                .font(.subheadline)
        }
    }
}
