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
    let address: String
    let city: String
    let country: String
    let title: String
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
             commentId,
             address,
             city,
             country,
             title
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(userId)
    }
    
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id && lhs.userId == rhs.userId
    }
    
    func getFirstPhotoURL() -> URL? {
        guard let photoURL = imageUrl.first else {
            return nil
        }
        return URL(string: photoURL)
    }
}

extension Post: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
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
        try container.encode(address, forKey: .address)
        try container.encode(city, forKey: .city)
        try container.encode(country, forKey: .country)
        try container.encode(title, forKey: .title)
    }
}

extension Post: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
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
        address = try container.decode(String.self, forKey: .address)
        city = try container.decode(String.self, forKey: .city)
        country = try container.decode(String.self, forKey: .country)
        title = try container.decode(String.self, forKey: .title)
    }
}
