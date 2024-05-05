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
import FirebaseCore
import FirebaseFirestore
import Combine

enum UserServiceError: Error {
    case UserNotSignedInError
    case CouldNotCompressImageError
}

struct UserService {
    static let shared = UserService()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    var userPublisher = PassthroughSubject<[User], Error>()

    private init() { }

    func saveProfile(displayName: String, description: String, image: UIImage?) async throws {
        guard let currentUser = AuthService.shared.currentUser else {
            throw UserServiceError.UserNotSignedInError
        }
        guard let documentId = currentUser.id else {
            throw UserServiceError.UserNotSignedInError
        }
        let email = currentUser.email ?? ""
        do {
            var photoURL: String? = nil
            if let image = image {
                photoURL = try await uploadProfileImage(documentId: documentId, image: image)
            }
            let newUser = User(id: documentId, email: email, displayName: displayName, description: description, photoURL: photoURL, followerIds: [], followingIds: [], likedPostIds: [])
            try db.collection(User.collectionName).document(documentId).setData(from: newUser)
            
        } catch {
            print("[DEBUG ERROR] UserService:saveProfile() error: \(error.localizedDescription)\n")
            throw error
        }
    }
    
    func fetchProfile(userId documentId: String) async throws -> User {
        do {
            let document = try await db.collection(User.collectionName).document(documentId).getDocument()
            let user = try document.data(as: User.self)
            return user
        } catch {
            print("[DEBUG ERROR] UserService:fetchProfile() error: \(error.localizedDescription)\n")
            throw error
        }
    }
    
    func uploadProfileImage(documentId: String, image: UIImage) async throws -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { throw UserServiceError.CouldNotCompressImageError }
        
        let storageRef = storage.reference().child("\(documentId)/profile_pic.jpg")
        
        do {
            let result = try await storageRef.putDataAsync(imageData)
            print("[DEBUG] uploadProfileImage() result: \(result)\n")
            let urlString = try await storageRef.downloadURL()
            print("[DEBUG] uploadProfileImage() urlString: \(urlString)\n")
            return urlString.absoluteString
        } catch {
            print("[DEBUG ERROR] UserService:uploadProfileImage() error: \(error.localizedDescription)\n")
            throw error
        }
    }
    
    
    // TODO: possibly remove
    func fetchProfileImage(documentId: String) async throws -> UIImage? {
        do {
            let storageRef = storage.reference().child("\(documentId)/profile_pic.jpg")
            let data = try await storageRef.data(maxSize: 10 * 1024 * 1024)
            guard let image = UIImage(data: data) else { return nil }
            return image
        } catch {
            print("[DEBUG ERROR] UserService:fetchProfileImage() error: \(error.localizedDescription)\n")
            throw error
        }
    }
    
    func listenToUsersDatabase() {
        guard let currentUserId = AuthService.shared.currentUser?.id else { return }
        
        let querySnapshot =  db.collection(User.collectionName)
        
        querySnapshot.addSnapshotListener { querySnapshot, error in
            if let error = error {
                self.userPublisher.send(completion: .failure(error))
                return
            }
            guard let querySnapshot = querySnapshot else { return }
            let users = querySnapshot.documents.compactMap { queryDocumentSnapshot -> User? in
                return try? queryDocumentSnapshot.data(as: User.self)
            }
            print("[DEBUG] UserService:listenToUsersDatabase() users: \(users)\n")
            self.userPublisher.send(users)
        }
    }
    
    func likePost(userId: String, postId: String) async throws {
        do {
            try await db.collection(User.collectionName).document(userId).updateData(["likedPostIds": FieldValue.arrayUnion([postId])])
            print("[DEBUG] UserService:likePost() liked post \(postId)\n")
        } catch {
            print("[DEBUG ERROR] UserService:likePost() error: \(error.localizedDescription)\n")
            throw error
        }
    }
    
    func unlikePost(userId: String, postId: String) async throws {
        do {
            try await db.collection(User.collectionName).document(userId).updateData(["likedPostIds": FieldValue.arrayRemove([postId])])
            print("[DEBUG] UserService:unlikePost() unliked post \(postId)\n")
        } catch {
            print("[DEBUG ERROR] UserService:unlikePost() error: \(error.localizedDescription)\n")
            throw error
        }
    }
}

extension UserService {
    func followUser(_ otherUser: String) async {
        // curUserId follows otherUser
        guard let curUserId = AuthService.shared.currentUser?.id else {return}
        do {
            try await db.collection("users").document(curUserId).updateData(["followingIds": FieldValue.arrayUnion([otherUser])])
            try await db.collection("users").document(otherUser).updateData(["followerIds": FieldValue.arrayUnion([curUserId])])
        } catch {
            print("Error following a user: \(error)\n")
        }
    }
    
    func unfollowUser(_ otherUser: String) async {
        // curUserId unfollows otherUser
        guard let curUserId = AuthService.shared.currentUser?.id else {return}
        do {
            try await db.collection("users").document(curUserId).updateData(["followingIds": FieldValue.arrayRemove([otherUser])])
            try await db.collection("users").document(otherUser).updateData(["followerIds": FieldValue.arrayRemove([curUserId])])
        } catch {
            print("Error unfollowing a user: \(error)\n")
        }
    }
}
