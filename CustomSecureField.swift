//
//  CustomSecureField.swift
//  Advotech Keyboard
//
//  Created by Alhammadi, Abdulrahman (UMKC-Student) on 2/18/24.
//

import Foundation
import SwiftUI

struct CustomSecureField: UIViewRepresentable {
    var placeholder: String
    @Binding var text: String

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.isSecureTextEntry = true
        textField.placeholder = placeholder
        textField.textContentType = .oneTimeCode // Prevents strong password suggestions
        textField.borderStyle = .roundedRect
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var text: Binding<String>

        init(text: Binding<String>) {
            self.text = text
        }
        func textFieldDidChangeSelection(_ textField: UITextField) {
            text.wrappedValue = textField.text ?? ""
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
}
