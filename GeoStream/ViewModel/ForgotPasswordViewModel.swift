//
//  ForgotPasswordViewModel.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/1/24.
//

import Foundation

class ForgotPasswordViewModel: ObservableObject {
    @Published var email = ""
    @Published var errorMessage: String? = nil
    
    func resetPassword() {
        Task {
            do {
                try await AuthService.shared.resetPassword(email: email)
            } catch {
                print("[DEBUG ERROR] ForgotPasswordViewModel:resetPassword() Error: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
            }
        }
    }
}
