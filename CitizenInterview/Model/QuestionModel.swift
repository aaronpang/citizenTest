//
//  QuestionModel.swift
//  CitizenInterview
//
//  Created by Aaron Pang on 8/29/23.
//

import Foundation

struct QuestionModel: Decodable {
    let question: String
    let answers: [String]
    let question_id: Int
    let above_65_question: Bool
}
