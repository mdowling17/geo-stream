//
//  SignInViewModel.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/1/24.
//

import Foundation

@MainActor
class SignInViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var showPassword = false
    @Published var errorMessage: String? = nil
    
    func signIn() {
        Task {
            do {
                try await AuthService.shared.signIn(email: email, password: password)
            } catch {
                print("[DEBUG ERROR] SignInViewModel:signIn() Error: \(error.localizedDescription)\n")
                errorMessage = error.localizedDescription
            }
        }
    }
}
