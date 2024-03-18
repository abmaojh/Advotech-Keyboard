import UIKit

class KeyboardViewController: UIInputViewController {

    var suggestionBar: UIView!
    var suggestionLabel: UILabel!
    var isLowercase = true
    var wordList: [String]?

    override func updateViewConstraints() {
        super.updateViewConstraints()
        // Add custom view sizing constraints here
    }

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

        // Keyboard name label
        let label = UILabel()
        label.text = "Advotech Keyboard"
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

        let numRows = 5
        let numKeysPerRow = 10
        let keySpacing: CGFloat = 5
        let keyHeight: CGFloat = 40
        let totalSpacing = CGFloat(numKeysPerRow + 1) * keySpacing
        let availableWidth = view.frame.width - totalSpacing
        let keyWidth = availableWidth / CGFloat(numKeysPerRow)

        // Include lowercase letters
        let keyLetters = ["1234567890", "qwertyuiop", "asdfghjkl", "zxcvbnm", ""]

        for rowIndex in 0..<numRows {
            let rowLetters = keyLetters[rowIndex]
            let startY = startYOffset + keyHeight * CGFloat(rowIndex) + keySpacing * CGFloat(rowIndex + 1) + suggestionBar.frame.maxY

            for (colIndex, letter) in rowLetters.enumerated() {
                let keyButton = UIButton(type: .system)
                keyButton.setTitle(String(letter), for: .normal)
                keyButton.setTitleColor(.black, for: .normal)
                keyButton.backgroundColor = .white
                keyButton.layer.cornerRadius = 5

                let startX = keySpacing + CGFloat(colIndex) * (keyWidth + keySpacing)
                keyButton.frame = CGRect(x: startX, y: startY, width: keyWidth, height: keyHeight)
                keyButton.addTarget(self, action: #selector(keyTapped), for: .touchUpInside)

                view.addSubview(keyButton)
            }

            // Add backspace and space keys
            if rowIndex == 2 {
                let backspaceButton = createSpecialKey(title: "⌫", startX: view.frame.width - keyWidth - keySpacing, startY: startY, width: keyWidth, height: keyHeight)
                view.addSubview(backspaceButton)
            } else if rowIndex == 3 {
                let spaceButtonWidth = availableWidth / 2
                let spaceButtonStartX = (view.frame.width - spaceButtonWidth) / 2
                let spaceButton = createSpecialKey(title: "space", startX: spaceButtonStartX, startY: startY, width: spaceButtonWidth, height: keyHeight)
                view.addSubview(spaceButton)

                // Add lowercase/uppercase toggle button
                let toggleButton = createSpecialKey(title: "⇧", startX: keySpacing, startY: startY, width: keyWidth, height: keyHeight)
                toggleButton.addTarget(self, action: #selector(toggleCase), for: .touchUpInside)
                view.addSubview(toggleButton)
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

    @objc func keyTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }

        if title == "⌫" {
            textDocumentProxy.deleteBackward()
        } else if title == "space" {
            textDocumentProxy.insertText(" ")
        } else {
            let textToInsert = isLowercase ? title.lowercased() : title.uppercased()
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

        // Update button title to reflect current case
        sender.setTitle(isLowercase ? "⇧" : "⇩", for: .normal)

        // Update keyboard layout to reflect current case
        viewDidLayoutSubviews() // Call this to redraw the keyboard with updated case
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

    func predictWords(for input: String) -> [String] {
        guard let wordList = wordList else { return [] }

        // Filter the word list based on the input (e.g., starts with, contains)
        let filteredWords = wordList.filter { $0.hasPrefix(input) }

        // You can further refine the suggestions based on word frequency, context, etc.

        return filteredWords
    }
}