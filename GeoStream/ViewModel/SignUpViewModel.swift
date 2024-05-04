//
//  SignUpViewModel.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/1/24.
//

import Foundation

@MainActor
class SignUpViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var showPassword = false
    @Published var showConfirmPassword = false
    @Published var errorMessage: String? = nil
    
    func signUp() {
        Task {
            do {
                try await AuthService.shared.signUp(email: email, password: password, confirmPassword: password)
            } catch {
                print("[DEBUG ERROR] SignUpViewModel:signUp() Error: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
            }
        }
    }
}
