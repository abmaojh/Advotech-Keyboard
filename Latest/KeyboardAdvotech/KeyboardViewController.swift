import UIKit

class KeyboardViewController: UIInputViewController {

    var suggestionBar: UIView!
    var suggestionLabel: UILabel!
    var isLowercase = true
    var wordList: [String]?
    var isSymbolsKeyboardActive = false

    override func updateViewConstraints() {
        super.updateViewConstraints()
        // Add custom view sizing constraints here
    }
    let symbolsKeyboardLayout = ["1234567890",
                                 "!@#$%^&*()",
                                 "+-=_\\|/?",
                                 ".:;'\"/"]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize suggestion bar and label
        suggestionBar = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 30))
        suggestionBar.backgroundColor = .lightGray
        view.addSubview(suggestionBar)

        suggestionLabel = UILabel(frame: suggestionBar.bounds)
        suggestionLabel.textAlignment = .center
        suggestionLabel.text = "Type here..."
        suggestionBar.addSubview(suggestionLabel)

        // Add tap gesture to suggestionLabel
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(suggestionTapped))
        suggestionLabel.isUserInteractionEnabled = true
        suggestionLabel.addGestureRecognizer(tapGesture)
        
        let sharedDefaults = UserDefaults(suiteName: "group.KeyboardAdvotech")
        let userName = sharedDefaults?.string(forKey: "userName") ?? ""
        // Keyboard name label
        let label = UILabel()
        label.text = "Welcome \(userName)"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20)
        label.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        view.addSubview(label)

        // Keyboard background
        view.backgroundColor = .lightGray

        // Load word list
        if let path = Bundle.main.path(forResource: "words", ofType: "txt") {
            do {
                let data = try String(contentsOfFile: path, encoding: .utf8)
                wordList = data.components(separatedBy: "\n")
            } catch {
                print("Error loading word list: \(error)")
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update suggestion bar frame
        suggestionBar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 30)
        suggestionLabel.frame = suggestionBar.bounds

        // Adjust startYOffset for suggestion bar
        let startYOffset: CGFloat = 30

        // Clear existing buttons
        view.subviews.forEach { subview in
            if subview is UIButton && subview != suggestionBar {
                subview.removeFromSuperview()
            }
        }

        let numRows = 4
        let numKeysPerRow = 10
        let keySpacing: CGFloat = 5
        let keyHeight: CGFloat = 40
        let totalSpacing = CGFloat(numKeysPerRow + 1) * keySpacing
        let availableWidth = view.frame.width - totalSpacing
        let keyWidth = availableWidth / CGFloat(numKeysPerRow)

        // Include lowercase letters
        let keyLetters = isSymbolsKeyboardActive ? symbolsKeyboardLayout : ["qwertyuiop", "asdfghjkl", "zxcvbnm", ""]
        for rowIndex in 0..<numRows {
            let rowLetters = keyLetters[rowIndex]
            let startY = startYOffset + keyHeight * CGFloat(rowIndex) + keySpacing * CGFloat(rowIndex + 1) + suggestionBar.frame.maxY
            // Calculate total width of letters in the row
            let totalLetterWidth = CGFloat(rowLetters.count) * keyWidth + CGFloat(rowLetters.count - 1) * keySpacing
            // Calculate starting x position for centering
            let startXOffset = (view.frame.width - totalLetterWidth) / 2


            for (colIndex, letter) in rowLetters.enumerated() {
                let keyButton = UIButton(type: .system)
                keyButton.setTitle(String(letter), for: .normal)
                keyButton.setTitleColor(.black, for: .normal)
                keyButton.backgroundColor = .white
                keyButton.layer.cornerRadius = 5

                let startX = startXOffset + CGFloat(colIndex) * (keyWidth + keySpacing)
                keyButton.frame = CGRect(x: startX, y: startY, width: keyWidth, height: keyHeight)
                keyButton.addTarget(self, action: #selector(keyTapped), for: .touchUpInside)

                view.addSubview(keyButton)
            }

            // Add backspace and space keys
            if rowIndex == 2 {
                // Uppercase/lowercase toggle button (on the left)
                           let toggleCaseButton = createSpecialKey(title: isLowercase ? "⇧" : "⇩",
                                                                   startX: keySpacing,
                                                                   startY: startY,
                                                                   width: keyWidth, height: keyHeight)
                           toggleCaseButton.addTarget(self, action: #selector(toggleCase), for: .touchUpInside)
                           view.addSubview(toggleCaseButton)

                           // Backspace button (on the right)
                           let backspaceButton = createSpecialKey(title: "⌫",
                                                                   startX: view.frame.width - keyWidth - keySpacing,
                                                                   startY: startY,
                                                                   width: keyWidth, height: keyHeight)
                           view.addSubview(backspaceButton)
                
            } else if rowIndex == 3 {
                // Symbols/letters toggle button (on the left)
                           let toggleKeyboardButton = createSpecialKey(title: isSymbolsKeyboardActive ? "ABC" : "123",
                                                                       startX: keySpacing,
                                                                       startY: startY,
                                                                       width: keyWidth, height: keyHeight)
                           toggleKeyboardButton.addTarget(self, action: #selector(toggleKeyboard), for: .touchUpInside)
                           view.addSubview(toggleKeyboardButton)

                           // Space button (adjust width and position)
                // Space button (centered)
                    let spaceButtonWidth = availableWidth - 2 * keyWidth - 3 * keySpacing
                    let spaceButtonStartX = (view.frame.width - spaceButtonWidth) / 2
                    let spaceButton = createSpecialKey(title: "space",
                                                        startX: spaceButtonStartX,
                                                        startY: startY,
                                                        width: spaceButtonWidth, height: keyHeight)
                    view.addSubview(spaceButton)
               }
        }
    }

    func getCurrentUserId() -> String? {
        let sharedDefaults = UserDefaults(suiteName: "group.KeyboardAdvotech")
        return sharedDefaults?.string(forKey: "userID")
    }

    func createSpecialKey(title: String, startX: CGFloat, startY: CGFloat, width: CGFloat, height: CGFloat) -> UIButton {
        let specialKey = UIButton(type: .system)
        specialKey.setTitle(title, for: .normal)
        specialKey.setTitleColor(.black, for: .normal)
        specialKey.backgroundColor = .white
        specialKey.layer.cornerRadius = 5
        specialKey.frame = CGRect(x: startX, y: startY, width: width, height: height)
        specialKey.addTarget(self, action: #selector(keyTapped), for: .touchUpInside)
        return specialKey
    }

    override func viewWillLayoutSubviews() {
        // self.nextKeyboardButton.isHidden = !self.needsInputModeSwitchKey
        super.viewWillLayoutSubviews()
    }

    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }

    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.

        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
        // self.nextKeyboardButton.setTitleColor(textColor, for: [])

        if let currentText = textDocumentProxy.documentContextBeforeInput {
            let suggestions = predictWords(for: currentText)
            if suggestions.isEmpty {
                suggestionLabel.text = "Type here..."
            } else {
                suggestionLabel.text = suggestions.joined(separator: ", ")
            }
        }
    }
    @objc func showSymbols(_ sender: UIButton) {
        isSymbolsKeyboardActive = true
        viewDidLayoutSubviews()
    }
    @objc func toggleKeyboard(_ sender: UIButton) {
        isSymbolsKeyboardActive = !isSymbolsKeyboardActive
        viewDidLayoutSubviews() // Update keyboard display

        // Clear any existing text in the suggestion bar
        suggestionLabel.text = "Type here..."

        // Update the button title to reflect the new state
        sender.setTitle(isSymbolsKeyboardActive ? "ABC" : "123", for: .normal)

        // Prevent text insertion by clearing the title for both highlighted and selected states
        sender.setTitle("", for: .highlighted)
        sender.setTitle("", for: .selected)
    }

    @objc func keyTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal),
                  title != "⇧" && title != "⇩" && title != "ABC" && title != "123" else { return }

        if title == "⌫" {
            textDocumentProxy.deleteBackward()
        } else if title == "space" {
            textDocumentProxy.insertText(" ")
        } else {
            let textToInsert = isSymbolsKeyboardActive ? title : (isLowercase ? title.lowercased() : title.uppercased())
                   textDocumentProxy.insertText(textToInsert)
        }

        if let currentText = textDocumentProxy.documentContextBeforeInput {
            // Regex for detecting sensitive information
            let ssnRegex = "(?:\\d{3}-\\d{2}-\\d{4}|\\d{9})"
            let creditCardRegex = "\\b(?:\\d{4}[ -]?){3,4}\\d{4,7}\\b"
            let combinedRegex = "\(ssnRegex)|\(creditCardRegex)"

            if matchesRegex(combinedRegex, in: currentText) {
                suggestionLabel.text = "Sensitive text detected!"

                if let userId = getCurrentUserId() {
                    print("Sensitive information detected for user ID: \(userId)")
                    // Placeholder for next steps: Log event or notify user/caretaker
                }
            } else {
                // Update suggestions after key press
                let suggestions = predictWords(for: currentText)
                if suggestions.isEmpty {
                    suggestionLabel.text = "Type here..."
                } else {
                    suggestionLabel.text = suggestions.joined(separator: ", ")
                }
            }
        }
    }

    @objc func toggleCase(_ sender: UIButton) {
        isLowercase = !isLowercase

        // Update button title
        sender.setTitle(isLowercase ? "⇧" : "⇩", for: .normal)

        // Update letter button titles
        for subview in view.subviews {
            if let button = subview as? UIButton, let title = button.title(for: .normal), title.count == 1 {
                button.setTitle(isLowercase ? title.lowercased() : title.uppercased(), for: .normal)
            }
        }
    }

    func matchesRegex(_ regex: String, in text: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            return results.count > 0
        } catch let error {
            print("Invalid regex: \(error.localizedDescription)")
            return false
        }
    }
    @objc func suggestionTapped(_ gesture: UITapGestureRecognizer) {
        guard let suggestionLabel = gesture.view as? UILabel,
              let suggestionText = suggestionLabel.text else { return }

        let words = suggestionText.components(separatedBy: ", ")
        let tapLocation = gesture.location(in: suggestionLabel)

        for (index, word) in words.enumerated() {
            let wordSize = (word as NSString).size(withAttributes: [.font: suggestionLabel.font])
            let wordRect = CGRect(x: suggestionLabel.textRect(forBounds: suggestionLabel.bounds, limitedToNumberOfLines: 1).origin.x + CGFloat(index) * (wordSize.width + 2 /* Increased spacing */),
                                  y: 0,
                                  width: wordSize.width,
                                  height: wordSize.height)
            
            if wordRect.contains(tapLocation) {
                // Delete existing text before inserting the suggestion
                if let currentText = textDocumentProxy.documentContextBeforeInput {
                    for _ in 0..<currentText.count {
                        textDocumentProxy.deleteBackward()
                    }
                }
                textDocumentProxy.insertText(word)
                break // Word found, stop iterating
            }
        }
    }

    func predictWords(for input: String) -> [String] {
        guard let wordList = wordList else { return [] }
        // Filter based on input
        let filteredWords = wordList.filter { $0.hasPrefix(input) }
        // Return first 3 suggestions
        return Array(filteredWords.prefix(3))
    }
}
