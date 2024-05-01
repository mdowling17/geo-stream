//
//  PostService.swift
//  GeoStream
//
//  Created by Zirui Wang on 4/30/24.
//

import Foundation
import Firebase

struct PostService {
    let db = Firestore.firestore()
    
    func addPost(content: String, latitude: Double, longitude: Double, type: String, completion: @escaping(Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let data = ["userId": uid,
                    "timestamp": Timestamp(date: Date()),
                    "likes": 0,
                    "content": content,
                    "latitude": latitude,
                    "longitude": longitude,
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
    
    func fetchPost() {}
    
    func fetchPostsByTime() {}
    
    func deletePost() {}
}
