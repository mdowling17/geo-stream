//
//  CreatePostViewModel.swift
//  GeoStream
//
//  Created by Zirui Wang on 4/30/24.
//

import Foundation
import SwiftUI

@MainActor
class CreatePostViewModel: ObservableObject {
    @Published var image: UIImage?
    @Published var photoURL: String?
    @Published var isConfirmationDialogPresented: Bool = false
    @Published var isImagePickerPresented: Bool = false
    @Published var sourceType: SourceType = .camera

    @Published var user: User?
    @Published var lat: Double = -122.407546
    @Published var lon: Double = 37.788155
    @Published var content: String = ""
    @Published var title: String = ""
    @Published var type: String = "All"
    let locationManager = LocationManager()
    
    init() {
        fetchUser()
        getCoords()
    }
    
    func fetchUser() {
        Task {
            do {
                guard let userId = AuthService.shared.currentUser?.uid else { return }
                let fetchedUser = try await UserService.shared.fetchProfile(documentId: userId)
                user = fetchedUser
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func uploadPhoto() {
        Task {
            do {
                if let image = image {
                    let url = await PostService.shared.uploadPhoto(documentId: user?.id ?? UUID().uuidString, image: image)
                    photoURL = url
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func getCoords() {
        locationManager.requestLocation()
        if let location = locationManager.location {
            lat = location.latitude
            lon = location.longitude
        }
    }
    
    func createPost() {
        locationManager.requestLocation()
        Task {
            do {
                if let location = locationManager.location {
                    try await PostService.shared.addPost(content: content, location: location, type: type, title: title, imageUrl: photoURL ?? "")
                    uploadPhoto()
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
}
