//
//  ContentView.swift
//  CitizenInterview
//
//  Created by Aaron Pang on 8/25/23.
//

import SwiftUI

struct ContentView: View {
    @State private var showAnswer = false
    @State private var question = ""
    @State private var answer = ""
    @State private var questionCounter = 0

    @State private var questions: [QuestionModel] = []

    init() {
        self._questions = State(initialValue: parseJSONFile(forName: "Questions")!)
        let question1 = questions[0]
        self._question = State(initialValue: question1.question)
        self._answer = State(initialValue: question1.answers[0])
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(String(format: "Question #%d", questionCounter + 1)).fontWeight(.bold)
            Text(question).padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
            if showAnswer {
                Text(answer)
                Button("Next Question") {
                    showAnswer.toggle()
                    questionCounter += 1
                    if questionCounter >= questions.count {
                        questionCounter = 0
                    }
                    question = questions[questionCounter].question

                    // Update the answer
                    answer = parseAnswersIntoString(answers: questions[questionCounter].answers)
                }
            } else {
                Button("Show Answer") {
                    showAnswer.toggle()
                }
            }
        }
        .padding()
        .background(Color.white)
        .frame(maxWidth: .infinity, // Full Screen Width
               maxHeight: .infinity, // Full Screen Height
               alignment: .topLeading)
    }

    private func parseAnswersIntoString(answers: [String]) -> String {
        var answerString = ""
        let appendHyphen = answers.count > 1
        answers.forEach { answer in
            answerString.append((appendHyphen ? " - " : "") + answer + "\n")
        }
        return answerString
    }

    func parseJSONFile(forName name: String) -> [QuestionModel]? {
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
