//
//  PostDetailViewModel.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/5/24.
//

import Foundation
import SwiftUI

class PostDetailViewModel: ObservableObject {
    @Published var showUserDetail: Bool = false
    
    func toggleLikePost(postId: String?) {
        Task {
            do {
                guard let postId = postId else {
                    print("[DEBUG ERROR] PostDetailViewModel:toggleLikePost() Error: postId is nil\n")
                    return
                }
                guard let userId = AuthService.shared.currentUser?.id else {
                    print("[DEBUG ERROR] PostDetailViewModel:toggleLikePost() Error: userId is nil\n")
                    return
                }
                let user = try await UserService.shared.fetchProfile(userId: userId)
                let isLiked = user.likedPostIds.contains(postId)
                if isLiked {
                    try await UserService.shared.unlikePost(userId: userId, postId: postId)
                    try await PostService.shared.unlikePost(postId: postId)
                } else {
                    try await UserService.shared.likePost(userId: userId, postId: postId)
                    try await PostService.shared.likePost(postId: postId)
                }
            } catch {
                print("[DEBUG ERROR] PostDetailViewModel:toggleLikePost() Error: \(error.localizedDescription)\n")
            }
        }
    }
}
