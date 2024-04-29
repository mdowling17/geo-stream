//
//  AuthViewModel.swift
//  GeoStream
//
//  Created by Zirui Wang on 4/29/24.
//

import Foundation

import Foundation
import Firebase

class AuthViewModel: ObservableObject {
    @Published var errorMessage: String? = nil
    @Published var isSignedIn: Bool = false
    @Published var profileAdded: Bool = false
    let auth = Auth.auth()
    
    var curUserId: String {
        if let user = auth.currentUser {
            user.uid
        }
        else {
            "No User Logged In"
        }
    }
    
    var curUserEmail: String {
        if let user = auth.currentUser {
            user.email ?? "No email found"
        } else {
            "No user logged in"
        }
    }
    
    func signIn(email: String, password: String) {
        auth.signIn(withEmail: email, password: password) {result, error in
            guard result != nil, error == nil else {
                self.errorMessage = error?.localizedDescription
                return
            }
            self.isSignedIn = true
            self.profileAdded = true
        }
    }
    
    func signUp(email: String, password: String, confirmPassword: String, completion: @escaping (Bool) -> Void) {
        if password != confirmPassword {
            self.errorMessage = "Password not matching"
            return
        }
        auth.createUser(withEmail: email, password: password) { result, error in
            guard result != nil, error == nil else {
                self.errorMessage = error?.localizedDescription
                return
            }
            self.isSignedIn = true
            completion(true)
        }
    }
    
    func signOut() {
        do {
            try auth.signOut()
            self.isSignedIn = false
        }
        catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
