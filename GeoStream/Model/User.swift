//
//  User.swift
//  GeoStream
//
//  Created by Zirui Wang on 4/29/24.
//

import Foundation
import Firebase
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String? //UserId
    let email: String
    let displayName: String?
    let description: String?
    let photoURL: String?
    let followers: [String] //UserId
    let following: [String] //UserId
    let favPost: [String] //PostId
    
    func getPhotoURL() -> URL? {
        guard let photoURL = photoURL else {
            return nil
        }
        print("[DEBUG INFO] User:\(displayName ?? ""):getPhotoURL() photoURL: \(photoURL)")
        return URL(string: photoURL)
    }
}

extension User {
    static let collectionName = "users"
}
