//
//  PostListViewModel.swift
//  GeoStream
//
//  Created by Zirui Wang on 5/3/24.
//

import Foundation
import SwiftUI

@MainActor
class PostListViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var user: User = User(email: "", displayName: "", description: "", photoURL: "", followers: [], following: [], favPost: [])
    let userId = AuthService.shared.currentUser!.uid
    
    func fetchPosts() {
        Task {
            let fetchedPosts = await PostService.shared.fetchPostsByUserId(userId)
            self.posts = fetchedPosts
        }
    }
    
    func fetchUser() {
        Task {
            let fetchedUser = try await UserService.shared.fetchProfile(documentId: userId)
            self.user = fetchedUser
        }
    }
}

@MainActor
class PostRowViewModel: ObservableObject {
    @Published var img: UIImage?
    @Published var comments: [Comment] = []
    
    func fetchUserImg(_ userId: String) {
        Task {
            img = try await UserService.shared.fetchProfileImage(documentId: userId)
        }
    }
    
    func fetchComments(_ postId: String) {
        print(postId)
        Task {
            comments = await PostService.shared.fetchComments(postId)
            print(comments)
        }
    }
}
