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
    
    func saveProfile(userId: String, email: String) async throws {
        do {
            var newUser = User(
                id: userId,
                email: email,
                displayName: "",
                description: "",
                photoURL: "",
                followerIds: [],
                followingIds: [],
                likedPostIds: []
            )
            try db.collection(User.collectionName).document(userId).setData(from: newUser)
        } catch {
            print("[DEBUG ERROR] UserService:saveProfile() error: \(error.localizedDescription)\n")
            throw error
        }
    }
    
    func saveProfile(displayName: String, description: String, image: UIImage?, photoURL: String?) async throws {
        guard let currentUser = AuthService.shared.currentUser else {
            throw UserServiceError.UserNotSignedInError
        }
        guard let documentId = currentUser.id else {
            throw UserServiceError.UserNotSignedInError
        }
        var givenPhotoURL = photoURL
        let email = currentUser.email
        let followerIds = currentUser.followerIds
        let followingIds = currentUser.followingIds
        let likedPostIds = currentUser.likedPostIds
        do {
            if givenPhotoURL == nil || givenPhotoURL == "", let image = image {
                givenPhotoURL = try await uploadProfileImage(documentId: documentId, image: image)
            }
            var newUser = User(id: documentId, email: email, displayName: displayName, description: description, photoURL: givenPhotoURL ?? "", followerIds: followerIds, followingIds: followingIds, likedPostIds: likedPostIds)
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
    
    func listenToUsersDatabase() {
        let querySnapshot =  db.collection(User.collectionName).order(by: "displayName")
        
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
    
    func addFriend(userId: String) async throws {
        do {
            guard let currentUserId = AuthService.shared.currentUser?.id else { return }
            try await db.collection(User.collectionName).document(userId).updateData(["followerIds": FieldValue.arrayUnion([currentUserId])])
            try await db.collection(User.collectionName).document(currentUserId).updateData(["followingIds": FieldValue.arrayUnion([userId])])
            print("[DEBUG] UserService:addFriend() added friend \(userId)\n")
        } catch {
            print("[DEBUG ERROR] UserService:addFriend() error: \(error.localizedDescription)\n")
            throw error
        }
    }
    
    func removeFriend(userId: String) async throws {
        do {
            guard let currentUserId = AuthService.shared.currentUser?.id else { return }
            try await db.collection(User.collectionName).document(userId).updateData(["followerIds": FieldValue.arrayRemove([currentUserId])])
            try await db.collection(User.collectionName).document(currentUserId).updateData(["followingIds": FieldValue.arrayRemove([userId])])
            print("[DEBUG] UserService:removeFriend() removed friend \(userId)\n")
        } catch {
            print("[DEBUG ERROR] UserService:removeFriend() error: \(error.localizedDescription)\n")
            throw error
        }
    }
}
