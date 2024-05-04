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
    @Published var messages: [Message] = []
    @Published var text = ""
    @Published var errorMessage = ""
    @Published var toUserId = ""
    @Published var photoURL: String?
    @Published var friends: [User] = []
    @Published var showIndividualChat = false
    var subscribers: Set<AnyCancellable> = []
    
    init () {
        MessageService.shared.listenToMessagesDatabase()
        subToMessagePublisher()
        fetchUserDetails()
    }
    
    func sendChatMessage(text: String) {
        Task {
            do {
                print("[DEBUG] ChatViewModel:sendChatMessage() text: \(text) toUserId: \(toUserId)")
                try await MessageService.shared.sendChatMessage(toUserId: toUserId, text: text, photoURL: photoURL)
            } catch {
                print("[DEBUG ERROR] ChatViewModel:sendChatMessage() error: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func fetchChatMessages() {
        Task {
            do {
                messages = try await MessageService.shared.fetchChatMessages()
            } catch {
                print("[DEBUG ERROR] ChatViewModel:fetchChatMessages() error: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func subToMessagePublisher() {
        print("[DEBUG] ChatViewModel:subToMessagePublisher() started")
        MessageService.shared.messagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    print("[DEBUG] ChatViewModel:subToMessagePublisher() finished")
                case .failure(let error):
                    print("[DEBUG ERROR] ChatViewModel:subToMessagePublisher() error: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] messages in
                print("[DEBUG] ChatViewModel:subToMessagePublisher() receiveValue() messages: \(messages)")
                self?.messages = messages
            }
            .store(in: &subscribers)
    }
    
    func fetchUserDetails() {
        guard let currentUser = AuthService.shared.currentUser else { return }
        let documentId = currentUser.uid
        
        Task {
            do {
                let user = try await UserService.shared.fetchProfile(documentId: documentId)
                photoURL = user.photoURL
                print("[DEBUG] ChatViewModel:fetchUserDetails() user: \(user.photoURL ?? "")")
                friends = user.friends
                //TODO: get rid of this hardcoded friend
                friends.append(User(id: "1", email: "test2@gmail.com", displayName: "testuser1", description: "first tester", photoURL: "https://upload.wikimedia.org/wikipedia/en/thumb/5/5f/Original_Doge_meme.jpg/220px-Original_Doge_meme.jpg", friends: []))
                print("[DEBUG] ChatViewModel:fetchUserDetails() friends: \(friends)")
            } catch {
                print("[DEBUG ERROR] ProfileEditViewModel:init() Error: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
            }
        }
    }
}
