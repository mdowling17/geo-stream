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
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if LocationService.shared.userIsSharingLocation {
                if AuthService.shared.currentFirebaseUser != nil && AuthService.shared.currentUser != nil {
                    ContentView()
                } else {
                    SignInView()
                }
            } else {
                RequestLocationView()
            }
        }
    }
}
