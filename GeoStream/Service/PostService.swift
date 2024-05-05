//
//  PostService.swift
//  GeoStream
//
//  Created by Zirui Wang on 4/30/24.
//

import Foundation
import Firebase
import MapKit
import CoreLocation
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore
import Combine

enum PostServiceError: Error {
    case CouldNotCompressImageError
}


struct PostService {
    var addresses = [CLPlacemark]()
    static let shared = PostService()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    var postPublisher = PassthroughSubject<[Post], Error>()
    
    private init() { }
    func addPost(post: Post, postId: String) throws {
        do {
            let _ = try db.collection(Post.collectionName).document(postId).setData(from: post)
            print("[DEBUG] PostService:addPost() postId: \(postId)\n")
        } catch {
            print("[DEBUG ERROR] PostService:addPost() error: \(error.localizedDescription)\n")
            throw error
        }
    }
    
    func deletePost(_ postId: String) async {
        do {
            try await db.collection("posts").document(postId).delete()
        } catch {
            print("Error removing post: \(error)\n")
        }
    }
    
    func fetchPostsByUserId(_ userId: String) async throws -> [Post] {
        var posts = [Post]()
        do {
            let querySnapshot = try await db.collection("posts").whereField("userId", isEqualTo: userId).getDocuments()
            for document in querySnapshot.documents {
                do{ let doc = try document.data(as: Post.self)}
                catch{
                   print("hererer \(error)")
                }
                posts.append( try document.data(as: Post.self) )
            }
        } catch {
            print("[DEBUG ERROR] PostService:fetchPostsByUserId() error: \(error.localizedDescription)\n")
            throw error
        }
        return posts
    }
    
    func fetchPostsByPostIds(_ postIds: [String]) async -> [Post] {
        if postIds.isEmpty {return []}
        // up to 30 posts
        var posts = [Post]()
        do {
            let querySnapshot = try await db.collection("posts").whereField(FieldPath.documentID(), in: postIds).getDocuments()
            for document in querySnapshot.documents {
                print("hererer \(document)")
                posts.append( try document.data(as: Post.self) )
            }
        } catch {
            print("Error fetching liked posts: \(error)")
        }
        return posts
    }
    
    func fetchPostsByTime() {}
    
    func uploadPhoto(userId: String, image: UIImage, postId: String) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { throw PostServiceError.CouldNotCompressImageError }
        let storageRef = storage.reference().child("\(userId)/\(postId).jpg")
        
        do {
            let result = try await storageRef.putDataAsync(imageData)
            print("[DEBUG] PostService:uploadPhoto() result: \(result)\n")
            let urlString = try await storageRef.downloadURL()
            print("[DEBUG] PostService:uploadPhoto() urlString: \(urlString)\n")
            return urlString.absoluteString
        } catch {
            print("[DEBUG ERROR] PostService:uploadPhoto() error: \(error.localizedDescription)\n")
            throw error
        }
    }

}

extension PostService {
    func addComment(postId: String, commentId: String) async throws {
        do {
            try await db.collection(Post.collectionName).document(postId).updateData(["commentIds": FieldValue.arrayUnion([commentId])])
        }
        catch {
            print("Error adding comment: \(error)")
        }
    }
    
    func deleteComment(postId: String, commentId: String) async {
        do {
            try await db.collection(Post.collectionName).document(postId).updateData(["commentIds": FieldValue.arrayRemove([commentId])])
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
            print("Error fetching comments: \(error)")
        }
        return comments
    }
}

extension PostService {
    func likePost(postId: String) async throws {
        do {
            try await db.collection(Post.collectionName).document(postId).updateData(["likes": FieldValue.increment(Int64(1))])
        } catch {
            print("[DEBUG ERROR] PostService:likePost() error: \(error.localizedDescription)\n")
            throw error
        }
    }
    
    func unlikePost(postId: String) async throws {
        do {
            try await db.collection(Post.collectionName).document(postId).updateData(["likes": FieldValue.increment(Int64(-1))])
        } catch {
            print("Error unlike a post in firebase: \(error)\n")
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
            print("Error fetching liked posts: \(error)\n")
        }
        return posts
    }
    
    func checkIsUserLikedPost(_ postId: String, completion: @escaping(Bool) -> Void) {
        guard let curUserId = AuthService.shared.currentUser?.id else {return}
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
                print("Failed to get address with error: \(error.localizedDescription)\n")
                return
            }
            result = places ?? []
            print("Address: \(result)\n")
        }
        return result
    }

    func getAddressAsync(location: CLLocationCoordinate2D) {
        let address = CLGeocoder.init()
        let location = CLLocation.init(latitude: location.latitude, longitude: location.longitude)
        Task {
            do {
                let places = try await address.reverseGeocodeLocation(location)
                print("Address: \(places)\n")
            } catch {
                print("Failed to get address with error: \(error.localizedDescription)\n")
                // throw error
            }
        }
    }
    
    func listenToPostsDatabase() {
        guard let currentUserId = AuthService.shared.currentUser?.id else { return }
        
        let querySnapshot =  db.collection(Post.collectionName).order(by: "timestamp", descending: false)
        
        querySnapshot.addSnapshotListener { querySnapshot, error in
            if let error = error {
                self.postPublisher.send(completion: .failure(error))
                return
            }
            guard let querySnapshot = querySnapshot else { return }
            let posts = querySnapshot.documents.compactMap { queryDocumentSnapshot -> Post? in
                return try? queryDocumentSnapshot.data(as: Post.self)
            }
            print("[DEBUG] PostService:listenToPostsDatabase() posts: \(posts)\n")
            self.postPublisher.send(posts)
        }
    }
}

extension PostService {
    static let mockPosts: [Post] = [
        Post(id: "2", userId: "YnThFX1rbvTvTSJVuEmD1dxN43w2", timestamp: Date(), likes: 12, content: "this is content", type: "Event", location: CLLocationCoordinate2D(latitude: 37.78815531914898, longitude: -122.40754586877463), address: "San Francisco", city: "San Francisco", country: "USA", title: "Downtown SF Party", imageUrl: ["https://encrypted-tbn0.gstatic.com/licensed-image?q=tbn:ANd9GcTStT4ON9fBkjWLpniDZo0-UfkdjpUPgu2YgWd76yWevng-2wvVRgp3RXdBIzhkfxBvPQqfoqBDjXWVPncCoz1NYVXmbF_CbVsJgrAUuQ", "https://lh5.googleusercontent.com/p/AF1QipN0-mJ4M1ftzod1vtrdwMyE2fmmqxGdPxnvQMH4=w1188-h686-n-k-no"], commentIds: []),
        Post(id: "1", userId: "1", timestamp: Date(), likes: 0, content: "peaking", type: "alert", location: CLLocationCoordinate2D(latitude: 37.784951824864464, longitude: -122.40220161414518), address: "San Francisco", city: "San Francisco", country: "USA", title: "Golden Gate Bridge", imageUrl: [], commentIds: []),
        Post(id: "3", userId: "1", timestamp: Date(), likes: 0, content: "yes", type: "review", location: CLLocationCoordinate2D(latitude: 37.78930690593879, longitude: -122.39700979660641), address: "San Francisco", city: "San Francisco", country: "USA", title: "Backyard BBQ", imageUrl: [], commentIds: []),
        Post(id: "4", userId: "1", timestamp: Date(), likes: 0, content: "yes", type: "event", location: CLLocationCoordinate2D(latitude: 37.77949484957832, longitude: -122.41768564428206), address: "San Francisco", city: "San Francisco", country: "USA", title: "Office Birthday Bash", imageUrl: [], commentIds: []),
        Post(id: "5", userId: "1", timestamp: Date(), likes: 0, content: "yes", type: "alert", location: CLLocationCoordinate2D(latitude: 37.3323916038548, longitude: -122.00604306620986), address: "San Francisco", city: "San Francisco", country: "USA", title: "Road closed", imageUrl: [], commentIds: []),
    ]
}
