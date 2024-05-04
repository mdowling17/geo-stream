//
//  ProfileEditViewModel.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/1/24.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseStorage

@MainActor
class ProfileEditViewModel: ObservableObject {
    @Published var image: UIImage?
    @Published var photoURL: String?
    @Published var isConfirmationDialogPresented: Bool = false
    @Published var isImagePickerPresented: Bool = false
    @Published var sourceType: SourceType = .camera
    @Published var displayName: String = ""
    @Published var description: String = ""
    @Published var saveProfileMessage: String? = nil
    @Published var saveProfileMessageColor: Color = .app
    @Published var signOutMessage: String? = nil
    @Published var signOutMessageColor: Color = .app

    init() {
        fetchProfile()
    }
    
    func saveProfile() {
        Task {
            do {
                try await UserService.shared.saveProfile(displayName: displayName, description: description, image: image)
                saveProfileMessage = "Profile saved successfully"
                saveProfileMessageColor = .app
            } catch {
                print("[DEBUG ERROR] ProfileEditViewModel:saveProfile() Error: \(error.localizedDescription)")
                saveProfileMessage = error.localizedDescription
                saveProfileMessageColor = .red
            }
        }
    }
    
    func fetchProfile() {
        guard let currentUser = AuthService.shared.currentUser else { return }
        let documentId = currentUser.uid
        
        Task {
            do {
                let user = try await UserService.shared.fetchProfile(documentId: documentId)
                displayName = user.displayName ?? ""
                description = user.description ?? ""
                //TODO: make sure this works
//                image = try await UserService.shared.fetchProfileImage(documentId: documentId)
                photoURL = user.photoURL
            } catch {
                print("[DEBUG ERROR] ProfileEditViewModel:init() Error: \(error.localizedDescription)")
                saveProfileMessage = error.localizedDescription
                saveProfileMessageColor = .red
            }
        }
    }
    
    func signOut() {
        do {
            try AuthService.shared.signOut()
        } catch {
            print("[DEBUG ERROR] ProfileEditViewModel:signOut() Error: \(error.localizedDescription)")
            signOutMessage = error.localizedDescription
            signOutMessageColor = .red
        }
    }
}

enum SourceType {
    case camera
    case photoLibrary
}
