//
//  CreatePostViewModel.swift
//  GeoStream
//
//  Created by Zirui Wang on 4/30/24.
//

import Foundation

class CreatePostViewModel: ObservableObject {
    @Published var didUploadPost = false
    let service = PostService()
    let locationManager = LocationManager()
    
    func createPost(content: String, type: String) {
        locationManager.requestLocation()
        if let location = locationManager.location {
            service.addPost(content: content, location: location, type: type) { success in
                if success {
                    self.didUploadPost = true
                } else {
                    //show error
                }
            }
        }
    }
}
