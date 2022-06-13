//
//  ViewController.swift
//  Project5 - Word Scramble
//
//  Created by Vitali Vyucheiski on 3/13/22.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = [String()]
    var usedWords = [String()]
    var errorTitle = ""
    var errorMessege = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        startGame()
        
        let defaults = UserDefaults.standard
        
        title = defaults.string(forKey: "title")
        usedWords = defaults.object(forKey: "usedWords") as? [String] ?? usedWords
    }

    @objc func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }

    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        
        if isPosible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    usedWords.insert(answer.lowercased(), at: 0)
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    save(usedWords: usedWords, title: title!)
                    
                    return
                } else {
                    errorTitle = "Word not recognized"
                    errorMessege = "You can't just make them up, you know!"
                }
            } else {
                errorTitle = "Word already used"
                errorMessege = "Be more original!"
            }
        } else {
            errorTitle = "Word not posible"
            errorMessege = "You can't spell that word from \(title!.lowercased())"
        }
        
        showErrorMessage(title: errorTitle, messege: errorMessege)
    }
    
    func isPosible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        if word.count < 3 {
            errorTitle = "Word is less then 3 characters"
            errorMessege = "You can't use word that less then 3 characters"
            showErrorMessage(title: errorTitle, messege: errorMessege)
            return false
        } else {
            if word == title?.lowercased() {
                errorTitle = "Same word"
                errorMessege = "You can't use same word"
                showErrorMessage(title: errorTitle, messege: errorMessege)
                return false
            }
        }
        
        return misspelledRange.location == NSNotFound
    }
    
    func showErrorMessage(title:String, messege:String) {
        let ac = UIAlertController(title: title, message: messege, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func save(usedWords: [String], title: String) {
        let defaults = UserDefaults.standard
        
        defaults.set(usedWords, forKey: "usedWords")
        defaults.set(title, forKey: "title")
    }
}

