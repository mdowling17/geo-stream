//
//  Comment.swift
//  GeoStream
//
//  Created by Zirui Wang on 5/1/24.
//

import Foundation
import Firebase
import FirebaseFirestore

struct Comment: Identifiable, Codable {
    @DocumentID var id: String?
    let postId: String
    let content: String
    let timestamp: Date
    let posterId: String //poster's userId
    let posterName: String
    let posterImg: String
}

extension Comment {
    static let collectionName = "comments"
}
