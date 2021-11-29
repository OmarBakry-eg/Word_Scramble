//
//  ContentView.swift
//  Word Scramble
//
//  Created by Omar Bakry on 29/11/2021.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords : [String] = []
    @State private var rootWord : String = ""
    @State private var newWord : String = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationView{
            List{
                Section{
                    TextField("Enter your word", text: $newWord).onSubmit {
                        addNewWord()
                    }.autocapitalization(.none) // make keyboard lower cased as default.
                }
                
                Section {
                    ForEach(usedWords , id : \.self){ word in
                        HStack {
                            // word : String
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }.navigationTitle(rootWord)
                .onAppear(perform: startGame)
                .alert(errorTitle, isPresented: $showingError) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(errorMessage)
                }
        }
      
            
        }
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func startGame(){
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWordsString = try? String(contentsOf: startWordsURL)
            {
                let allWords : [String] = startWordsString.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "Bakry"
                return
            }
        }
        fatalError("Could not load start.txt from bundle.")
    }
    
    func addNewWord(){
        let newWord = self.newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        // checking if newWord have a char after removing spaces or not
        guard newWord.isOriginal(arryOfStrings: usedWords) else {
            wordError(title: "Word used already", message: "Be more original")
               return
        }
        guard newWord.isPossible(rootWord: rootWord) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }

        guard newWord.isReal() else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        guard newWord.count > 0 else{return}
        withAnimation {
            usedWords.insert(newWord, at: 0)
        }
        self.newWord = ""
    }
    }

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}




extension String{
    func isOriginal(arryOfStrings: [String]) -> Bool {
        !arryOfStrings.contains(self)
    }
    func isPossible(rootWord:String) -> Bool {
        var tempWord = rootWord

        for letter in self {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }

        return true
    }
    func isReal() -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: self.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: self, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
}
