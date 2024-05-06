//
//  CreatePostViewModel.swift
//  GeoStream
//
//  Created by Zirui Wang on 4/30/24.
//

import Foundation
import SwiftUI
import MapKit

@MainActor
class CreatePostViewModel: ObservableObject {
    @Published var image: UIImage?
    @Published var photoURL: String?
    @Published var isConfirmationDialogPresented: Bool = false
    @Published var isImagePickerPresented: Bool = false
    @Published var sourceType: SourceType = .camera

    @Published var user: User?
    @Published var lat: Double = -122.407546 //initialize to san francisco, this will be overwritten
    @Published var lon: Double = 37.788155
    @Published var content: String = ""
    @Published var title: String = ""
    @Published var type: String = "Event"
    
    @Published var newPost: Post?
    
    init() {
        fetchUser()
        setCoordinatesOnCurrentLocation()
    }
    
    func fetchUser() {
        Task {
            do {
                guard let userId = AuthService.shared.currentUser?.id else { return }
                let fetchedUser = try await UserService.shared.fetchProfile(userId: userId)
                user = fetchedUser
            } catch {
                print("[DEBUG ERROR] CreatePostViewModel:fetchUser() Error: \(error.localizedDescription)\n")
            }
        }
    }
    
    func uploadPhoto(userId: String, postId: String) async throws -> String {
        do {
            guard let image = image else { return "" }
            let url = try await PostService.shared.uploadPhoto(userId: userId, image: image, postId: postId)
            print("[DEBUG] CreatePostViewModel:uploadPhoto() URL: \(url)\n")
            return url
        } catch {
            print("[DEBUG ERROR] CreatePostViewModel:uploadPhoto() Error: \(error.localizedDescription)\n")
            return ""
        }
    }
    
    func setCoordinatesOnCurrentLocation() {
        if let userLocation = LocationService.shared.userLocation {
            lat = userLocation.coordinate.latitude
            lon = userLocation.coordinate.longitude
        }
    }
    
    func createPost() {
        Task {
            do {
                guard let userId = AuthService.shared.currentUser?.id else { return }
                let postId = UUID().uuidString
                let photoURL = try await uploadPhoto(userId: userId, postId: UUID().uuidString)
                let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                let addresses = try await PostService.shared.getAddressAsync(location: coordinates)
                let city = addresses.first?.locality ?? ""
                let state = addresses.first?.administrativeArea ?? ""
                let country = addresses.first?.isoCountryCode ?? ""
                print("[DEBUG] CreatePostViewModel:createPost() addresses: \(addresses)\n")
                let newPost = Post(
                    id: postId,
                    userId: userId,
                    timestamp: Date(),
                    likes: 0,
                    content: content,
                    type: type,
                    location: CLLocationCoordinate2D(
                        latitude: lat,
                        longitude: lon
                    ),
                    city: city,
                    state: state,
                    country: country,
                    imageUrl: [photoURL],
                    commentIds: []
                )
                try PostService.shared.addPost(post: newPost, postId: postId)
                self.newPost = newPost
            } catch {
                print("[DEBUG ERROR] CreatePostViewModel:createPost() Error: \(error.localizedDescription)\n")
            }
        }
    }
}
