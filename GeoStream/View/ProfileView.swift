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
                        if let url = profileVM.currentUser?.getPhotoURL() {
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
                            if let user = profileVM.currentUser {
                                Text("@\(user.displayName ?? "")")
                                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                    .fontWeight(.bold)
                                Text(user.email)
                                HStack(spacing: 40) {
                                    Text("Follower")
                                    Text("Following")
                                }
                            }
                        }
                    }
                }
                
                Section("About Me"){
                    Text(profileVM.currentUser?.description ?? "")
                }
                
                Section("Post") {
                    NavigationLink(destination: LikedPostsView().environmentObject(profileVM)) {
                        Label("Liked Posts", systemImage: "heart")
                    }
                    NavigationLink(destination: PostHistoryView().environmentObject(profileVM)) {
                        Label("Post History", systemImage: "archivebox")
                    }
                }
                
                Section ("Account") {
                    NavigationLink(destination: ProfileEditView().environmentObject(profileVM)){
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
