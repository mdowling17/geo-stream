//
//  UserService.swift
//  GeoStream
//
//  Created by Zirui Wang on 5/1/24.
//  Created by Matthew Dowling on 5/1/24.
//

import Foundation
import Firebase
import FirebaseStorage

struct UserService {
    static let shared = UserService()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    private init() { }

    func saveProfile(documentId: String, newUser: User, image: UIImage?) async throws {
        do {
            try db.collection(User.collectionName).document(documentId).setData(from: newUser)
            if let image = image {
                try await uploadProfileImage(documentId: documentId, image: image)
            }
        } catch {
            print("[DEBUG ERROR] UserService:saveProfile() error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func fetchProfile(documentId: String) async throws -> User {
        do {
            // fetch from users collection by documentId
            let document = try await db.collection(User.collectionName).document(documentId).getDocument()
            let user = try document.data(as: User.self)
            return user
        } catch {
            print("[DEBUG ERROR] UserService:fetchProfile() error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func uploadProfileImage(documentId: String, image: UIImage) async throws {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        
        let storageRef = storage.reference().child("\(documentId).jpg")
        
        do {
            try await storageRef.putDataAsync(imageData)
        } catch {
            print("[DEBUG ERROR] UserService:uploadProfileImage() error: \(error.localizedDescription)")
            throw error
        }
        
    }
    
    
    func fetchProfileImage(documentId: String) async throws -> UIImage? {
        do {
            let storageRef = storage.reference().child("\(documentId).jpg")
            let data = try await storageRef.data(maxSize: 10 * 1024 * 1024)
            guard let image = UIImage(data: data) else { return nil }
            return image
        } catch {
            print("[DEBUG ERROR] UserService:fetchProfileImage() error: \(error.localizedDescription)")
            throw error
        }
    }

}
