//
//  ViewController.swift
//  Anagrams Project 5
//  Day 27 - 28 - 29
//  Created by Igor Polousov on 01.07.2021.
//

import UIKit

class ViewController: UITableViewController {
    
    var allWords = [String]() // Массив для всех слов из файла
    var usedWords = [String]() // Массив для использованных слов
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Кнопка справа в navigation bar с функцией promptForAnswer строка 48
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        // Кнопка слева в navigation bar с функцией startGame строка
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "New game", style: .plain, target: self, action: #selector(startGame))
        // Замыкание через которое получаем слова из файла
        // Указали путь и название файла с расширением
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // Укзал массив в который будут записаны слова если они есть
            if let startWords = try? String(contentsOf: startWordsURL) {
                // Добавили слова в allWords
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        // На случай ошибки, если в массив allWords слова не были добавлены делаем проверку и добавляем одно слово
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        // startGame() строка 37
        startGame()
    }
    
   @objc func startGame() {
        title = allWords.randomElement() // Добавляет случайное слово из allWords в title navigation bar
        usedWords.removeAll(keepingCapacity: true) // Удаление всех слов из usedWords перед началом игры
        tableView.reloadData()
    }
    
    // Количество строк в таблице
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        usedWords.count
    }
    // Что будет содержать ячейка в таблице
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    // Функция для кнопки в navigation bar
    @objc func promptForAnswer() {
        // Создали сообщение с просьбой ввести слово
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        // Добавили в сообщение текстовое поле
        ac.addTextField()
        // Замыкание с действием которое нужно сделать после ввода слова игроком
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            // указываем weak чтобы не создавалась сильная ссылка при получении замыканием данных
            [weak self, weak ac] action in
            // Проверка что массив textFields содержит буквы
            guard let answer = ac?.textFields?[0].text else { return }
            // Выполнение функции submit строка 75
            self?.submit(answer)
        }
        // Добавляем действие
            ac.addAction(submitAction)
        // Показали сообщение
            present(ac, animated: true)
        
    }
    
    func submit(_ answer:String){
        // Приводим буквы в ответе к нижнему регистру чтоы в дальнейшем было удобно делать сравнение введенных слов
        let lowerAnswer = answer.lowercased()
        // Константы для показа ошибок в случае если игрок  написал слово которого не существует или использовал буквы которых нет в слове или написал повторо слова
//
        
        
        // Проверка введенного слова при помощи трёх функций
        if isPossible(word: lowerAnswer){
            if isOriginal(word: lowerAnswer){
                if isReal(word: lowerAnswer){
                    // Если слово прошло три проверки оно добавляется в массив usedWords
                    usedWords.insert(lowerAnswer, at: 0)
                    // после того как слово добавлено в массив usedWords указываем в какое место в таблице его добавить
                    let indexPath = IndexPath(row: 0, section: 0)
                    // Добавляем строку в таблицу
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    // Если всё прошло успешно возвращаемся
                    return
                    // Иначе показываем пользователю три вида ошибок
                } else {
                    showErrorMassege(errorMasseges: .isNotPossible)
                }
            } else {
                showErrorMassege(errorMasseges: .isNotOriginal)
            }
        } else {
            showErrorMassege(errorMasseges: .isNotReal)
        }

    }
    
    // Функция проверяет можно ли составить слово из букв слова представленного в заголовке
    func isPossible(word: String) -> Bool {
        // Проверка что есть буквы в слове в заголовке в navigation bar
        guard var tempWord = title?.lowercased() else { return false }
        // Для буквы в веденном слове
        for letter in word {
            // Если буква в веденном слове равна первой букве в заголовке
            if let position = tempWord.firstIndex(of: letter) {
                // Убрать букву
                tempWord.remove(at: position)
                // Иначе вернуть что буквы нет
            } else {
                return false
            }
        }
        // Возвращаем что все буквы в слове соотвествуют буквам в заголовке
        return true
    }
   // Функция которая делает проверку на повтор
    func isOriginal(word: String) -> Bool {
        // Если массив usedWords не содержит введенное слово
        return !usedWords.contains(word)
    }
    // Функция делает проверку на существование слова
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        
        // Если слово короче 3 букв, то вернет false
        if word.utf16.count <= 2 {
            showErrorMassege(errorMasseges: .isNotRealTooShort)
            return false
        }
        // Если слово такое же как и слово в заголовке
        guard let checkWord = title?.lowercased() else { return false }
        if word == checkWord {
            showErrorMassege(errorMasseges: .isNotRealSameWord)
            return false
        }
        
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
  
    
    enum ErrorMasseges {
        case isNotPossible
        case isNotOriginal
        case isNotReal
        case isNotRealTooShort
        case isNotRealSameWord
        
    }
    
    func showErrorMassege(errorMasseges: ErrorMasseges) {
        let errorTitle: String
        let errorMessage: String
        
        switch errorMasseges {
        case .isNotPossible:
            errorTitle = "Word not recognized"
            errorMessage = "You can't just make them up, you know!"
            
        case .isNotOriginal:
        errorTitle = "Word used already"
        errorMessage = "Try to be more original"
            
        case .isNotReal:
            guard let title = title?.lowercased() else { return }
            errorTitle =  "Word not possible"
            errorMessage = "You can't spell that word from \(title)"
            
        case .isNotRealTooShort:
            errorTitle = "Word is too short"
            errorMessage = "You have to use words contains more than two letters"
            
        case .isNotRealSameWord:
            errorTitle = "Word is the same as original"
            errorMessage = "You need to use different words from original"
        }
        
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
    }
    
}

