//
//  PostService.swift
//  GeoStream
//
//  Created by Zirui Wang on 4/30/24.
//

import Foundation
import Firebase
import GeoFire
import GeoFireUtils
import MapKit
import CoreLocation

struct PostService {
    var addresses = [CLPlacemark]()
    static let shared = PostService()
    let db = Firestore.firestore()

    private init() {
        print("[DEBUG] PostService:init() mockPosts: \(PostService.mockPosts)")
        getAddressAsync(location: PostService.mockPosts.first!.location)
    }
    static let mockPosts: [Post] = [
        Post(id: "2", userId: "abc", timestamp: Date(), likes: 12, content: "this is content", type: "event", location: CLLocationCoordinate2D(latitude: 37.78815531914898, longitude: -122.40754586877463), address: "San Francisco", city: "San Francisco", country: "USA", title: "Downtown SF Party", imageUrl: ["https://encrypted-tbn0.gstatic.com/licensed-image?q=tbn:ANd9GcTStT4ON9fBkjWLpniDZo0-UfkdjpUPgu2YgWd76yWevng-2wvVRgp3RXdBIzhkfxBvPQqfoqBDjXWVPncCoz1NYVXmbF_CbVsJgrAUuQ", "https://lh5.googleusercontent.com/p/AF1QipN0-mJ4M1ftzod1vtrdwMyE2fmmqxGdPxnvQMH4=w1188-h686-n-k-no"], commentId: []),
        Post(id: "1", userId: "cde", timestamp: Date(), likes: 0, content: "peaking", type: "alert", location: CLLocationCoordinate2D(latitude: 37.784951824864464, longitude: -122.40220161414518), address: "San Francisco", city: "San Francisco", country: "USA", title: "Golden Gate Bridge", imageUrl: [], commentId: []),
        Post(id: "3", userId: "def", timestamp: Date(), likes: 0, content: "yes", type: "review", location: CLLocationCoordinate2D(latitude: 37.78930690593879, longitude: -122.39700979660641), address: "San Francisco", city: "San Francisco", country: "USA", title: "Backyard BBQ", imageUrl: [], commentId: []),
        Post(id: "4", userId: "efg", timestamp: Date(), likes: 0, content: "yes", type: "event", location: CLLocationCoordinate2D(latitude: 37.77949484957832, longitude: -122.41768564428206), address: "San Francisco", city: "San Francisco", country: "USA", title: "Office Birthday Bash", imageUrl: [], commentId: []),
        Post(id: "5", userId: "q5m1AGTK84owC1KShCEt", timestamp: Date(), likes: 0, content: "yes", type: "alert", location: CLLocationCoordinate2D(latitude: 37.3323916038548, longitude: -122.00604306620986), address: "San Francisco", city: "San Francisco", country: "USA", title: "Road closed", imageUrl: [], commentId: []),
    ]
    
    
    func addPost(content: String, location: CLLocationCoordinate2D, type: String, completion: @escaping(Bool) -> Void) {
        guard let uid = AuthService.shared.currentUser?.uid else {return}
        let hash = GFUtils.geoHash(forLocation: location)
        let data = ["userId": uid,
                    "timestamp": Timestamp(date: Date()),
                    "likes": 0,
                    "content": content,
                    "location": hash,
                    "type": type
        ] as [String: Any]
        db.collection("posts").document().setData(data) { error in
            if let error = error {
                print("Failed to upload post with error: \(error.localizedDescription)")
                completion(false)
                return
            }
            print("Upload post succesfully")
            completion(true)
        }
    }
    
    func deletePost() {}
    
    func fetchPostByUserId(_ userId: String) {}
    
    func fetchPostsByTime() {}
    
    func addComment() {}
    
    func deleteComment() {}
    
    func fetchComment(_ postId: String) {
        
    }
    

    func getAddress(location: CLLocationCoordinate2D) -> [CLPlacemark] {
        let address = CLGeocoder.init()
        var result = [CLPlacemark]()
        address.reverseGeocodeLocation(CLLocation.init(latitude: location.latitude, longitude: location.longitude)) { (places, error) in
            if let error {
                print("Failed to get address with error: \(error.localizedDescription)")
                return
            }
            result = places ?? []
            print("Address: \(result)")
        }
        return result
    }

    func getAddressAsync(location: CLLocationCoordinate2D) {
        let address = CLGeocoder.init()
        let location = CLLocation.init(latitude: location.latitude, longitude: location.longitude)
        Task {
            do {
                let places = try await address.reverseGeocodeLocation(location)
                print("Address: \(places)")
            } catch {
                print("Failed to get address with error: \(error.localizedDescription)")
                // throw error
            }
        }
    }
}
