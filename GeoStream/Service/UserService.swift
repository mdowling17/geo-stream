//
//  UserService.swift
//  GeoStream
//
//  Created by Zirui Wang on 4/29/24.
//

import Firebase

struct UserService {
    let db = Firestore.firestore()
    
    func addUser(id: String, email: String) {
        let user = User(id: id, email: email, userName: "", description: "", profileImgUrl: "")
        do {
            try db.collection("users").document(id).setData(from: user)
        }
        catch let error {
            print("Error addUser: \(error.localizedDescription)")
        }
    }
    
    func fetchUser(id: String, completion: @escaping(User) -> Void) {
        db.collection("users").document(id).getDocument { document, error in
            guard let document = document else { return }
            var user: User
            do {
                user = try document.data(as: User.self)
            } catch {
                print ("Error fetchUser: \(error.localizedDescription)")
                return
            }
            completion(user)
        }
    }
    
    func fetchUsers() {}
    
    func updateUserName(id: String, userName: String) async {
        do {
            try await db.collection("users").document(id).updateData([
                "userName": userName,
            ])
        } catch {
            print("Error updating document: \(error)")
        }
    }
    
    func updateUserNumber(id: String, description: String) async {
        do {
            try await db.collection("users").document(id).updateData([
                "description": description,
            ])
        } catch {
            print("Error updating document: \(error)")
        }
        
    }
    
    func updateUserPic(id: String, imgURL: String) async {
        do {
            try await db.collection("users").document(id).updateData([
                "profileImgUrl": imgURL,
            ])
        } catch {
            print("Error updating document: \(error)")
        }
    }
}
