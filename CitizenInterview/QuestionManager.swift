//
//  QuestionManager.swift
//  CitizenInterview
//
//  Created by Aaron Pang on 9/13/23.
//

import Foundation

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
}
