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
            StreamView()
                .tabItem {
                    Label("Stream", systemImage: "globe")
                }
            
            ChatView()
                .tabItem {
                    Label("Chat", systemImage: "message")
                }
            
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

#Preview {
    ContentView()
}
