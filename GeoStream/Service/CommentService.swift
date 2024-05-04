//
//  CommentService.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/4/24.
//

import Foundation
import FirebaseFirestore

struct CommentService {
    static let shared = CommentService()
    let db = Firestore.firestore()

    private init() {
        print("[DEBUG] PostService:init() mockPosts: \(PostService.mockPosts)")
    }
    
    func fetchComments(_ postId: String) async throws -> [Comment] {
        do {
            let querySnapshot = try await db.collection(Comment.collectionName).whereField("postId", isEqualTo: postId).getDocuments()
            let comments = querySnapshot.documents.compactMap { queryDocumentSnapshot -> Comment? in
                return try? queryDocumentSnapshot.data(as: Comment.self)
            }
            return comments
        } catch {
            print("[DEBUG ERROR] CommentService:fetchCommentsByPostId() error: \(error.localizedDescription)")
            throw error
        }
    }
    
    static let mockComments = [
        Comment(id: "1", postId: "1", content: "This is a comment", timestamp: Date(), userId: "1"),
        Comment(id: "2", postId: "1", content: "This is another comment", timestamp: Date(), userId: "2"),
        Comment(id: "3", postId: "1", content: "This is a third comment", timestamp: Date(), userId: "3")
    ]

}
