//
//  ContentView.swift
//  GeoStream
//
//  Created by Zirui Wang on 4/10/24.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView {
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
            ChatView()
                .tabItem {
                    Label("Chat", systemImage: "message")
                }
            ProfileEditView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }

        }
    }
}

#Preview {
    ContentView()
}
