//
//  ProfileViewModel.swift
//  GeoStream
//
//  Created by Zirui Wang on 5/3/24.
//

import Foundation
import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var image: UIImage?
    @Published var displayName: String = ""
    @Published var description: String = ""
    @Published var email: String = ""
    @Published var signOutMessage: String? = nil
    
    init() {
        fetchProfile()
    }
    
    func fetchProfile() {
        guard let currentUser = AuthService.shared.currentUser else { return }
        let documentId = currentUser.uid
        Task {
            do {
                let user = try await UserService.shared.fetchProfile(documentId: documentId)
                displayName = user.displayName ?? ""
                description = user.description ?? ""
                email = user.email
                image = try await UserService.shared.fetchProfileImage(documentId: documentId)
            } catch {
                print("[DEBUG ERROR] ProfileEditViewModel:init() Error: \(error.localizedDescription)")
            }
        }
    }
    
    func signOut() {
        do {
            try AuthService.shared.signOut()
        } catch {
            print("[DEBUG ERROR] ProfileEditViewModel:signOut() Error: \(error.localizedDescription)")
            signOutMessage = error.localizedDescription
        }
    }
    
}
