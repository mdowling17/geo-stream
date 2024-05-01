//
//  AuthService.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/1/24.
//

import Foundation
import Firebase

@Observable
final class AuthService {
    private let auth = Auth.auth()
    var currentUser: FirebaseAuth.User? {
        didSet {
            print("[DEBUG INFO] AuthService:currentUser didSet: \(oldValue?.uid ?? "nil") to \(currentUser?.uid ?? "nil")")
        }
    }

    static let shared = AuthService()
    private init() {
        currentUser = auth.currentUser
    }
    
    func signIn(email: String, password: String) async throws {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            currentUser = result.user
            print("[DEBUG INFO] AuthService:signIn() result: \(result.description)")
        } catch {
            throw error
        }
    }
    
    func signUp(email: String, password: String, confirmPassword: String) async throws {
        do {
            if password != confirmPassword {
                throw MyError.runtimeError("Passwords do not match")
            }
            let result = try await auth.createUser(withEmail: email, password: password)
            currentUser = result.user
            print("[DEBUG INFO] AuthService:signUp() result: \(result.description)")
        } catch {
            print("[DEBUG ERROR] AuthService:signUp() error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func signOut() throws {
        do {
            try auth.signOut()
            currentUser = nil
        } catch {
            throw error
        }
    }
    
    func resetPassword(email: String) async throws {
        do {
            try await auth.sendPasswordReset(withEmail: email)
            print("[DEBUG ERROR] AuthService:resetPassword() result: Success")
        } catch {
            print("[DEBUG ERROR] AuthService:resetPassword() error: \(error.localizedDescription)")
            throw error
        }
    }
}

enum MyError: Error {
    case runtimeError(String)
}
