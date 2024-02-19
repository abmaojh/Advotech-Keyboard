//
//  CustomSecureField.swift
//  Advotech Keyboard
//
//  Created by Alhammadi, Abdulrahman (UMKC-Student) on 2/18/24.
//

import SwiftUI

struct CustomSecureField: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        SecureField(placeholder, text: $text)
            .textContentType(.oneTimeCode)
            .padding() // Add padding if desired
            .border(.secondary) // Or your preferred styling
    }
}

