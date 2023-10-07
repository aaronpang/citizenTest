//
//  QuestionManager.swift
//  CitizenInterview
//
//  Created by Aaron Pang on 9/13/23.
//

import Foundation

enum OfficialRole: String, Codable {
    case none
    case president
    case vicePresident
    case senator
    case representative
    case governor
}

struct Official: Codable {
    let name: String
    let party: String
    let role: OfficialRole
}

struct OfficeResult: Decodable {
    let levels: [String]
    let roles: [String]
    let officialIndices: [Int]
}

struct OfficialResult: Decodable {
    let name: String
    let party: String
}

struct RepresentativesResult: Decodable {
    let offices: [OfficeResult]
    let officials: [OfficialResult]
}

class QuestionManager {
    static let questions: [QuestionModel]? = JSONParser.parseQuestionsJSON()

    class func updateQuestionScore(questionID: Int, scoreDifference: Int) {
        let userDefaults = UserDefaults.standard
        var questions: [Int: Int] = [:]
        // Question ID : Score
        if let questionsFromUserDefaults = userDefaults.object(forKey: "questions") as? [NSString: NSNumber] {
            for questionFromUserDefaults in questionsFromUserDefaults {
                questions[Int(questionFromUserDefaults.key.intValue)] = questionFromUserDefaults.value.intValue
            }
        } else {
            // If it was never initialized, initialize the array
            if let questionModels = QuestionManager.questions {
                var questionsToSave: [Int: Int] = [:]
                for questionModel in questionModels {
                    questionsToSave[questionModel.question_id] = 0
                }
                questions = questionsToSave
            }
        }
        guard let score = questions[questionID] else { return }
        questions[questionID] = score + scoreDifference
        // Convert questions to NSString : NSNumber
        var storableQuestions: [NSString: NSNumber] = [:]
        for question in questions {
            storableQuestions[NSString(format: "%d", question.key)] = NSNumber(value: question.value)
        }
        userDefaults.set(storableQuestions, forKey: "questions")
    }

    class func getQuestionOrderedByScore(showOnly65AboveQuestions: Bool, orderedQuestionsUnranked: Bool) -> [QuestionModel] {
        guard let questions = QuestionManager.questions else { return [] }
        // Parse the questions and get them ordered based on their score
        var sortedQuestionToReturn: [QuestionModel] = []
        // Create dictioanry of question_id : questions
        var questionIDToQuestionModel: [Int: QuestionModel] = [:]
        for question in questions {
            questionIDToQuestionModel[question.question_id] = question
        }
        let userDefaults = UserDefaults.standard
        // If we are going to show the questions ordered and unranked then don't even pull the question scores
        if !orderedQuestionsUnranked, let questionScoreDict = userDefaults.object(forKey: "questions") as? [NSString: NSNumber] {
            // Convert it to Int : Int
            var convertedQuestionScoreDict: [Int: Int] = [:]
            for questionScore in questionScoreDict {
                convertedQuestionScoreDict[questionScore.key.integerValue] = questionScore.value.intValue
            }
            let questionSortedDict = convertedQuestionScoreDict.sorted(by: { $0.value < $1.value })
            var sortedQuestions: [QuestionModel] = []
            // This is now ordered by lowest scoring question to highest scoring question
            for questionID in questionSortedDict {
                // Create the question model list based on this new ordering
                if let questionModel = questionIDToQuestionModel[questionID.key] {
                    sortedQuestions.append(questionModel)
                }
            }
            sortedQuestionToReturn = sortedQuestions
        } else {
            // Assume all questions have score of 0 so just return the questions ordered
            sortedQuestionToReturn = questions
        }

        // Filter out only the questions that are for above age 65
        if showOnly65AboveQuestions {
            return sortedQuestionToReturn.filter { questionModel in
                questionModel.above_65_question
            }
        } else {
            return sortedQuestionToReturn
        }
    }

    class func fetchData(locationManager: LocationManager, completion: @escaping (DynamicAnswerResultsModel?, Error?) -> Void) {
        // Check if the data is cached with a refresh date of < 2 months, then fetch the info
        var urlComponents = URLComponents(string: "https://www.googleapis.com/civicinfo/v2/representatives")!
        urlComponents.queryItems = [
            URLQueryItem(name: "address", value: locationManager.location),
            URLQueryItem(name: "key", value: "AIzaSyCOGbH_RzRwROVMroT7EFklR9sVpIj43Y4")
        ]
        let url = urlComponents.url!
        let zipCode = locationManager.zipCode
        let userDefaults = UserDefaults.standard

        // Check we have an answer model stored within the device that is not stale < 2 months
        if let answerModel = userDefaults.value(forKey: "dynamic_answers_for_zip_" + zipCode) as? Data {
            let decoder = JSONDecoder()
            if let loadedAnswerModelStore = try? decoder.decode(DynamicAnswerResultsModelStore.self, from: answerModel) {
                let time = Int(NSDate().timeIntervalSince1970)
                if time - loadedAnswerModelStore.timeStored < 5256000 { // Greater than 2 months
                    completion(loadedAnswerModelStore.answers, nil)
                    return
                }
            }
        }

        // If we don't have a cached result or if the info is state for the zip code then do a fetch!
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else { return }
            do {
                let representativeResults = try JSONDecoder().decode(RepresentativesResult.self, from: data)
                // Create list of officials with their official name
                var officials: [Official] = []
                for office in representativeResults.offices {
                    for officialIndex in office.officialIndices {
                        let officialResult = representativeResults.officials[officialIndex]
                        let role = QuestionManager.officialRoleFromRolesAndLevels(roles: office.roles,
                                                                                  levels: office.levels)
                        if role != .none {
                            let official = Official(name: officialResult.name,
                                                    party: officialResult.party,
                                                    role: role)
                            officials.append(official)
                        }
                    }
                }
                let senators = QuestionManager.officalNames(officials: officials, role: .senator, location: locationManager.location)
                let representatives = QuestionManager.officalNames(officials: officials, role: .representative, location: locationManager.location)
                let president = QuestionManager.officalNames(officials: officials, role: .president, location: locationManager.location)[0]
                let vicePresident = QuestionManager.officalNames(officials: officials, role: .vicePresident, location: locationManager.location)[0]
                let governor = QuestionManager.officalNames(officials: officials, role: .governor, location: locationManager.location)[0]
                let presidentPoliticalParty =
                    officials.filter {
                        $0.role == .president
                    }.map { official in
                        official.party
                    }[0]
                let stateCapitals = JSONParser.parseStateCapitals() ?? [:]
                let state = locationManager.state
                let capital = stateCapitals[state] ?? String(format: "Couldn't find capital for state %@. Please search this up online.", state)
                let answers = DynamicAnswerResultsModel(senators: senators,
                                                        representatives: representatives,
                                                        president: president,
                                                        presidentPoliticalParty: presidentPoliticalParty,
                                                        vicePresident: vicePresident,
                                                        governor: governor,
                                                        capital: capital,
                                                        speakerOfHouse: "Patrick McHenry",
                                                        numberOfSupremeCourtJustices: 9,
                                                        chiefJustice: "John Roberts") // Don't hard code these
                // Cache the information per zip code with a timeout of 2 months so we don't fetch every time the user taps on Begin Quiz
                let time = Int(NSDate().timeIntervalSince1970)
                let modelStore = DynamicAnswerResultsModelStore(answers: answers, timeStored: time)
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(modelStore) {
                    userDefaults.setValue(encoded, forKey: "dynamic_answers_for_zip_" + locationManager.zipCode)
                }

                completion(answers, nil)
            } catch {
                print(error)
                completion(nil, error)
            }
        }
        task.resume()
    }

    class func officalNames(officials: [Official], role: OfficialRole, location: String) -> [String] {
        let names = officials.filter {
            $0.role == role
        }.map { official in
            official.name
        }
        if names.count <= 0 {
            return ["Unable to retrieve information. Please visit the (USCIS government website)[uscis.gov/citizenship/testupdates] for updates."]
        }
        return names
    }

    class func officialRoleFromRolesAndLevels(roles: [String], levels: [String]) -> OfficialRole {
        if roles.contains("headOfGovernment") {
            // President or Governor
            if levels.contains("country") {
                return .president
            } else if levels.contains("administrativeArea1") {
                return .governor
            }
        }
        if roles.contains("deputyHeadOfGovernment") && levels.contains("country") {
            return .vicePresident
        }
        if roles.contains("legislatorUpperBody") && levels.contains("country") {
            return .senator
        }
        if roles.contains("legislatorLowerBody") && levels.contains("country") {
            return .representative
        }
        return .none
    }
}
