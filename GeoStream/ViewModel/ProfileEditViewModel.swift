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
import Combine

@MainActor
class ProfileEditViewModel: ObservableObject {
    
    // data
    @Published var image: UIImage?
    @Published var sourceType: SourceType = .camera
    @Published var displayName: String = ""
    @Published var description: String = ""
    @Published var saveProfileMessage: String? = nil
    @Published var saveProfileMessageColor: Color = .app
    @Published var signOutMessage: String? = nil
    @Published var signOutMessageColor: Color = .app

    // toggles
    @Published var isConfirmationDialogPresented: Bool = false
    @Published var isImagePickerPresented: Bool = false
    
    // subscriptions
    var subscribers: Set<AnyCancellable> = []
    @Published var currentUser: User?

    init() {
        AuthService.shared.listenToUsersDatabase()
        subToAuthPublisher()
    }
    
    func saveProfile() {
        Task {
            do {
                let photoURL = currentUser?.photoURL
                try await UserService.shared.saveProfile(displayName: displayName, description: description, image: image, photoURL: photoURL)
                saveProfileMessage = "Profile saved successfully"
                saveProfileMessageColor = .app
            } catch {
                print("[DEBUG ERROR] ProfileEditViewModel:saveProfile() Error: \(error.localizedDescription)\n")
                saveProfileMessage = error.localizedDescription
                saveProfileMessageColor = .red
            }
        }
    }
        
    func signOut() {
        do {
            try AuthService.shared.signOut()
        } catch {
            print("[DEBUG ERROR] ProfileEditViewModel:signOut() Error: \(error.localizedDescription)\n")
            signOutMessage = error.localizedDescription
            signOutMessageColor = .red
        }
    }
    
    private func subToAuthPublisher() {
        print("[DEBUG] ProfileEditViewModel:subToAuthPublisher() started\n")
        AuthService.shared.userPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    print("[DEBUG] ProfileEditViewModel:subToAuthPublisher() finished\n")
                case .failure(let error):
                    print("[DEBUG ERROR] ProfileEditViewModel:subToAuthPublisher() error: \(error.localizedDescription)\n")
                }
            } receiveValue: { [weak self] currentUser in
                print("[DEBUG] ProfileEditViewModel:subToAuthPublisher() receiveValue() currentUser: \(currentUser)\n")
                self?.currentUser = currentUser
                self?.displayName = currentUser.displayName ?? ""
                self?.description = currentUser.description ?? ""
            }
            .store(in: &subscribers)
    }
}

enum SourceType {
    case camera
    case photoLibrary
}
