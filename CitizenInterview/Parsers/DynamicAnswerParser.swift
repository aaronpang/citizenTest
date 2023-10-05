//
//  QuestionManager.swift
//  CitizenInterview
//
//  Created by Aaron Pang on 9/13/23.
//

import Foundation

class DynamicAnswerParser {
    class func parseAnswersIntoString(answers: [String], answerModel: DynamicAnswerResultsModel?) -> String {
        guard let answerModel else { return "" }
        var answerString = ""
        let appendHyphen = answers.count > 1
        answers.forEach { answer in
            // Convert answer tokens from dynamic answer model
            let convertedAnswer = convertAnswerTokens(answer: answer, answerModel: answerModel)
            // If answer is a certain key then pull the dynamic data that way
            answerString.append((appendHyphen ? "- " : "") + convertedAnswer.localizedCapitalized + "\n")
        }
        // Remove the final \n
        answerString = answerString.trimmingCharacters(in: .whitespacesAndNewlines)
        return answerString
    }

    private static func convertAnswerTokens(answer: String, answerModel: DynamicAnswerResultsModel) -> String {
        var newAnswer = answer
            .replacingOccurrences(of: "$president", with: answerModel.president)
            .replacingOccurrences(of: "$vice_president", with: answerModel.vicePresident)
            .replacingOccurrences(of: "$party_of_president", with: answerModel.presidentPoliticalParty)
            .replacingOccurrences(of: "$governor", with: answerModel.governor)
            .replacingOccurrences(of: "$capital", with: answerModel.capital)
            .replacingOccurrences(of: "$speaker_of_house", with: answerModel.speakerOfHouse)
            .replacingOccurrences(of: "$number_supreme_court_justices", with: String(answerModel.numberOfSupremeCourtJustices))
            .replacingOccurrences(of: "$chief_justice", with: String(answerModel.chiefJustice))
        if newAnswer == "$senators" {
            var senatorString = ""
            let appendHyphen = answerModel.senators.count > 1
            answerModel.senators.forEach { senator in
                senatorString.append((appendHyphen ? " - " : "") + senator.localizedCapitalized + "\n")
            }
            newAnswer = senatorString
        } else if newAnswer == "$representatives" {
            var representativeString = ""
            let appendHyphen = answerModel.senators.count > 1
            answerModel.representatives.forEach { representative in
                representativeString.append((appendHyphen ? " - " : "") + representative.localizedCapitalized + "\n")
            }
            newAnswer = representativeString
        }
        return newAnswer
    }
}
