//
//  LikedPostsViewModel.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/5/24.
//

import Foundation

@MainActor
class LikedPostsViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var user: User?
    @Published var showSheet: Bool = false
    
    init() {
        fetchUser()
        fetchPostDetails()
        print("FavPostViewModel INIT CALLED")
    }
    
    func fetchPostDetails() {
        Task {
            do {
                let fetchedPosts = try await PostService.shared.fetchPostsByPostIds(user?.likedPostIds ?? [])
                posts = fetchedPosts
                print("fetchPostDetails CALLED \(posts)")
            } catch {
                print("[DEBUG ERROR] PostListViewModel:fetchPosts() Error: \(error.localizedDescription)")
            }
            
        }
    }
    
    func fetchUser() {
        Task {
            guard let userId = AuthService.shared.currentUser?.id else { return }
            let fetchedUser = try await UserService.shared.fetchProfile(userId: userId)
            user = fetchedUser
        }
    }
    
}
