//
//  PostViewModel.swift
//  GeoStream
//
//  Created by Zirui Wang on 5/1/24.
//

import Foundation
import SwiftUI

class PostViewModel: ObservableObject {
    @Published var user: User?
    @Published var comments: [Comment] = []
    @Published var userImg: UIImage?
    
    func fetchUser(_ userId: String) async {
        do {
            self.user = try await UserService.shared.fetchProfile(userId: userId)
        } catch {
            print("Error fetching user: \(error)\n")
        }
    }
    
    func fetchUserImg(_ userId: String) async {
        do {
            self.userImg = try await UserService.shared.fetchProfileImage(documentId: userId)
        } catch {
            print("Error fetching user image: \(error)\n")
        }
    }

    func fetchComments() {}
    
    func fetchPostImages() {}
}
