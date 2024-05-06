//
//  ChatViewModel.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/2/24.
//

import Foundation
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    // subscriptions
    var subscribers: Set<AnyCancellable> = []
    @Published var messages = [Message]()
    @Published var posts = [Post]()
    @Published var users = [User]()
    @Published var currentUser: User?
    
    // data
    @Published var searchQuery: String = ""
    
    // toggles
    @Published var showOnlyFollowing: Bool = false
    @Published var text = ""
    @Published var errorMessage = ""
    @Published var toUserId = ""
    
    init () {
        MessageService.shared.listenToMessagesDatabase()
        subToMessagePublisher()
        PostService.shared.listenToPostsDatabase()
        subToPostPublisher()
        UserService.shared.listenToUsersDatabase()
        subToUserPublisher()
        AuthService.shared.listenToUsersDatabase()
        subToAuthPublisher()
    }
    
    func sendChatMessage(text: String) {
        Task {
            do {
                print("[DEBUG] ChatViewModel:sendChatMessage() text: \(text) toUserId: \(toUserId)\n")
                let photoURL = currentUser?.photoURL ?? ""
                try await MessageService.shared.sendChatMessage(toUserId: toUserId, text: text, photoURL: photoURL)
            } catch {
                print("[DEBUG ERROR] ChatViewModel:sendChatMessage() error: \(error.localizedDescription)\n")
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func subToMessagePublisher() {
        print("[DEBUG] ChatViewModel:subToMessagePublisher() started\n")
        MessageService.shared.messagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    print("[DEBUG] ChatViewModel:subToMessagePublisher() finished\n")
                case .failure(let error):
                    print("[DEBUG ERROR] ChatViewModel:subToMessagePublisher() error: \(error.localizedDescription)\n")
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] messages in
                print("[DEBUG] ChatViewModel:subToMessagePublisher() receiveValue() messages: \(messages)\n")
                self?.messages = messages
            }
            .store(in: &subscribers)
    }
    
    private func subToPostPublisher() {
        print("[DEBUG] ChatViewModel:subToPostPublisher() started\n")
        PostService.shared.postPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    print("[DEBUG] ChatViewModel:subToPostPublisher() finished\n")
                case .failure(let error):
                    print("[DEBUG ERROR] ChatViewModel:subToPostPublisher() error: \(error.localizedDescription)\n")
                }
            } receiveValue: { [weak self] posts in
                print("[DEBUG] ChatViewModel:subToPostPublisher() receiveValue() posts: \(posts)\n")
                self?.posts = posts
            }
            .store(in: &subscribers)
    }
    
    private func subToUserPublisher() {
        print("[DEBUG] ChatViewModel:subToUserPublisher() started\n")
        UserService.shared.userPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    print("[DEBUG] ChatViewModel:subToUserPublisher() finished\n")
                case .failure(let error):
                    print("[DEBUG ERROR] ChatViewModel:subToUserPublisher() error: \(error.localizedDescription)\n")
                }
            } receiveValue: { [weak self] users in
                print("[DEBUG] ChatViewModel:subToUserPublisher() receiveValue() users: \(users)\n")
                self?.users = users
            }
            .store(in: &subscribers)
    }
    
    private func subToAuthPublisher() {
        print("[DEBUG] ChatViewModel:subToAuthPublisher() started\n")
        AuthService.shared.userPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    print("[DEBUG] ChatViewModel:subToAuthPublisher() finished\n")
                case .failure(let error):
                    print("[DEBUG ERROR] ChatViewModel:subToAuthPublisher() error: \(error.localizedDescription)\n")
                }
            } receiveValue: { [weak self] currentUser in
                print("[DEBUG] MapViewModel:subToAuthPublisher() receiveValue() currentUser: \(currentUser)\n")
                self?.currentUser = currentUser
            }
            .store(in: &subscribers)
    }
    
    func addFriend(userId: String) {
        Task {
            do {
                try await UserService.shared.addFriend(userId: userId)
            } catch {
                print("[DEBUG ERROR] ChatViewModel:addFriend() error: \(error.localizedDescription)\n")
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func removeFriend(userId: String) {
        Task {
            do {
                try await UserService.shared.removeFriend(userId: userId)
            } catch {
                print("[DEBUG ERROR] ChatViewModel:removeFriend() error: \(error.localizedDescription)\n")
                errorMessage = error.localizedDescription
            }
        }
    }

}
