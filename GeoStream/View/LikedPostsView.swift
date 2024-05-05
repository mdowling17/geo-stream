//
//  LikedPostsView.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/5/24.
//

import SwiftUI

struct LikedPostsView: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                LazyVStack {
                    if let currentUser = profileVM.currentUser {
                        ForEach(profileVM.posts.filter { post in
                            guard let postId = post.id else { return false }
                            return currentUser.likedPostIds.contains(postId)
                        }) { post in
                            PostRowView(post: post, user: profileVM.currentUser)
                                .onTapGesture{
                                    profileVM.selectedPost = post
                                }
                        }
                    }
                }
            }
        }
        .sheet(item: $profileVM.selectedPost, onDismiss: nil) { post in
            PostSheetView(post: post, user: profileVM.currentUser).environmentObject(profileVM)
        }
        .navigationTitle("Liked Posts")
    }
}

#Preview {
    LikedPostsView().environmentObject(ProfileViewModel())
}
