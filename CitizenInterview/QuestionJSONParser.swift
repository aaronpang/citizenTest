//
//  JSONParser.swift
//  CitizenInterview
//
//  Created by Aaron Pang on 9/12/23.
//

import Foundation

class QuestionJSONParser {
    class func parse(forName name: String) -> [QuestionModel]? {
        do {
            if let bundlePath = Bundle.main.path(forResource: name, ofType: "json"),
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
}
