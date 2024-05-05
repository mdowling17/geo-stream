//
//  RequestLocationView.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/4/24.
//

import SwiftUI

struct RequestLocationView: View {
    var body: some View {
        VStack {
            Spacer()
            
            Image(systemName: "location.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            
            Text("Location Services")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top)
            
            Text("""
1. Tap the "Open Settings" button below
2. Tap on "Location Services"
3. Find and tap on "GeoStream"
4. Under "ALLOW LOCATION ACCESS" choose either "Ask Next Time Or When I Share" or "While Using the App"
""")
                .multilineTextAlignment(.leading)
                .padding()
            
            Button(action: {
                UIApplication.shared.open(
                    URL(string: UIApplication.openSettingsURLString)!,
                    options: [:],
                    completionHandler: nil
                )
            }) {
                Text("Open Settings")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
            
            Spacer()
        }
        .background(Color(.systemBackground))
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    RequestLocationView()
}
