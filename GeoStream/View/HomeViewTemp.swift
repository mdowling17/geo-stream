//
//  HomeViewTemp.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/1/24.
//

import SwiftUI

struct HomeViewTemp: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        Button(action: {
            do {
                try AuthService.shared.signOut()
            } catch {
                print("[DEBUG ERROR] HomeViewTemp:signOut() Error: \(error.localizedDescription)")
            }
        }) {
            Text("Sign Out")
        }
    }
}

#Preview {
    HomeViewTemp()
}
