//
//  JSONParser.swift
//  CitizenInterview
//
//  Created by Aaron Pang on 9/12/23.
//

import Foundation

class JSONParser {
    class func parseQuestionsJSON() -> [QuestionModel]? {
        do {
            if let bundlePath = Bundle.main.path(forResource: "Questions", ofType: "json"),
               let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8)
            {
                do {
                    let questions: [QuestionModel] = try JSONDecoder().decode([QuestionModel].self, from: jsonData)
                    return questions
                } catch {
                    print(error)
                }
            }
            return nil
        } catch {
            print(error)
            return nil
        }
    }

    class func parseStateCapitals() -> [String: String]? {
        do {
            if let bundlePath = Bundle.main.path(forResource: "Capitals", ofType: "json"),
               let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8)
            {
                do {
                    let stateToCapitals: [String: String] = try JSONDecoder().decode([String: String].self, from: jsonData)
                    return stateToCapitals
                } catch {
                    print(error)
                }
            }
            return nil
        } catch {
            print(error)
            return nil
        }
    }
}
