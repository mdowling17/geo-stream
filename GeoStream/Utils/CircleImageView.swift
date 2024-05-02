//
//  CircleImageView.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/1/24.
//

import SwiftUI

struct CircleImageView: View {
    var image: UIImage
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 4))
            .shadow(radius: 10)
    }
}

#Preview {
    CircleImageView(image: UIImage(named: "profile_pic")!)
}
