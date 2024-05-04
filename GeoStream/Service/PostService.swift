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
    static let shared = PostService()
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
    
    func deletePost(_ postId: String) async {
        do {
            try await db.collection("posts").document(postId).delete()
        } catch {
            print("Error removing post: \(error)")
        }
    }
    
    func fetchPostsByUserId(_ userId: String) async -> [Post] {
        var posts = [Post]()
        do {
            let querySnapshot = try await db.collection("posts").whereField("userId", isEqualTo: userId).getDocuments()
            for document in querySnapshot.documents {
                posts.append( try document.data(as: Post.self) )
            }
        } catch {
            print("Error fetching posts by UserId: \(error)")
        }
        return posts
    }
    
    func fetchPostsByTime() {}
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
    func likePost(_ postId: String) {
        guard let curUserId = AuthService.shared.currentUser?.uid else {return}
        do {
            try await db.collection("users").document(curUserId).updateData(["favPost": FieldValue.arrayUnion([postId])])
        } catch {
            print("Error like a post in firebase: \(error)")
        }
    }
    
    func unlikePost(_ postId: String) {
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
}
