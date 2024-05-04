//
//  MapPinView.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/3/24.
//

import SwiftUI

struct MapPinView: View {
    var accentColor: Color = .app
    var systemImage: String = "info"
    
    init(type: String) {
        if type == "event" {
            systemImage = "calendar"
            accentColor = .orange
        } else if type == "alert" {
            systemImage = "exclamationmark.circle"
            accentColor = .red
        } else if type == "review" {
            systemImage = "list.star"
            accentColor = .app
        }
    }
        
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Image(systemName: systemImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(geometry.size.width * 0.20) // 20% padding
                    .foregroundColor(.white)
                    .font(.headline)
                    .background(accentColor)
                    .clipShape(Circle())
                
                Image(systemName: "triangle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(accentColor)
                    .frame(width: geometry.size.width * 0.10, height: geometry.size.height * 0.10)
                    .rotationEffect(Angle(degrees: 180))
                    .offset(y: -geometry.size.height * 0.02)
            }
        }
    }
}

struct LocationMapAnnotationView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            MapPinView(type: "event")
                .frame(width: 100, height: 100)
                .scaledToFill()
            .cornerRadius(10)
        }
    }
}
