//
//  ProfilePicPlaceholderView.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/1/24.
//

import SwiftUI

struct ProfilePicPlaceholderView: View {
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 5)
                .foregroundColor(.gray)
                .frame(width: 100, height: 100)
            Image(systemName: "person.fill")
                .font(.system(size: 25))
                .foregroundColor(.gray)
                
        }
        .clipShape(Circle())
    }
}

#Preview {
    ProfilePicPlaceholderView()
}
