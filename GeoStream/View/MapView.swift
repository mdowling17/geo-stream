//
//  MapView.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/3/24.
//

import SwiftUI
import MapKit
import SDWebImageSwiftUI

@MainActor
struct MapView: View {
    @StateObject var mapVM = MapViewModel()
    
    let maxWidthForIpad: CGFloat = 700
    
    var body: some View {
        ZStack {
            mapLayer
                .onTapGesture {
                    mapVM.selectedPost = nil
                }
            
            VStack(spacing: 0) {
                header
                    .padding()
                    .frame(maxWidth: maxWidthForIpad)
                
                Spacer()
                locationsPreviewStack
            }

            if mapVM.showCreatePostButton {
                Button(action: {
                    mapVM.showCreatePost = true
                    }) {
                        Text("Create Post")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.app)
                            .cornerRadius(10)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
        }
        .sheet(item: $mapVM.openedPost, onDismiss: nil) { post in
            PostDetailView(post: post).environmentObject(mapVM)
        }
        .sheet(isPresented: $mapVM.showSearchSettings) {
            SearchSettingsView().environmentObject(mapVM)
        }
        .sheet(isPresented: $mapVM.showCreatePost) {
            CreatePostView().environmentObject(mapVM)
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}

extension MapView {
    private var header: some View {
        VStack {
            HStack {
                TextField("Search by address", text: $mapVM.searchQuery)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                Button {
                    mapVM.hitSearchButton()
                } label: {
                    if mapVM.showSearchButton {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                    } else {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                    }
                    
                }
                .padding(.trailing, 4)
                
                Button {
                    mapVM.toggleSearchSettings()
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.gray)
                }
                .padding(.trailing)
            }
            .background(Color(.systemGray6))

            
            Button(action: mapVM.togglePostList) {
                HStack {
                    Image(systemName: "arrow.down")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(4)
                        .rotationEffect(Angle(degrees: mapVM.showPostList ? 180 : 0))
                    if let nearestPost = mapVM.nearestPosts.first {
                        Text("Nearest: \(nearestPost.title)")
                            .font(.headline)
                            .fontWeight(.black)
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .animation(.none, value: mapVM.selectedPost)
            }
            
            if mapVM.showPostList {
                locationsListView
            }
        }
        .background(.thickMaterial)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 15)
    }

    private var mapLayer: some View {
        Map(position: $mapVM.cameraPosition, selection: $mapVM.selectedPost) {
            ForEach(mapVM.posts) { post in
                if (post.type == "event") {
                    Marker("Event", systemImage: "calendar", coordinate: post.location)
                        .tint(.orange)
                        .tag(post)
                }
                else if (post.type == "alert") {
                    Marker("Alert", systemImage: "exclamationmark.circle", coordinate: post.location)
                        .tint(.red)
                        .tag(post)
                }
                else if (post.type == "review") {
                    Marker("Review", systemImage: "list.star", coordinate: post.location)
                        .tint(.green)
                        .tag(post)
                }
            }
        }
        .mapControls{
            //TODO: clean this up
//            MapUserLocationButton()
//            MapCompass()
//            MapScaleView()
        }
    }
   
    
    private var locationsPreviewStack: some View {
        ZStack {
            ForEach(mapVM.posts) { post in
                if mapVM.selectedPost == post {
                    PostPreviewView(post: post)
                        .environmentObject(mapVM)
                        .shadow(color: Color.black.opacity(0.3), radius: 20)
                        .padding()
                        .frame(maxWidth: maxWidthForIpad)
                        .frame(maxWidth: .infinity)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)))
                }
            }
        }
    }
    
    private var locationsListView: some View {
        List {
            ForEach(mapVM.nearestPosts) { post in
                Button {
                    mapVM.showNextLocation(post: post)
                } label: {
                    listRowView(post: post)
                }
                .padding(.vertical, 4)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(PlainListStyle())
        .frame(maxHeight: 250)
    }
    
    private func listRowView(post: Post) -> some View {
        HStack {
            if let photoURL = post.getFirstPhotoURL() {
                PostImageView(post: post)
                    .frame(width: 45, height: 45)
                    .scaledToFill()
                    .cornerRadius(10)
            } else {
                VStack {
                    MapPinView(type: post.type)
                        .frame(width: 45, height: 45)
                }
                
            }
            
            VStack(alignment: .leading) {
                Text(post.title)
                    .font(.headline)
                Text(post.address)
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
}
