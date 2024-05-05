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

}
