//
//  UserService.swift
//  GeoStream
//
//  Created by Zirui Wang on 5/1/24.
//

import Foundation
import Firebase

struct UserService {
    let db = Firestore.firestore()
    
    
    
    func addUser(userId: String, email: String) {
//        let user = User(id: userId,
//                        email: email,
//                        userName: "N/A",
//                        description: "N/A",
//                        profileImgUrl: "N/A")
//        db.collection("users").document(id).setData(from: user)
        
//        do {
//            try db.collection("users").document(id).setData(from: user)
//        }
//        catch let error {
//            print("Error writing document: \(error)")
//        }
        
    }
    
    
    func fetchUser(withUid uid: String, completion: @escaping(User) -> Void) {
        db.collection("users").document(uid).getDocument { snapshot, _ in
            guard let snapshot = snapshot else { return }
            var user: User
            do {
                user = try snapshot.data(as: User.self)
            } catch {
                print ("Error fetchUser: \(error)")
                return
            }
            completion(user)
        }
    }
    
    func fetchUsers(completion: @escaping([User]) -> Void) {
        Firestore.firestore().collection("users")
            .getDocuments { snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                let users = documents.compactMap({ try? $0.data(as: User.self)})
                
                completion(users)
            }
    }
}
