//
//  User.swift
//  GeoStream
//
//  Created by Zirui Wang on 4/29/24.
//

import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    let email: String
    let displayName: String?
    let description: String?
}

extension User {
    static let collectionName = "users"
}
