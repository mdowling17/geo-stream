//
//  ContentView.swift
//  GeoStream
//
//  Created by Zirui Wang on 4/10/24.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    var body: some View {
        TabView(selection: $selectedTab) {
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(0)
                
            ChatView()
                .tabItem {
                    Label("Chat", systemImage: "message")
                }
                .tag(1)
                            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(2)

        }
    }
}

#Preview {
    ContentView()
}
