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
    
    @State private var questions : [QuestionModel] = []
    
    init() {
        self._questions = State(initialValue: parseJSONFile(forName: "Questions")!)
        let question1 = questions[0]
        self._question = State(initialValue: question1.question )
        self._answer = State(initialValue: question1.answer[0] )
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
                .onTapGesture {
                    showAnswer.toggle()
                }
            Text(question)
            Text(answer).opacity(showAnswer ? 1 : 0)
            Image(systemName: "globe").opacity(showAnswer ? 1 : 0).onTapGesture {
                showAnswer.toggle()
                questionCounter+=1
                question = questions[questionCounter].question
            }
        }
        .padding()
        .background(Color.purple)
        .frame(maxWidth: .infinity, // Full Screen Width
                                        maxHeight: .infinity, // Full Screen Height
                                        alignment: .topLeading)
    }
    
    func parseJSONFile(forName name: String) -> [QuestionModel]? {
       do {
          if let bundlePath = Bundle.main.path(forResource: name, ofType: "json"),
             let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
              do {
                  let questions: [QuestionModel] = try JSONDecoder().decode([QuestionModel].self, from: jsonData)
                  return questions
              }
              catch {
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
