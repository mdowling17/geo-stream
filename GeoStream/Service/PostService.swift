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


struct PostService {
    var addresses = [CLPlacemark]()
    static let shared = PostService()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    func addPost(content: String, location: CLLocationCoordinate2D, type: String, title: String, imageUrl: String) async throws {
        guard let uid = AuthService.shared.currentUser?.uid else {return}
        let data = Post(userId: uid, 
                        timestamp: Date(),
                        likes: 0,
                        content: content,
                        type: type,
                        location: location,
                        address: "",
                        city: "",
                        country: "",
                        title: title,
                        imageUrl: [],
                        commentIds: [])
        do {
            let result = try await db.collection(Post.collectionName).document().setData(from: data)
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
                do{ let doc = try document.data(as: Post.self)}
                catch{
                   print("hererer \(error)")
                }
                posts.append( try document.data(as: Post.self) )
            }
        } catch {
            print("[DEBUG ERROR] PostService:fetchPostsByUserId() error: \(error.localizedDescription)")
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
            print("Error fetching comments: \(error)")
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
