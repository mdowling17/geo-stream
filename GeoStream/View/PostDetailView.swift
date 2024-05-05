//
//  PostDetailView.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/3/24.
//

import SwiftUI
import MapKit
import SDWebImageSwiftUI

struct PostDetailView: View {
    @EnvironmentObject private var mapVM: MapViewModel
    @StateObject private var postDetailVM = PostDetailViewModel()
    let post: Post
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    HStack {
                        if let user = AuthService.shared.currentUser {
                            if let url = user.getPhotoURL() {
                                AnimatedImage(url: url)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: 50, maxHeight: 50)
                                    .clipShape(Circle())
                            } else {
                                ProfilePicPlaceholderView()
                            }
                            Text("@\(user.displayName ?? "")")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        else {
                            Image(systemName: "person.fill")
                                .frame(maxWidth: 50, maxHeight: 50)
                                .padding()
                                .background(.app)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                            Text("@\("anonymous")")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            if !post.city.isEmpty, !post.country.isEmpty {
                                Text("\(post.city), \(post.country)")
                                    .font(.headline)
                            }
                            
                            Text("\(Calendar.current.dateComponents([.hour], from: post.timestamp, to: Date()).hour ?? 0) hrs ago")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                    }
                    .padding()
                    .frame(height: 50)
                    .onAppear {
                        mapVM.getUser(userId: post.userId)
                    }
                    
                }
                if let _ = post.getFirstPhotoURL() {
                    imageSection
                        .frame(height: 500)
                }
                
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        HStack {
                            Button {
                                postDetailVM.toggleLikePost(postId: post.id)
                            } label: {
                                HStack {
                                    if let postId = post.id, let user = mapVM.currentUser, user.likedPostIds.contains(postId) {
                                        Image(systemName: "heart.fill")
                                            .foregroundColor(.red)
                                    } else {
                                        Image(systemName: "heart")
                                            .foregroundColor(.red)
                                    }
                                    // display the like count of the post in the mapVM posts array that is equal to the current post
                                    Text("\(mapVM.posts.first(where: { $0.id == post.id })?.likes ?? 0)")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Divider()
                                .frame(height: 20)
                            
                            Button {
                                //TODO: comments
                            } label: {
                                HStack {
                                    Image(systemName: "bubble.right")
                                    Text("\(post.commentIds.count)") // Replace with actual comments count
                                    
                                }
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Capsule().fill(.ultraThinMaterial))
                        Spacer()
                    }
                    
                    descriptionSection
                    Divider()
                    mapLayer
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(.ultraThinMaterial)
        .onDisappear {
            mapVM.postDetailUser = nil
        }
    }
}

extension PostDetailView {
    
    private var imageSection: some View {
        TabView {
            ForEach(post.imageUrl, id: \.self) {
                if let photoURL = URL(string: $0) {
                    AnimatedImage(url: photoURL)
                        .resizable()
                        .indicator(.activity)
                        .scaledToFill()
                        .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? nil : UIScreen.main.bounds.width)
                        .clipped()
                }
                
            }
        }
        .tabViewStyle(PageTabViewStyle())
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(post.title)
                .font(.largeTitle)
                .fontWeight(.semibold)
            
            Text(post.address)
                .font(.title3)
                .foregroundColor(.secondary)
        }
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(post.content)
//                .font(.subheadline)
                .foregroundColor(.primary)
                .padding()
        }
    }
    
    private var mapLayer: some View {
        Map(coordinateRegion: .constant(MKCoordinateRegion(
            center: post.location,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))),
            annotationItems: [post]) { post in
            MapAnnotation(coordinate: post.location) {
                MapPinView(type: post.type)
                    .frame(width: 50, height: 50)
                    .shadow(color: .app, radius: 10)
            }
        }
            .allowsHitTesting(false)
            .aspectRatio(1, contentMode: .fit)
            .cornerRadius(30)
    }
    
    private var backButton: some View {
        Button {
            mapVM.openedPost = nil
        } label: {
            Image(systemName: "xmark")
                .font(.headline)
                .padding(16)
                .foregroundColor(.primary)
                .background(.thickMaterial)
                .cornerRadius(10)
                .shadow(radius: 4)
                .padding()
        }
        
    }
}

struct PostDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PostDetailView(post: PostService.mockPosts.first!)
            .environmentObject(MapViewModel())
    }
}
