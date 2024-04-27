import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class KeyboardViewController: UIInputViewController {

    var suggestionBar: UIView!
    var suggestionLabel: UILabel!
    var isLowercase = true
    var wordList: [String]?
    var isSymbolsKeyboardActive = false
    var sensitiveTextDetected = false
    var suggestionLabelHeightConstraint: NSLayoutConstraint!

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
        suggestionBar = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 65))
        suggestionBar.backgroundColor = .lightGray
        suggestionBar.layer.borderWidth = 1 // Set border width
        suggestionBar.layer.borderColor = UIColor.lightGray.cgColor // Set border color
        suggestionBar.layer.cornerRadius = 2 // Adjust the corner radius value as desired
        view.addSubview(suggestionBar)

        suggestionLabel = UILabel(frame: suggestionBar.bounds)
        suggestionLabel.textAlignment = .center
        suggestionLabel.text = ""
        suggestionBar.addSubview(suggestionLabel)

        // Add tap gesture to suggestionLabel
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(suggestionTapped))
        suggestionLabel.isUserInteractionEnabled = true
        suggestionLabel.addGestureRecognizer(tapGesture)
        
        suggestionLabelHeightConstraint = suggestionLabel.heightAnchor.constraint(equalToConstant: 0)
        suggestionLabelHeightConstraint.isActive = true
        
        let sharedDefaults = UserDefaults(suiteName: "group.UMKCAdvotech")
        let userName = sharedDefaults?.string(forKey: "userName") ?? ""
        // Keyboard name label
       // let label = UILabel()
       // label.text = "Welcome \(userName)"
       // label.textAlignment = .center
       // label.font = .systemFont(ofSize: 20)
        //label.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        //view.addSubview(label)

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
        let sharedDefaults = UserDefaults(suiteName: "group.UMKCAdvotech")
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
                suggestionLabel.text = ""
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
        suggestionLabel.text = ""

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
            sensitiveTextDetected = false // Reset flag on backspace
        } else if title == "space" {
            textDocumentProxy.insertText(" ")
            sensitiveTextDetected = false // Reset flag on space
        } else if title == "Send" || title == "Enter" { // Replace with your actual send/enter key title
            if sensitiveTextDetected {
                // Retrieve caretaker ID from shared defaults
                let sharedDefaults = UserDefaults(suiteName: "group.UMKCAdvotech")
                if let caretakerID = sharedDefaults?.string(forKey: "caretakerID") {
                    sendNotification(to: caretakerID)
                }
                sensitiveTextDetected = false // Reset the flag after sending
            }
            // (Handle sending the text or performing other actions)
        } else {
            let textToInsert = isSymbolsKeyboardActive ? title : (isLowercase ? title.lowercased() : title.uppercased())
            textDocumentProxy.insertText(textToInsert)

            if let currentText = textDocumentProxy.documentContextBeforeInput {
                // Regex for detecting sensitive information
                let ssnRegex = "(?:\\d{3}-\\d{2}-\\d{4}|\\d{9})"
                let creditCardRegex = "\\b(?:\\d{4}[ -]?){3,4}\\d{4,7}\\b"
                let medicareRegex = "\\d[A-Z]\\d{3}-[A-Z]\\d{2}-[A-Z][A-Z]\\d{2}" //for Medicare numbers
                let combinedRegex = "\(ssnRegex)|\(creditCardRegex)|\(medicareRegex)"

                if matchesRegex(combinedRegex, in: currentText) {
                    suggestionLabel.text = "⚠️ Sensitive text detected!" // Add warning emoji to the text
                    suggestionLabel.textColor = .red
                    suggestionLabel.font = UIFont.boldSystemFont(ofSize: 16)
                    suggestionLabel.backgroundColor = UIColor(red: 1, green: 0.8, blue: 0.8, alpha: 1) // Light red background
                    sensitiveTextDetected = true
                    // Update height constraint to make label visible
                    suggestionLabelHeightConstraint.constant = 65 //adjust height
                } else {
                    // Update suggestions after key press
                    let suggestions = predictWords(for: currentText)
                    if suggestions.isEmpty {
                        suggestionLabel.text = ""
                    } else {
                        suggestionLabel.text = suggestions.joined(separator: ", ")
                    }
                    sensitiveTextDetected = false // Reset the flag if no sensitive text
                    // Reset height constraint to hide label
                    suggestionLabelHeightConstraint.constant = 0
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
    //NOTIFICATION STUFF
    //
    func sendNotification(to caretakerID: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let notification = ["fromUserID": userID, "message": "Sensitive information may have been shared", "timestamp": FieldValue.serverTimestamp()] as [String : Any]
        db.collection("notifications").document(caretakerID).collection("userNotifications").addDocument(data: notification) { error in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
            } else {
                print("Notification sent successfully")
            }
        }
    }

    func predictWords(for input: String) -> [String] {
        guard let wordList = wordList else { return [] }

        // 1. Filter words starting with the input (case-insensitive)
        let filteredWords = wordList.filter {
            $0.lowercased().hasPrefix(input.lowercased())
        }

        // 2. Sort filtered words based on their position in the original list
        let sortedWords = filteredWords.sorted { (word1, word2) -> Bool in
            guard let index1 = wordList.firstIndex(of: word1),
                  let index2 = wordList.firstIndex(of: word2) else {
                return false // Handle cases where words are not found
            }
            return index1 < index2
        }
        // 3. Return the first 3 suggestions
        return Array(sortedWords.prefix(3))
    }
}
