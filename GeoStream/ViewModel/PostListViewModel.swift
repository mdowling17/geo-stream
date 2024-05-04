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
    @Published var user: User?
    
    init() {
        fetchPostDetails()
        fetchUser()
    }
    
    func fetchPostDetails() {
        Task {
            do {
                guard let userId = AuthService.shared.currentUser?.uid else { return }
                let fetchedPosts = try await PostService.shared.fetchPostsByUserId(userId)
                posts = fetchedPosts
            } catch {
                print("[DEBUG ERROR] PostListViewModel:fetchPosts() Error: \(error.localizedDescription)")
            }
            
        }
    }
    
    func fetchUser() {
        Task {
            guard let userId = AuthService.shared.currentUser?.uid else { return }
            let fetchedUser = try await UserService.shared.fetchProfile(documentId: userId)
            user = fetchedUser
        }
    }
}
