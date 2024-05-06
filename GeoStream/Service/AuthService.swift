//
//  AuthService.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/1/24.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Combine

@Observable
final class AuthService {
    private let auth = Auth.auth()
    let db = Firestore.firestore()
    var userPublisher = PassthroughSubject<User, Error>()
    var finishedLoadingUser = false
    
    var currentUser: User? {
        didSet {
            print("[DEBUG INFO] AuthService:currentUser didSet: \(oldValue?.id ?? "nil") to \(currentUser?.id ?? "nil")\n")
        }
    }
    
    var currentFirebaseUser: FirebaseAuth.User? {
        didSet {
            print("[DEBUG INFO] AuthService:currentUser didSet: \(oldValue?.uid ?? "nil") to \(currentFirebaseUser?.uid ?? "nil")\n")
        }
    }

    static let shared = AuthService()
    private init() {
        currentFirebaseUser = auth.currentUser
        if let userId = currentFirebaseUser?.uid {
            getUser(userId: userId)
        } else {
            finishedLoadingUser = true
        }
    }
    
    func signIn(email: String, password: String) async throws {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            currentFirebaseUser = result.user
            currentUser = try? await UserService.shared.fetchProfile(userId: result.user.uid)
            print("[DEBUG INFO] AuthService:signIn() result: \(result.description)\n")
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
            let userId = result.user.uid
            let _ = try await UserService.shared.saveProfile(userId: userId, email: email)

            print("[DEBUG INFO] AuthService:signUp() result: \(result.description)\n")
        } catch {
            print("[DEBUG ERROR] AuthService:signUp() error: \(error.localizedDescription)\n")
            throw error
        }
    }
    
    func signOut() throws {
        do {
            try auth.signOut()
            currentUser = nil
            currentFirebaseUser = nil
        } catch {
            throw error
        }
    }
    
    func resetPassword(email: String) async throws {
        do {
            try await auth.sendPasswordReset(withEmail: email)
            print("[DEBUG ERROR] AuthService:resetPassword() result: Success\n")
        } catch {
            print("[DEBUG ERROR] AuthService:resetPassword() error: \(error.localizedDescription)\n")
            throw error
        }
    }
    
    func getUser(userId: String) {
        Task {
            do {
                let user = try await UserService.shared.fetchProfile(userId: userId)
                currentUser = user
            } catch {
                print("[DEBUG ERROR] AuthService:getUser() error: \(error.localizedDescription)\n")
            }
            finishedLoadingUser = true
        }
    }
    
    func listenToUsersDatabase() {
        guard let currentUserId = currentUser?.id else {
            print("[DEBUG] AuthService:listenToUsersDatabase currentUser.id is nil")
            return
        }
        let querySnapshot =  db.collection(User.collectionName).document(currentUserId)
        
        querySnapshot.addSnapshotListener { querySnapshot, error in
            if let error = error {
                self.userPublisher.send(completion: .failure(error))
                return
            }
            guard let document = querySnapshot else { return }
            guard let user = try? document.data(as: User.self) else { return }
            
            print("[DEBUG] UserService:listenToUsersDatabase() currentUser: \(user)\n")
            self.userPublisher.send(user)
        }
    }
}

enum MyError: Error {
    case runtimeError(String)
}
