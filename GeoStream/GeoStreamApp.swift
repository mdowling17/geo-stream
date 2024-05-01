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
            if AuthService.shared.currentUser != nil {
                HomeViewTemp()
            } else {
                SignInView()
            }
        }
    }
}
