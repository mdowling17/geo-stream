//
//  UserService.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/1/24.
//

import Foundation
import Firebase
import FirebaseStorage

enum UserServiceError: Error {
    case UserNotSignedInError
    case CouldNotCompressImageError
}

struct UserService {
    static let shared = UserService()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    private init() { }

    func saveProfile(displayName: String, description: String, image: UIImage?) async throws {
        guard let currentUser = AuthService.shared.currentUser else {
            throw UserServiceError.UserNotSignedInError
        }
        let documentId = currentUser.uid
        let email = currentUser.email ?? ""
        do {
            var photoURL: String? = nil
            if let image = image {
                photoURL = try await uploadProfileImage(documentId: documentId, image: image)
            }
            let newUser = User(id: documentId, email: email, displayName: displayName, description: description, photoURL: photoURL, friends: [])
            try db.collection(User.collectionName).document(documentId).setData(from: newUser)
            
        } catch {
            print("[DEBUG ERROR] UserService:saveProfile() error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func fetchProfile(documentId: String) async throws -> User {
        do {
            let document = try await db.collection(User.collectionName).document(documentId).getDocument()
            let user = try document.data(as: User.self)
            return user
        } catch {
            print("[DEBUG ERROR] UserService:fetchProfile() error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func uploadProfileImage(documentId: String, image: UIImage) async throws -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { throw UserServiceError.CouldNotCompressImageError }
        
        let storageRef = storage.reference().child("\(documentId)/profile_pic.jpg")
        
        do {
            let result = try await storageRef.putDataAsync(imageData)
            print("[DEBUG] uploadProfileImage() result: \(result)")
            let urlString = try await storageRef.downloadURL()
            print("[DEBUG] uploadProfileImage() urlString: \(urlString)")
            return urlString.absoluteString
        } catch {
            print("[DEBUG ERROR] UserService:uploadProfileImage() error: \(error.localizedDescription)")
            throw error
        }
        
    }
    
    
    func fetchProfileImage(documentId: String) async throws -> UIImage? {
        do {
            let storageRef = storage.reference().child("\(documentId)/profile_pic.jpg")
            let data = try await storageRef.data(maxSize: 10 * 1024 * 1024)
            guard let image = UIImage(data: data) else { return nil }
            return image
        } catch {
            print("[DEBUG ERROR] UserService:fetchProfileImage() error: \(error.localizedDescription)")
            throw error
        }
    }

}
