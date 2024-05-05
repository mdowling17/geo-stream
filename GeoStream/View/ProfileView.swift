//
//  ProfileView.swift
//  GeoStream
//
//  Created by Zirui Wang on 5/3/24.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

struct ProfileView: View {
    @StateObject private var profileVM = ProfileViewModel()
    
    var body: some View {
        NavigationView{
            List{
                Section {
                    HStack(spacing: 20){
                        if let img = profileVM.image {
                            Image (uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .cornerRadius (64)
                                .overlay(RoundedRectangle(cornerRadius: 64)
                                    .stroke(Color.black, lineWidth:3))
                        } else if let photoURL = profileVM.photoURL, let url = URL(string: photoURL) {
                            AnimatedImage(url: url)
                                .resizable()
                                .indicator(.activity)
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                .shadow(radius: 10)
                        } else {
                            Image(systemName: "person.fill")
                                .font(.system(size:64))
                                .padding()
                                .overlay(RoundedRectangle(cornerRadius: 64)
                                    .stroke(Color.black, lineWidth:3))
                        }
                        VStack(alignment: .leading, spacing: 10){
                            Text("@\(profileVM.displayName)").bold().font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                            Text(profileVM.email)
                            HStack(spacing: 40) {
                                Text("Follower")
                                Text("Following")
                            }
                        }
                    }
                }
                
                Section("About Me"){
                    Text(profileVM.description)
                }
                
                Section("Post") {
                    NavigationLink(destination: FavPostView()) {
                        Label("Favorite", systemImage: "heart")
                    }
                    NavigationLink(destination: HistoryPostView()) {
                        Label("History", systemImage: "archivebox")
                    }
                }
                
                Section ("Account") {
                    NavigationLink(destination: ProfileEditView()){
                        Label("Edit Profile", systemImage: "pencil")
                    }
                    Button(action: {
                        profileVM.signOut()
                    }) {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}
