//
//  AppHeader.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/1/24.
//

import SwiftUI

struct AppHeader: View {
    var body: some View {
        VStack {
            Image("AppIconUsable")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding(.top, 80)
            Text("GeoStream")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(Color.white)
                .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity)
        .background(Color.app)
        .shadow(radius: 10)
        .padding(.horizontal, -40)
    }
}

#Preview {
    AppHeader()
}
