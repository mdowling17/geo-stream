//
//  CustomTextField.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/1/24.
//

import SwiftUI

struct CustomTextField: View {
    var placeholder: String
    var icon: String
    var secure: Bool
    @Binding var text: String
    @Binding var showPassword: Bool
    
    init(placeholder: String, icon: String, text: Binding<String>, secure: Bool = false, showPassword: Binding<Bool> = .constant(false)) {
        self.placeholder = placeholder
        self.icon = icon
        self.secure = secure
        _text = text
        _showPassword = showPassword
    }
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color.app)
                if secure {
                    if showPassword == true {
                        TextField(placeholder, text: $text)
                            .keyboardType(.default)
                            .textContentType(.password)
                            .disableAutocorrection(true)
                            .textInputAutocapitalization(.never)
                        Image(systemName: "eye.slash")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color.app)
                            .onTapGesture {
                                showPassword.toggle()
                            }
                    } else {
                        SecureField(placeholder, text: $text)
                            .keyboardType(.default)
                            .textContentType(.password)
                            .disableAutocorrection(true)
                            .textInputAutocapitalization(.never)
                        Image(systemName: "eye")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color.app)
                            .onTapGesture {
                                showPassword.toggle()
                            }
                    }
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(.default)
                        .textContentType(.password)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                }
                
            }
            .frame(height: 20)
            Divider()
                .background(Color(.darkGray))
        }
    }
}

#Preview {
    CustomTextField(placeholder: "Password", icon: "lock", text: .constant(""), secure: true, showPassword: .constant(false))
}
