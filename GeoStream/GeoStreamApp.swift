//
//  GeoStreamApp.swift
//  GeoStream
//
//  Created by Zirui Wang on 4/10/24.
//

import SwiftUI
import Firebase

@main
struct GeoStreamApp: App {
    @StateObject var authVM = AuthViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
            .environmentObject(authVM)
        }
    }
}
