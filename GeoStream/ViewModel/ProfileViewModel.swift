//
//  ProfileViewModel.swift
//  GeoStream
//
//  Created by Zirui Wang on 5/3/24.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    // data
    @Published var selectedPost: Post?
    @Published var commentContent: String = ""
    
    //toggles
    @Published var showComments = false
    
    // subscriptions
    var subscribers: Set<AnyCancellable> = []
    @Published var comments = [Comment]()
    @Published var posts = [Post]()
    @Published var users = [User]()
    @Published var postDetailUser: User?
    @Published var currentUser: User?

    init() {
        CommentService.shared.listenToCommentsDatabase()
        subToCommentPublisher()
        PostService.shared.listenToPostsDatabase()
        subToPostPublisher()
        UserService.shared.listenToUsersDatabase()
        subToUserPublisher()
        AuthService.shared.listenToUsersDatabase()
        subToAuthPublisher()
    }
        
    func signOut() {
        do {
            try AuthService.shared.signOut()
        } catch {
            print("[DEBUG ERROR] ProfileEditViewModel:signOut() Error: \(error.localizedDescription)\n")
        }
    }
    
    func toggleShowComments() {
        showComments.toggle()
    }
    
    func toggleLikePost(postId: String?) {
        Task {
            do {
                guard let postId = postId else {
                    print("[DEBUG ERROR] ProfileViewModel:toggleLikePost() Error: postId is nil\n")
                    return
                }
                guard let userId = AuthService.shared.currentUser?.id else {
                    print("[DEBUG ERROR] ProfileViewModel:toggleLikePost() Error: userId is nil\n")
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
                print("[DEBUG ERROR] ProfileViewModel:toggleLikePost() Error: \(error.localizedDescription)\n")
            }
        }
    }
    
    func addComment(postId: String?) {
        Task {
            do {
                guard let postId = postId else {
                    print("[DEBUG ERROR] MapViewModel:addComment() Error: postId is nil\n")
                    return
                }
                guard let userId = AuthService.shared.currentUser?.id else {
                    print("[DEBUG ERROR] MapViewModel:addComment() Error: userId is nil\n")
                    return
                }
                let comment = Comment(
                    postId: postId,
                    content: commentContent,
                    timestamp: Date(),
                    posterId: userId
                )
                try await CommentService.shared.addComment(comment: comment, postId: postId)
            } catch {
                print("[DEBUG ERROR] MapViewModel:addComment() Error: \(error.localizedDescription)\n")
            }
        }
    }
    
    
    
    private func subToCommentPublisher() {
        print("[DEBUG] MapViewModel:subToCommentPublisher() started\n")
        CommentService.shared.commentPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    print("[DEBUG] MapViewModel:subToCommentPublisher() finished\n")
                case .failure(let error):
                    print("[DEBUG ERROR] MapViewModel:subToCommentPublisher() error: \(error.localizedDescription)\n")
                }
            } receiveValue: { [weak self] comments in
                print("[DEBUG] MapViewModel:subToCommentPublisher() receiveValue() comments: \(comments)\n")
                self?.comments = comments
            }
            .store(in: &subscribers)
    }
    
    private func subToPostPublisher() {
        print("[DEBUG] MapViewModel:subToPostPublisher() started\n")
        PostService.shared.postPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    print("[DEBUG] MapViewModel:subToPostPublisher() finished\n")
                case .failure(let error):
                    print("[DEBUG ERROR] MapViewModel:subToPostPublisher() error: \(error.localizedDescription)\n")
                }
            } receiveValue: { [weak self] posts in
                print("[DEBUG] MapViewModel:subToPostPublisher() receiveValue() posts: \(posts)\n")
                self?.posts = posts
            }
            .store(in: &subscribers)
    }
    
    private func subToUserPublisher() {
        print("[DEBUG] MapViewModel:subToUserPublisher() started\n")
        UserService.shared.userPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    print("[DEBUG] MapViewModel:subToUserPublisher() finished\n")
                case .failure(let error):
                    print("[DEBUG ERROR] MapViewModel:subToUserPublisher() error: \(error.localizedDescription)\n")
                }
            } receiveValue: { [weak self] users in
                print("[DEBUG] MapViewModel:subToUserPublisher() receiveValue() users: \(users)\n")
                self?.users = users
            }
            .store(in: &subscribers)
    }
    
    private func subToAuthPublisher() {
        print("[DEBUG] MapViewModel:subToAuthPublisher() started\n")
        AuthService.shared.userPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    print("[DEBUG] MapViewModel:subToAuthPublisher() finished\n")
                case .failure(let error):
                    print("[DEBUG ERROR] MapViewModel:subToAuthPublisher() error: \(error.localizedDescription)\n")
                }
            } receiveValue: { [weak self] currentUser in
                print("[DEBUG] MapViewModel:subToAuthPublisher() receiveValue() currentUser: \(currentUser)\n")
                self?.currentUser = currentUser
            }
            .store(in: &subscribers)
    }

    
}
