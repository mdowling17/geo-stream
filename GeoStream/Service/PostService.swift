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
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore


struct PostService {
    var addresses = [CLPlacemark]()
    static let shared = PostService()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    private init() {
        print("[DEBUG] PostService:init() mockPosts: \(PostService.mockPosts)")
        getAddressAsync(location: PostService.mockPosts.first!.location)
    }
    static let mockPosts: [Post] = [
        Post(id: "2", userId: "1", timestamp: Date(), likes: 12, content: "this is content", type: "event", location: CLLocationCoordinate2D(latitude: 37.78815531914898, longitude: -122.40754586877463), address: "San Francisco", city: "San Francisco", country: "USA", title: "Downtown SF Party", imageUrl: ["https://encrypted-tbn0.gstatic.com/licensed-image?q=tbn:ANd9GcTStT4ON9fBkjWLpniDZo0-UfkdjpUPgu2YgWd76yWevng-2wvVRgp3RXdBIzhkfxBvPQqfoqBDjXWVPncCoz1NYVXmbF_CbVsJgrAUuQ", "https://lh5.googleusercontent.com/p/AF1QipN0-mJ4M1ftzod1vtrdwMyE2fmmqxGdPxnvQMH4=w1188-h686-n-k-no"], commentIds: []),
        Post(id: "1", userId: "1", timestamp: Date(), likes: 0, content: "peaking", type: "alert", location: CLLocationCoordinate2D(latitude: 37.784951824864464, longitude: -122.40220161414518), address: "San Francisco", city: "San Francisco", country: "USA", title: "Golden Gate Bridge", imageUrl: [], commentIds: []),
        Post(id: "3", userId: "1", timestamp: Date(), likes: 0, content: "yes", type: "review", location: CLLocationCoordinate2D(latitude: 37.78930690593879, longitude: -122.39700979660641), address: "San Francisco", city: "San Francisco", country: "USA", title: "Backyard BBQ", imageUrl: [], commentIds: []),
        Post(id: "4", userId: "1", timestamp: Date(), likes: 0, content: "yes", type: "event", location: CLLocationCoordinate2D(latitude: 37.77949484957832, longitude: -122.41768564428206), address: "San Francisco", city: "San Francisco", country: "USA", title: "Office Birthday Bash", imageUrl: [], commentIds: []),
        Post(id: "5", userId: "1", timestamp: Date(), likes: 0, content: "yes", type: "alert", location: CLLocationCoordinate2D(latitude: 37.3323916038548, longitude: -122.00604306620986), address: "San Francisco", city: "San Francisco", country: "USA", title: "Road closed", imageUrl: [], commentIds: []),
    ]
    
    
    func addPost(content: String, location: CLLocationCoordinate2D, type: String, title: String, imageUrl: String) async throws {
//        @DocumentID var id: String?
//        let userId: String
//        let timestamp: Date
//        var likes: Int
//        let content: String
//        let type: String
//        let location: CLLocationCoordinate2D
//        let address: String
//        let city: String
//        let country: String
//        let title: String
//        let imageUrl: [String]
//        let commentIds: [String]
        guard let uid = AuthService.shared.currentUser?.uid else {return}
        let hash = GFUtils.geoHash(forLocation: location)

        let data = [
            "timestamp": Timestamp(date: Date()),
            "likes": 0,
            "content": content,
            "type": type,
            "location": hash,
            "address": "",
            "city": "",
            "title": title,
            "imageUrl": imageUrl,
            "commentIds": []
        ] as [String: Any]
        do {
            let result = try await db.collection(Post.collectionName).addDocument(data: data)
            print("[DEBUG] PostService:addPost() result: \(result)")
        } catch {
            print("[DEBUG ERROR] PostService:addPost() error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func deletePost(_ postId: String) async {
        do {
            try await db.collection("posts").document(postId).delete()
        } catch {
            print("Error removing post: \(error)")
        }
    }
    
    func fetchPostsByUserId(_ userId: String) async throws -> [Post] {
        var posts = [Post]()
        do {
            let querySnapshot = try await db.collection("posts").whereField("userId", isEqualTo: userId).getDocuments()
            for document in querySnapshot.documents {
                posts.append( try document.data(as: Post.self) )
            }
        } catch {
            print("[DEBUG ERROR] PostService:fetchPostsByUserId() error: \(error.localizedDescription)")
            throw error
        }
        return posts
    }
    
    func fetchPostsByTime() {}
    
    func uploadPhoto(documentId: String, image: UIImage) async -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return nil }
        
        let storageRef = storage.reference().child("\(documentId)/new_image.jpg")
        
        do {
            let result = try await storageRef.putDataAsync(imageData)
            print("[DEBUG] uploadProfileImage() result: \(result)")
            let urlString = try await storageRef.downloadURL()
            print("[DEBUG] uploadProfileImage() urlString: \(urlString)")
            return urlString.absoluteString
        } catch {
            print("[DEBUG ERROR] UserService:uploadProfileImage() error: \(error.localizedDescription)")
            return nil
        }
    }

}

extension PostService {
    func addComment(_ comment: Comment) {
        do {
            try db.collection("comments").document().setData(from: comment)
        }
        catch {
            print("Error adding comment: \(error)")
        }
    }
    
    func deleteComment(_ commentId: String) async {
        do {
          try await db.collection("comments").document(commentId).delete()
        } catch {
          print("Error deleting comment: \(error)")
        }
    }
    
    func fetchComments(_ postId: String) async -> [Comment] {
        var comments = [Comment]()
        do {
          let querySnapshot = try await db.collection("comments").whereField("postId", isEqualTo: postId).getDocuments()
          for document in querySnapshot.documents {
              comments.append( try document.data(as: Comment.self) )
          }
        } catch {
            print("Error fetching documents: \(error)")
        }
        return comments
    }
}

extension PostService {
    func likePost(_ postId: String) async throws {
        guard let curUserId = AuthService.shared.currentUser?.uid else {return}
        do {
            try await db.collection("users").document(curUserId).updateData(["favPost": FieldValue.arrayUnion([postId])])
        } catch {
            print("Error like a post in firebase: \(error)")
        }
    }
    
    func unlikePost(_ postId: String) async throws {
        guard let curUserId = AuthService.shared.currentUser?.uid else {return}
        do {
            try await db.collection("users").document(curUserId).updateData(["favPost": FieldValue.arrayRemove([postId])])
        } catch {
            print("Error unlike a post in firebase: \(error)")
        }
    }
    
    
    func fetchPostsIfLiked(_ postIds: [String]) async -> [Post] {
        // up to 30 posts
        var posts = [Post]()
        do {
            let querySnapshot = try await db.collection("posts").whereField(FieldPath.documentID(), in: postIds).getDocuments()
            for document in querySnapshot.documents {
                posts.append( try document.data(as: Post.self) )
            }
        } catch {
            print("Error fetching liked posts: \(error)")
        }
        return posts
    }
    
    func checkIsUserLikedPost(_ postId: String, completion: @escaping(Bool) -> Void) {
        guard let curUserId = AuthService.shared.currentUser?.uid else {return}
        db.collection("users").document(curUserId).getDocument { snapshot, _ in
            guard let snapshot = snapshot else { return }
            completion(snapshot.exists)
        }
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
