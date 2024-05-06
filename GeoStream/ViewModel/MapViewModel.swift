//
//  MapViewModel.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/3/24.
//

import Foundation
import MapKit
import SwiftUI
import Combine

struct Address: Codable {
    let data: [Datum]
 }

struct Datum: Codable {
   let latitude, longitude: Double
   let name: String?
}



@MainActor
class MapViewModel: ObservableObject {
    // PositionStack API Config
    private let POSITION_STACK_URL = "http://api.positionstack.com/v1/forward"
    private let POSITION_STACK_API_KEY = "92d0989cebd26dea67f59db3a280d7a6"

    // Map Config
    @Published var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic) {
        didSet {
            print("cameraPosition changed to \(cameraPosition)")
        }
    }
    @Published var mapRegion: MKCoordinateRegion = MKCoordinateRegion()
    let mapSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)

    // Data
    @Published var searchQuery: String = ""
    @Published var selectedPost: Post? {
        didSet {
            showCreatePostButton = selectedPost == nil
        }
    }
    @Published var nearestPosts = [Post]()
    @Published var commentContent: String = ""
        
    // Toggles
    @Published var showPostList: Bool = false
    @Published var showSearchSettings: Bool = false
    @Published var showCreatePost: Bool = false
    @Published var showCreatePostButton: Bool = true

    // Show location detail via sheet
    @Published var openedPost: Post?
    
    //SettingsView Settings
    @Published var distanceSettingEnabled: Bool = true {
        didSet{
            UserDefaults.standard.set(distanceSettingEnabled, forKey: "distanceSettingEnabled")
        }
    }
    @Published var distanceSetting: Int = 25 {
        didSet{
            UserDefaults.standard.set(distanceSetting, forKey: "distanceSetting")
        }
    }
    @Published var timeframeSettingEnabled: Bool = true {
        didSet{
            UserDefaults.standard.set(timeframeSettingEnabled, forKey: "timeframeSettingEnabled")
        }
    }
    @Published var timeframeSetting: Int = 24 {
        didSet{
            UserDefaults.standard.set(timeframeSetting, forKey: "timeframeSetting")
        }
    }
    
    // Map Settings View
    @Published var showMapSettings: Bool = false
    @Published var mapSettings = MapSettings() {
        didSet {
            if let encodedMapSettings = try? JSONEncoder().encode(mapSettings) {
                UserDefaults.standard.set(encodedMapSettings, forKey: "mapSettings")
            }
        }
    }
    
    // subscriptions
    var subscribers: Set<AnyCancellable> = []
    @Published var comments = [Comment]()
    @Published var posts = [Post]()
    @Published var users = [User]()
    @Published var postDetailUser: User?
    @Published var currentUser: User?

    init() {
        self.distanceSettingEnabled = UserDefaults.standard.bool(forKey: "distanceSettingEnabled")
        self.distanceSetting = UserDefaults.standard.integer(forKey: "distanceSetting")
        self.timeframeSettingEnabled = UserDefaults.standard.bool(forKey: "timeframeSettingEnabled")
        self.timeframeSetting = UserDefaults.standard.integer(forKey: "timeframeSetting")
        if let data = UserDefaults.standard.data(forKey: "mapSettings"),
           let decodedMapSettings = try? JSONDecoder().decode(MapSettings.self, from: data) {
            mapSettings = decodedMapSettings
        }
        CommentService.shared.listenToCommentsDatabase()
        subToCommentPublisher()
        PostService.shared.listenToPostsDatabase()
        subToPostPublisher()
        UserService.shared.listenToUsersDatabase()
        subToUserPublisher()
        AuthService.shared.listenToUsersDatabase()
        subToAuthPublisher()
    }
    
    func addComment(postId: String?) {
        Task {
            do {
                guard let postId = postId else {
                    print("[DEBUG ERROR] MapViewModel:addComment() Error: postId is nil\n")
                    return
                }
                guard let userId = AuthService.shared.currentUser?.id else {
                    print("[DEBUG ERROR] MapViewModel:addComment() Error: userId is nil\n")
                    return
                }
                let comment = Comment(
                    postId: postId,
                    content: commentContent,
                    timestamp: Date(),
                    posterId: userId
                )
                commentContent = ""
                try await CommentService.shared.addComment(comment: comment, postId: postId)
            } catch {
                print("[DEBUG ERROR] MapViewModel:addComment() Error: \(error.localizedDescription)\n")
            }
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
    
    func showNextLocation(post: Post?) {
        withAnimation(.easeInOut) {
            selectedPost = post
            showPostList = false
        }
    }
    
    func nextButtonPressed() {
        // Get the current index
        guard let currentIndex = nearestPosts.firstIndex(where: { $0 == selectedPost }) else {
            print("Could not find current index in locations array! Should never happen.\n")
            return
        }
        
        let nextIndex = currentIndex + 1
        guard nearestPosts.indices.contains(nextIndex) else {
            guard let firstLocation = nearestPosts.first else { return }
            showNextLocation(post: firstLocation)
            return
        }
        
        let nextLocation = nearestPosts[nextIndex]
        showNextLocation(post: nextLocation)
    }
    
    func clearSearch() {
        searchQuery = ""
        nearestPosts = []
        showPostList = false
    }
    
    //TODO: use this to fix addresses
    func searchLocation() {
        if searchQuery.isEmpty { return }
        // take the search query and make an API call to Position Stack
        // use the resultant coordinates to update the cameraLocation, selectedPost, and nearbyPosts
        let urlEncodedAddress = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        
        guard let url = URL(string: "\(POSITION_STACK_URL)?access_key=\(POSITION_STACK_API_KEY)&query=\(urlEncodedAddress)") else {
            print("Invalid URL\n")
            return
        }
        
        print("Searching for location: \(url)\n")
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print(error!.localizedDescription)
                return }
            
            guard let newCoordinates = try? JSONDecoder().decode(Address.self, from: data) else {
                    print("Could not decode data...\n")
                    return
                }
            
            if newCoordinates.data.isEmpty {
                print("Could not find address...\n")
                return
            }
            
            // Set the new data
            DispatchQueue.main.async {
                let details = newCoordinates.data[0]
                let lat = details.latitude
                let lon = details.longitude
                let newLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                withAnimation(.easeInOut) {
                    let newMapRegion = MKCoordinateRegion(
                        center: newLocation,
                        span: self.mapSpan)
//                    self.mapRegion = newMapRegion
                    self.cameraPosition = .region(newMapRegion)
                    
                    print("Successfully loaded location! \(details.name ?? "")\n")
                }
                let targetPosts = self.posts
                
                let filteredPosts = self.filterPosts(targetPosts: targetPosts, newCoordinates: newLocation)
                self.nearestPosts = filteredPosts
                
                if filteredPosts.count > 0 {
                    withAnimation(.easeInOut) {
                        self.showPostList = true
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
        print("New Map Point Lat: \(newMapPoint.coordinate.latitude), Lon: \(newMapPoint.coordinate.longitude)\n")
        // Get the posts that are within 10 miles of the current location
        let nearbyPosts = posts.filter { post in
            print("A point Lat: \(post.location.latitude), Lon: \(post.location.longitude)\n")

            let postMapPoint = MKMapPoint(post.location)
            let distance = newMapPoint.distance(to: postMapPoint)
            print("Distance: \(distance)\n")
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
    
    private func subToCommentPublisher() {
        print("[DEBUG] MapViewModel:subToCommentPublisher() started\n")
        CommentService.shared.commentPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    print("[DEBUG] MapViewModel:subToCommentPublisher() finished\n")
                case .failure(let error):
                    print("[DEBUG ERROR] MapViewModel:subToCommentPublisher() error: \(error.localizedDescription)\n")
                }
            } receiveValue: { [weak self] comments in
                print("[DEBUG] MapViewModel:subToCommentPublisher() receiveValue() comments: \(comments)\n")
                self?.comments = comments
            }
            .store(in: &subscribers)
    }
    
    private func subToPostPublisher() {
        print("[DEBUG] MapViewModel:subToPostPublisher() started\n")
        PostService.shared.postPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    print("[DEBUG] MapViewModel:subToPostPublisher() finished\n")
                case .failure(let error):
                    print("[DEBUG ERROR] MapViewModel:subToPostPublisher() error: \(error.localizedDescription)\n")
                }
            } receiveValue: { [weak self] posts in
                print("[DEBUG] MapViewModel:subToPostPublisher() receiveValue() posts: \(posts)\n")
                self?.posts = posts
            }
            .store(in: &subscribers)
    }
    
    private func subToUserPublisher() {
        print("[DEBUG] MapViewModel:subToUserPublisher() started\n")
        UserService.shared.userPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    print("[DEBUG] MapViewModel:subToUserPublisher() finished\n")
                case .failure(let error):
                    print("[DEBUG ERROR] MapViewModel:subToUserPublisher() error: \(error.localizedDescription)\n")
                }
            } receiveValue: { [weak self] users in
                print("[DEBUG] MapViewModel:subToUserPublisher() receiveValue() users: \(users)\n")
                self?.users = users
            }
            .store(in: &subscribers)
    }
    
    private func subToAuthPublisher() {
        print("[DEBUG] MapViewModel:subToAuthPublisher() started\n")
        AuthService.shared.userPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    print("[DEBUG] MapViewModel:subToAuthPublisher() finished\n")
                case .failure(let error):
                    print("[DEBUG ERROR] MapViewModel:subToAuthPublisher() error: \(error.localizedDescription)\n")
                }
            } receiveValue: { [weak self] currentUser in
                print("[DEBUG] MapViewModel:subToAuthPublisher() receiveValue() currentUser: \(currentUser)\n")
                self?.currentUser = currentUser
            }
            .store(in: &subscribers)
    }
    
    //TODO: consider potentially removing this
    func getUser(userId: String) {
        Task {
            do {
                let user = try await UserService.shared.fetchProfile(userId: userId)
                print("[DEBUG] MapViewModel:getUserById() user: \(user)\n")
                postDetailUser = user
            } catch {
                print("[DEBUG ERROR] MapViewModel:getUserById() error: \(error.localizedDescription)\n")
            }
        }
    }
}
