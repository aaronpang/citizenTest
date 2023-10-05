//
//  QuestionModel.swift
//  CitizenInterview
//
//  Created by Aaron Pang on 8/29/23.
//

import Foundation

struct DynamicAnswerResultsModelStore: Codable {
    let answers: DynamicAnswerResultsModel
    let timeStored: Int
}

struct DynamicAnswerResultsModel: Codable {
    let senators: [String]
    let representatives: [String]

    let president: String
    let presidentPoliticalParty: String

    let vicePresident: String
    let governor: String
    let capital: String

    let speakerOfHouse: String

    let numberOfSupremeCourtJustices: Int
    let chiefJustice: String
}
