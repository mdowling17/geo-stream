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
}
