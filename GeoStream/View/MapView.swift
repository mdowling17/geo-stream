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
    @Namespace private var mapScope
    @FocusState var searchFieldFocus: Bool
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
    let maxWidthForIpad: CGFloat = 700
    
    var body: some View {
        ZStack {
            mapLayer
            
            VStack(spacing: 0) {
                header
                    .padding()
                    .frame(maxWidth: maxWidthForIpad)
                
                Spacer()
                locationsPreviewStack
            }
        }
        .sheet(item: $mapVM.openedPost, onDismiss: nil) { post in
            PostDetailView(post: post).environmentObject(mapVM)
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
            //            HStack {
            //                TextField("Search by address", text: $mapVM.searchQuery)
            //                    .disableAutocorrection(true)
            //                    .textInputAutocapitalization(.never)
            //                    .padding(10)
            //                    .background(Color(.systemGray6))
            //                    .cornerRadius(8)
            //
            //                Button {
            //                    mapVM.hitSearchButton()
            //                } label: {
            //                    if mapVM.showSearchButton {
            //                        Image(systemName: "magnifyingglass")
            //                            .foregroundColor(.gray)
            //                    } else {
            //                        Image(systemName: "xmark")
            //                            .foregroundColor(.gray)
            //                    }
            //
            //                }
            //                .padding(.trailing, 4)
            //
            //                Button {
            //                    mapVM.toggleSearchSettings()
            //                } label: {
            //                    Image(systemName: "gearshape.fill")
            //                        .foregroundColor(.gray)
            //                }
            //                .padding(.trailing)
            //            }
            //            .background(Color(.systemGray6))
            
            
            Button(action: mapVM.togglePostList) {
                HStack {
                    
                    if let nearestPost = mapVM.nearestPosts.first {
                        Image(systemName: "arrow.down")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(4)
                            .rotationEffect(Angle(degrees: mapVM.showPostList ? 180 : 0))
                        Text("Search results")
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
        Map(position: $cameraPosition, selection: $mapVM.selectedPost, scope: mapScope) {
            UserAnnotation()
            ForEach(mapVM.posts) { post in
                if (post.type == "Event") {
                    Marker("Event", systemImage: "calendar", coordinate: post.location)
                        .tint(.orange)
                        .tag(post)
                }
                else if (post.type == "Alert") {
                    Marker("Alert", systemImage: "exclamationmark.circle", coordinate: post.location)
                        .tint(.red)
                        .tag(post)
                    
                }
                else if (post.type == "Review") {
                    Marker("Review", systemImage: "list.star", coordinate: post.location)
                        .tint(.green)
                        .tag(post)
                    
                } else {
                    Marker("Post", systemImage: "questionmark", coordinate: post.location)
                        .tint(.blue)
                        .tag(post)
                }
            }
        }
        .onAppear {
            updateCameraPosition()
        }
        .onMapCameraChange{ context in
            mapVM.mapRegion = context.region
        }
        .onChange(of: mapVM.selectedPost) {
            updateCameraPositionToSelectedPost()
        }
        .mapStyle(mapVM.mapSettings.mapStyle)
        .safeAreaInset(edge: .bottom) {
            VStack {
                TextField("Search address", text: $mapVM.searchQuery)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($searchFieldFocus)
                    .overlay(alignment: .trailing) {
                        if searchFieldFocus {
                            HStack {
                                Button {
                                    mapVM.searchLocation()
                                } label: {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.gray)
                                }
                                Button {
                                    mapVM.clearSearch()
                                    searchFieldFocus = false
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.app)
                                }
                                .padding(.trailing, 4)
                            }
                            
                        }
                    }
                    .padding()
                
                // Create Post
                if mapVM.showCreatePostButton {
                    Button(action: {
                        mapVM.showCreatePost = true
                        mapVM.showPostList = false
                    }) {
                        Text("Create Post")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.app)
                            .cornerRadius(10)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .bottom)
                }

            }
        }
        .safeAreaInset(edge: .top, alignment: .trailing) {
            VStack {
                // Search Settings
                Button {
                    mapVM.toggleSearchSettings()
                } label: {
                    Image(systemName: "gearshape.fill")
                        .imageScale(.large)
                }
                .padding(8)
                .background(.thickMaterial)
                .clipShape(.circle)
                .sheet(isPresented: $mapVM.showSearchSettings) {
                    SearchSettingsView().environmentObject(mapVM)
                        .presentationDetents([.height(450)])
                }
                
                // Map Settings
                Button {
                    mapVM.showMapSettings.toggle()
                } label: {
                    Image(systemName: "globe.americas.fill")
                        .imageScale(.large)
                }
                .padding(8)
                .background(.thickMaterial)
                .clipShape(.circle)
                .sheet(isPresented: $mapVM.showMapSettings) {
                    MapSettingsView(mapSettings: $mapVM.mapSettings)
                        .presentationDetents([.height(275)])
                }
                
                // Map Controls
                MapUserLocationButton(scope: mapScope)
                MapCompass(scope: mapScope)
                    .mapControlVisibility(.visible)
                MapPitchToggle(scope: mapScope)
                    .mapControlVisibility(.visible)
            }
            .padding()
            .buttonBorderShape(.circle)
        }
        .mapScope(mapScope)
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
            if let _ = post.getFirstPhotoURL() {
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
    
    func updateCameraPosition() {
        if let userLocation = LocationService.shared.userLocation {
            let userRegion = MKCoordinateRegion(
                center: userLocation.coordinate,
                span: MKCoordinateSpan(
                    latitudeDelta: 0.05,
                    longitudeDelta: 0.05
                )
            )
            withAnimation {
                cameraPosition = .region(userRegion)
            }
        }
    }
    
    func updateCameraPositionToSelectedPost() {
        if let postCoordinates = mapVM.selectedPost?.location {
            let newlat = postCoordinates.latitude - 0.02
            let newCoordinates = CLLocationCoordinate2D(latitude: newlat, longitude: postCoordinates.longitude)
            let postRegion = MKCoordinateRegion(
                center: newCoordinates,
                span: MKCoordinateSpan(
                    latitudeDelta: 0.05,
                    longitudeDelta: 0.05
                )
            )
            withAnimation {
                cameraPosition = .region(postRegion)
            }
        }
    }
}
