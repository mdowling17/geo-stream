//
//  PostRowViewModel.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/4/24.
//

import Foundation

@MainActor
class PostRowViewModel: ObservableObject {
    @Published var showComment = false
    @Published var post: Post
    @Published var user: User?
    @Published var comments = [Comment]()
    @Published var age: Int
    
    init(post: Post, user: User?, age: Int) {
        self.post = post
        self.user = user
        self.age = age
        fetchComments()
    }
    
    func toggleShowComment() {
        showComment.toggle()
    }
    
    func fetchComments() {
        Task {
            do {
                guard let postId = post.id else { return }
                let fetchedComments = try await CommentService.shared.fetchComments(postId)
                comments = fetchedComments
                print("[DEBUG] PostRowViewModel:fetchComments() comments: \(comments)")
            } catch {
                print("[DEBUG ERROR] PostRowViewModel:fetchComments() Error: \(error.localizedDescription)")
            }
        }
    }
}
