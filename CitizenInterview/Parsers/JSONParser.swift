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
            if let bundlePath = Bundle.main.path(forResource: "States", ofType: "json"),
               let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8)
            {
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let states: [StateModel] = try decoder.decode([StateModel].self, from: jsonData)
                    var stateToCapitals: [String: String] = [:]
                    for state in states {
                        stateToCapitals[state.abbreviation] = state.capital
                    }
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

    class func parseStatesForName() -> [String: StateModel]? {
        do {
            if let bundlePath = Bundle.main.path(forResource: "States", ofType: "json"),
               let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8)
            {
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let states: [StateModel] = try decoder.decode([StateModel].self, from: jsonData)
                    var stateToCapitals: [String: StateModel] = [:]
                    for state in states {
                        stateToCapitals[state.stateName] = state
                    }
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
