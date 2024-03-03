//
//  KeyboardViewController.swift
//  KeyboardAdvotech
//
//  Created by Alhammadi, Abdulrahman (UMKC-Student) on 2/19/24.
//

import UIKit

class KeyboardViewController: UIInputViewController {
    var suggestionBar: UIView!
    var suggestionLabel: UILabel!
    //@IBOutlet var nextKeyboardButton: UIButton!
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    func getCurrentUserId() -> String? {
        let sharedDefaults = UserDefaults(suiteName: "group.KeyboardAdvotech")
        return sharedDefaults?.string(forKey: "userID")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize the suggestion bar and label
           suggestionBar = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 30)) // Adjust size as needed
           suggestionBar.backgroundColor = .lightGray // Choose a suitable background color
           view.addSubview(suggestionBar)

           suggestionLabel = UILabel(frame: suggestionBar.bounds)
           suggestionLabel.textAlignment = .center
           suggestionLabel.text = "Type here..." // Default text or leave it empty
           suggestionBar.addSubview(suggestionLabel)
        
        // 1. Keyboard Name
        let label = UILabel()
        label.text = "Advotech Keyboard"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20)
        label.frame = CGRect(x: 0, y: 0, width: 200, height: 50) // Adjust as needed
        view.addSubview(label)

        // 2. Adjust keyboard background
        view.backgroundColor = .lightGray
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Update the suggestion bar frame to adjust its width and keep its height
        suggestionBar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 30)
        suggestionLabel.frame = suggestionBar.bounds  // Ensure the label covers the suggestion bar

        // Adjust startYOffset to accommodate the suggestion bar height
        let startYOffset: CGFloat = 30 // Height of the suggestion bar

        // Clear existing buttons to avoid duplication, excluding the suggestionBar and its subviews
        view.subviews.forEach { subview in
            if subview is UIButton {
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

        let keyLetters = ["1234567890", "QWERTYUIOP", "ASDFGHJKL", "ZXCVBNM", ""]

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

            // Add backspace key on the last column of the second row and space key on the last row
            if rowIndex == 2 {
                let backspaceButton = createSpecialKey(title: "⌫", startX: view.frame.width - keyWidth - keySpacing, startY: startY, width: keyWidth, height: keyHeight)
                view.addSubview(backspaceButton)
            } else if rowIndex == 3 {
                let spaceButtonWidth = availableWidth / 2 // Make the space button wider
                let spaceButtonStartX = (view.frame.width - spaceButtonWidth) / 2 // Center the space button
                let spaceButton = createSpecialKey(title: "space", startX: spaceButtonStartX, startY: startY, width: spaceButtonWidth, height: keyHeight)
                view.addSubview(spaceButton)
            }
        }
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
    }
    @objc func keyTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }
        if title == "⌫" {
            textDocumentProxy.deleteBackward()
        } else if title == "space" {
            textDocumentProxy.insertText(" ")
        } else {
            textDocumentProxy.insertText(title)
        }
        
        // Assuming textDocumentProxy.documentContextBeforeInput returns all text before the cursor
        if let currentText = textDocumentProxy.documentContextBeforeInput {
            // Regex for detecting SSN (XXX-XX-XXXX) or 9 consecutive digits
            let ssnRegex = "(?:\\d{3}-\\d{2}-\\d{4}|\\d{9})"
            // Regex for detecting credit card numbers (13 to 19 consecutive digits)
            let creditCardRegex = "\\b(?:\\d{4}[ -]?){3,4}\\d{4,7}\\b"
            
            // Combine both regex patterns
            let combinedRegex = "\(ssnRegex)|\(creditCardRegex)"
            
            if matchesRegex(combinedRegex, in: currentText) {
                suggestionLabel.text = "Sensitive text detected!"
                
                // Retrieve the user ID
                if let userId = getCurrentUserId() {
                    print("Sensitive information detected for user ID: \(userId)")
                    // Placeholder for next steps: Log event or notify user/caretaker
                }
            } else {
                suggestionLabel.text = "Type here..."
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


}
