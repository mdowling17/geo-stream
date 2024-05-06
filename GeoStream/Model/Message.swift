//
//  Message.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/2/24.
//

import Foundation
import FirebaseFirestore

enum MessageError: Error {
    case CannotCreatePhotoURLError
}

struct Message: Decodable, Identifiable, Encodable, Equatable, Hashable {
    @DocumentID var id: String?
    let toUserId: String?
    let fromUserId: String
    let text: String
    let createdAt: Date
}

extension Message {
    static let collectionName = "messages"
}
