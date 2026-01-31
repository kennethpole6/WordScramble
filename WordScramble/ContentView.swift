//
//  ContentView.swift
//  WordScramble
//
//  Created by kenneth pole on 1/31/26.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWord = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""

    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                Section {
                    ForEach(usedWord, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
        }
        .onAppear(perform: startGame)
        .onSubmit(addNewWord)
        .alert(isPresented: $showingError) {
            Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word already in use", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not in dictionary", message: "Try again with a different word from \(rootWord)")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word is not real", message: "Try again with a different word")
            return
        }
        
        withAnimation {
            usedWord.insert(answer, at: 0)
        }
        newWord = ""
    }

    func startGame() {
        if let url = Bundle.main.url(forResource: "start", withExtension: "txt")
        {
            do {
                let contents = try String(contentsOf: url, encoding: .utf8)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                let lines =
                    contents
                    .components(separatedBy: .newlines)
                    .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                if let random = lines.randomElement() {
                    rootWord = random
                    return
                }
            } catch {
                // Fall through to fallback below
                print("Error reading start.txt: \(error)")
            }
        } else {
            print("start.txt not found in bundle")
        }
        // Fallback if loading fails
        rootWord = "silkworm"
    }

    func isOriginal(word: String) -> Bool {
        return !usedWord.contains(word)
    }

    func isPossible(word: String) -> Bool {
        var tempWord = rootWord

        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }

    func isReal(word: String) -> Bool {
        // Enforce a minimum length to avoid very short words
        if word.count < 3 { return false }

        let checker = UITextChecker()
        let nsWord = word as NSString
        let range = NSRange(location: 0, length: nsWord.length)

        // Check for misspellings using English dictionary
        let misspelledRange = checker.rangeOfMisspelledWord(
            in: word,
            range: range,
            startingAt: 0,
            wrap: false,
            language: "en"
        )
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }

}

#Preview {
    ContentView()
}
