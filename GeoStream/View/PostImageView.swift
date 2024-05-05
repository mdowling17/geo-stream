//
//  PostImageView.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/3/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct PostImageView: View {
    let post: Post
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
                if let photoURL = post.getFirstPhotoURL() {
                    AnimatedImage(url: photoURL)
                        .resizable()
                        .indicator(.activity)
                }
                MapPinView(type: post.type)
                    .frame(width: geometry.size.width * 0.5, height: geometry.size.height * 0.5)
            }
        }
    }
}
