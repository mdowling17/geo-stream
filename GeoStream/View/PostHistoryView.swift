//
//  PostHistoryView.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/5/24.
//

import SwiftUI

struct PostHistoryView: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                LazyVStack {
                    if let currentUser = profileVM.currentUser, let currentUserId = currentUser.id {
                        ForEach(profileVM.posts.filter { post in
                            return post.userId == currentUserId
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
        .navigationTitle("Post History")
    }
}


#Preview {
    PostHistoryView()
}
