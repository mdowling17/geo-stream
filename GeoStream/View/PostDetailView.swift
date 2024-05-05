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
    let post: Post
    
    var body: some View {
        ScrollView {
            VStack {
                if let _ = post.getFirstPhotoURL() {
                    imageSection
                        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
                        .frame(height: 500)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    titleSection
                    Divider()
                    descriptionSection
                    Divider()
                    mapLayer
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
        }
        .ignoresSafeArea()
        .background(.ultraThinMaterial)
        .overlay(backButton, alignment: .topLeading)
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
                .font(.subheadline)
                .foregroundColor(.secondary)
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
