//
//  MessageService.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/2/24.
//

import Foundation
import FirebaseFirestore
import Combine

enum MessageServiceError: Error {
    case UserNotSignedInError
}

struct MessageService {
    static let shared = MessageService()
    let db = Firestore.firestore()
    var messagePublisher = PassthroughSubject<[Message], Error>()

    private init() { }
    
    func fetchChatMessages() async throws -> [Message] {
        do {
            guard let currentUserId = AuthService.shared.currentUser?.id else { throw MessageServiceError.UserNotSignedInError }
            
            let querySnapshot =  db.collection(Message.collectionName).order(by: "createdAt", descending: false).whereFilter(Filter.orFilter([
                Filter.whereField("fromUserId", isEqualTo: currentUserId), Filter.whereField("toUserId", isEqualTo: currentUserId)
            ]))
            let messages = try await querySnapshot.getDocuments()
                .documents
                .compactMap { try? $0.data(as: Message.self) }
            return messages
        } catch {
            print("[DEBUG ERROR] MessageService:fetchChatMessages() error: \(error.localizedDescription)\n")
            throw error
        }
    }
    
    //TODO: fix this data
    func sendChatMessage(toUserId: String?, text: String, photoURL: String?) async throws {
        guard let currentUser = AuthService.shared.currentUser else { throw MessageServiceError.UserNotSignedInError }
        let fromUserId = currentUser.id
        let photoURL = photoURL
        let createdAt = Date()
        let data = [
            "toUserId": toUserId ?? "",
            "fromUserId": fromUserId,
            "toPostId": "",
            "text": text,
            "photoURL": photoURL ?? "",
            "createdAt": createdAt
        ] as [String: Any]
        do {
            
            let result = try await db.collection(Message.collectionName).addDocument(data: data)
            print("[DEBUG] MessageService:sendChatMessage() result: \(result)\n")
        } catch {
            print("[DEBUG ERROR] MessageService:sendChatMessage() error: \(error.localizedDescription)\n")
            throw error
        }
    }
    
    func listenToMessagesDatabase() {
        guard let currentUserId = AuthService.shared.currentUser?.id else { return }
        
        let querySnapshot =  db.collection(Message.collectionName).order(by: "createdAt", descending: false).whereFilter(Filter.orFilter([
            Filter.whereField("fromUserId", isEqualTo: currentUserId), Filter.whereField("toUserId", isEqualTo: currentUserId)
        ]))
        
        querySnapshot.addSnapshotListener { querySnapshot, error in
            if let error = error {
                self.messagePublisher.send(completion: .failure(error))
                return
            }
            guard let querySnapshot = querySnapshot else { return }
            let messages = querySnapshot.documents.compactMap { queryDocumentSnapshot -> Message? in
                return try? queryDocumentSnapshot.data(as: Message.self)
            }
            print("[DEBUG] MessageService:listenToMessagesDatabase() messages: \(messages)\n")
            self.messagePublisher.send(messages)
        }
    }
}
