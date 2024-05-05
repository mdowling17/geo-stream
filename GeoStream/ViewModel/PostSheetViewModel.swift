//
//  PostRowViewModel.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/4/24.
//

import Foundation

@MainActor
class PostSheetViewModel: ObservableObject {
    @Published var showComment = false
    @Published var post: Post
    @Published var user: User?
    @Published var comments = [Comment]()
    @Published var isLiked: Bool?
    
    init(post: Post, user: User?) {
        self.post = post
        self.user = user
        fetchComments()
        isPostLiked()
    }
    
    func toggleShowComment() {
        showComment.toggle()
    }
    
    func fetchComments() {
        Task {
            do {
                guard let postId = post.id else { return }
                let fetchedComments = await PostService.shared.fetchComments(postId)
                comments = fetchedComments
                //print("[DEBUG] PostRowViewModel:fetchComments() comments: \(comments)")
            } catch {
                print("[DEBUG ERROR] PostRowViewModel:fetchComments() Error: \(error.localizedDescription)")
            }
        }
    }
    
    func isPostLiked() {
        if let user = user, let id = post.id {
            if user.likedPostIds.contains(id) {
                isLiked = true
            } else {
                isLiked = false
            }
        } else { return }
    }
    
    func deletePost() {
        Task {
            if let id = post.id {
                await PostService.shared.deletePost(id)
            }
        }
    }
    
    func unlikePost() {
        isLiked?.toggle()
        if let user = user, let id = post.id {
            if let index = user.likedPostIds.firstIndex(of: id) {
                self.user?.likedPostIds.remove(at: index)
            }
            Task {
                try await PostService.shared.unlikePost(postId: id)
            }
        }
    }
    
    func likePost() {
        isLiked?.toggle()
        if let user = user, let id = post.id {
            self.user?.likedPostIds.append(id)
            Task {
                try await PostService.shared.likePost(postId: id)
            }
        }
    }
}
