//
//  PostHistoryViewModel.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/5/24.
//

import Foundation
import SwiftUI

@MainActor
class PostHistoryViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var user: User?
    @Published var showSheet: Bool = false

    init() {
        fetchPostDetails()
        fetchUser()
    }

    func fetchPostDetails() {
        Task {
            do {
                guard let userId = AuthService.shared.currentUser?.id else { return }
                let fetchedPosts = try await PostService.shared.fetchPostsByUserId(userId)
                posts = fetchedPosts
            } catch {
                print("[DEBUG ERROR] PostListViewModel:fetchPosts() Error: \(error.localizedDescription)\n")
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
