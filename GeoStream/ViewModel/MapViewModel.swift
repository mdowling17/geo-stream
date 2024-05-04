//
//  MapViewModel.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/3/24.
//

import Foundation
import MapKit
import SwiftUI

struct Address: Codable {
    let data: [Datum]
 }

struct Datum: Codable {
   let latitude, longitude: Double
   let name: String?
}



@MainActor
class MapViewModel: ObservableObject {
    private let POSITION_STACK_URL = "http://api.positionstack.com/v1/forward"
    private let POSITION_STACK_API_KEY = "92d0989cebd26dea67f59db3a280d7a6"

    // All loaded locations
    @Published var posts: [Post]
    @Published var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @Published var searchQuery: String = ""
    // Current location on map
    @Published var selectedPost: Post? {
        didSet {
            showCreatePostButton = selectedPost == nil
            updateMapRegion(post: selectedPost)
        }
    }
    @Published var nearestPosts = [Post]()
    
    // Current region on map
    @Published var mapRegion: MKCoordinateRegion = MKCoordinateRegion()
    let mapSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    
    // Show list of locations
    @Published var showPostList: Bool = false
    @Published var showSearchButton: Bool = true
    @Published var showSearchSettings: Bool = false
    @Published var showCreatePost: Bool = false
    @Published var showCreatePostButton: Bool = true

    // Show location detail via sheet
    @Published var openedPost: Post? = nil
    
    //SettingsView Settings
    @Published var distanceSettingEnabled: Bool = true
    @Published var distanceSetting: Int = 25
    @Published var timeframeSettingEnabled: Bool = true
    @Published var timeframeSetting: Int = 24
    
    init() {
        print("PostService.shared.addresses: \(PostService.shared.addresses)")
        let posts = PostService.mockPosts
        self.posts = posts
                
        // TODO: set this to the user's location
//        self.updateMapRegion(post: posts.first!)
    }
    
    private func updateMapRegion(post: Post?) {
        guard let post = post else { return }
        withAnimation(.easeInOut) {
            let newMapRegion = MKCoordinateRegion(
                center: post.location,
                span: mapSpan)
            mapRegion = newMapRegion
            cameraPosition = MapCameraPosition.region(newMapRegion)
        }
    }
        
    func togglePostList() {
        withAnimation(.easeInOut) {
            showPostList.toggle()
        }
    }
    
    func toggleSearchSettings() {
        withAnimation(.easeInOut) {
            showSearchSettings.toggle()
        }
    }
    
    func hitSearchButton() {
        if showSearchButton == false {
            withAnimation(.easeInOut) {
                searchQuery = ""
                nearestPosts = []
                showPostList = false
                showSearchButton = true
            }
        } else {
            searchLocation()
        }
    }
    
    func showNextLocation(post: Post?) {
        withAnimation(.easeInOut) {
            selectedPost = post
            showPostList = false
        }
    }
    
    func nextButtonPressed() {
        // Get the current index
        guard let currentIndex = nearestPosts.firstIndex(where: { $0 == selectedPost }) else {
            print("Could not find current index in locations array! Should never happen.")
            return
        }
        
        // Check if the currentIndex is valid
        let nextIndex = currentIndex + 1
        guard nearestPosts.indices.contains(nextIndex) else {
            // Next index is NOT valid
            // Restart from 0
            guard let firstLocation = nearestPosts.first else { return }
            showNextLocation(post: firstLocation)
            return
        }
        
        // Next index IS valid
        let nextLocation = nearestPosts[nextIndex]
        showNextLocation(post: nextLocation)
    }
    
    func searchLocation() {
        if searchQuery.isEmpty { return }
        // take the search query and make an API call to Position Stack
        // use the resultant coordinates to update the cameraLocation, selectedPost, and nearbyPosts
        let urlEncodedAddress = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        
        guard let url = URL(string: "\(POSITION_STACK_URL)?access_key=\(POSITION_STACK_API_KEY)&query=\(urlEncodedAddress)") else {
            print("Invalid URL")
            return
        }
        
        print("Searching for location: \(url)")
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print(error!.localizedDescription)
                return }
            
            guard let newCoordinates = try? JSONDecoder().decode(Address.self, from: data) else {
                    print("Could not decode data...")
                    return
                }
            
            if newCoordinates.data.isEmpty {
                print("Could not find address...")
                return
            }
            
            // Set the new data
            DispatchQueue.main.async {
                print("inside")
                let details = newCoordinates.data[0]
                let lat = details.latitude
                let lon = details.longitude
                let newLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                withAnimation(.easeInOut) {
                    let newMapRegion = MKCoordinateRegion(
                        center: newLocation,
                        span: self.mapSpan)
                    self.mapRegion = newMapRegion
                    self.cameraPosition = MapCameraPosition.region(newMapRegion)
                    
                    print("Successfully loaded location! \(details.name ?? "")")
                }
                let targetPosts = self.posts
                
                let filteredPosts = self.filterPosts(targetPosts: targetPosts, newCoordinates: newLocation)
                self.nearestPosts = filteredPosts
                
                if filteredPosts.count > 0 {
                    withAnimation(.easeInOut) {
                        self.showPostList = true
                        self.showSearchButton = false
                    }
                }

            }
        }
        .resume()
    }
    
    func filterPosts(targetPosts: [Post], newCoordinates: CLLocationCoordinate2D) -> [Post] {
        var filteredPosts = [Post]()
        if timeframeSettingEnabled && distanceSettingEnabled {
            filteredPosts = filterPostsByTimeframe(targetPosts: targetPosts)
            filteredPosts = filterPostsByLocation(targetPosts: filteredPosts, newCoordinates: newCoordinates)
        } else if timeframeSettingEnabled {
            filteredPosts = filterPostsByTimeframe(targetPosts: targetPosts)
        } else if distanceSettingEnabled {
            filteredPosts = filterPostsByLocation(targetPosts: targetPosts, newCoordinates: newCoordinates)
        }
        return filteredPosts
    }
    
    func filterPostsByLocation(targetPosts: [Post], newCoordinates: CLLocationCoordinate2D) -> [Post] {
        let newMapPoint = MKMapPoint(newCoordinates)
        print("New Map Point Lat: \(newMapPoint.coordinate.latitude), Lon: \(newMapPoint.coordinate.longitude)")
        // Get the posts that are within 10 miles of the current location
        let nearbyPosts = posts.filter { post in
            print("A point Lat: \(post.location.latitude), Lon: \(post.location.longitude)")

            let postMapPoint = MKMapPoint(post.location)
            let distance = newMapPoint.distance(to: postMapPoint)
            print("Distance: \(distance)")
            return Int(distance) <= distanceSetting * 1609 // 1609 meters per mile
        }.sorted { post1, post2 in
            let post1MapPoint = MKMapPoint(post1.location)
            let post2MapPoint = MKMapPoint(post2.location)
            let distance1 = newMapPoint.distance(to: post1MapPoint)
            let distance2 = newMapPoint.distance(to: post2MapPoint)
            return distance1 < distance2
        }
        return nearbyPosts
    }
    
    func filterPostsByTimeframe(targetPosts: [Post]) -> [Post] {
        let recentPosts = targetPosts.filter { post in
            let diffs = Calendar.current.dateComponents([.hour, .minute], from: post.timestamp, to: Date())
            let post_hours_ago = diffs.hour ?? 0
            return post_hours_ago <= timeframeSetting
        }
        
        return recentPosts
    }
}
