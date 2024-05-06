//
//  CommentService.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/4/24.
//

import Foundation
import FirebaseFirestore
import Combine

struct CommentService {
    static let shared = CommentService()
    let db = Firestore.firestore()
    var commentPublisher = PassthroughSubject<[Comment], Error>()

    private init() { }
    
    func addComment(comment: Comment, postId: String) async throws {
        do {
            let commentId = UUID().uuidString
            try db.collection(Comment.collectionName).document(commentId).setData(from: comment)
            print("[DEBUG] CommentService:addComment() commentId: \(commentId)\n")
            try await PostService.shared.addComment(postId: postId, commentId: commentId)
        } catch {
            print("[DEBUG ERROR] CommentService:addComment() error: \(error.localizedDescription)\n")
            throw error
        }
    }
    
    func listenToCommentsDatabase() {
        let querySnapshot =  db.collection(Comment.collectionName).order(by: "timestamp", descending: false)
        
        querySnapshot.addSnapshotListener { querySnapshot, error in
            if let error = error {
                self.commentPublisher.send(completion: .failure(error))
                return
            }
            guard let querySnapshot = querySnapshot else { return }
            let comments = querySnapshot.documents.compactMap { queryDocumentSnapshot -> Comment? in
                return try? queryDocumentSnapshot.data(as: Comment.self)
            }
            print("[DEBUG] CommentService:listenToCommentsDatabase() comments: \(comments)\n")
            self.commentPublisher.send(comments)
        }
    }

}
