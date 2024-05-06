//
//  SignUpViewModel.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/1/24.
//

import Foundation
import SwiftUI

@MainActor
class SignUpViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var showPassword = false
    @Published var showConfirmPassword = false
    @Published var errorMessage: String? = nil
    @Published var errorMessageColor: Color = .red
    func signUp() {
        Task {
            do {
                try await AuthService.shared.signUp(email: email, password: password, confirmPassword: password)
                errorMessage = "Successfully signed up!"
                errorMessageColor = .app
                email = ""
                password = ""
                confirmPassword = ""
            } catch {
                print("[DEBUG ERROR] SignUpViewModel:signUp() Error: \(error.localizedDescription)\n")
                errorMessage = error.localizedDescription
                errorMessageColor = .red
            }
        }
    }
}
