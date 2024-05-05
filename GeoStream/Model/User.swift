//
//  User.swift
//  GeoStream
//
//  Created by Zirui Wang on 4/29/24.
//

import Foundation
import Firebase
import FirebaseFirestore

struct User: Identifiable, Codable, Hashable, Equatable {
    @DocumentID var id: String? //UserId
    let email: String
    let displayName: String?
    let description: String?
    let photoURL: String?
    let followerIds: [String] //UserId
    let followingIds: [String] //UserId
    let likedPostIds: [String] //PostId
    
    func getPhotoURL() -> URL? {
        guard let photoURL = photoURL else {
            return nil
        }
        print("[DEBUG INFO] User:\(displayName ?? ""):getPhotoURL() photoURL: \(photoURL)\n")
        return URL(string: photoURL)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(email)
    }
}

extension User {
    static let collectionName = "users"
}
