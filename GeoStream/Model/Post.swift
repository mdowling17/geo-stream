//
//  Post.swift
//  GeoStream
//
//  Created by Zirui Wang on 4/26/24.
//

import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore
import CoreLocation

struct Post: Identifiable, Hashable {
    @DocumentID var id: String?
    let userId: String
    let timestamp: Date
    var likes: Int
    let content: String
    let type: String
    let location: CLLocationCoordinate2D
    let imageUrl: [String]
    let commentId: [String]
    
    enum CodingKeys: String, CodingKey {
        case id,
             userId,
             timestamp,
             likes,
             content,
             type,
             location,
             imageUrl,
             commentId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(userId)
    }
    
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id && lhs.userId == rhs.userId
    }
}

extension Post: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(likes, forKey: .likes)
        try container.encode(content, forKey: .content)
        try container.encode(type, forKey: .type)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(commentId, forKey: .commentId)
        // Convert CLLocationCoordinate2D to GeoPoint and encode it
        let geoPoint = GeoPoint(latitude: location.latitude, longitude: location.longitude)
        try container.encode(geoPoint, forKey: .location)
    }
}

extension Post: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(DocumentID<String>.self, forKey: .id).wrappedValue
        
        userId = try container.decode(String.self, forKey: .userId)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        likes = try container.decode(Int.self, forKey: .likes)
        content = try container.decode(String.self, forKey: .content)
        type = try container.decode(String.self, forKey: .type)
        imageUrl = try container.decode([String].self, forKey: .imageUrl)
        commentId = try container.decode([String].self, forKey: .commentId)
        // Decode GeoPoint and convert it to CLLocationCoordinate2D
        let geoPoint = try container.decode(GeoPoint.self, forKey: .location)
        location = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
    }
}
