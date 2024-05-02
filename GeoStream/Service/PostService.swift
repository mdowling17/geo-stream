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

struct PostService {
    let db = Firestore.firestore()
    
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
}
