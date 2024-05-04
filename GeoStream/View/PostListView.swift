//
//  PostListView.swift
//  GeoStream
//
//  Created by Zirui Wang on 5/3/24.
//

import Foundation
import SwiftUI
import CoreLocation

struct PostListView: View {
    @StateObject var postListVM = PostListViewModel()
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                LazyVStack {
                    ForEach(postListVM.posts) { post in
                        PostRowView(post: post, user: postListVM.user)
                            .padding()
                    }
                }
            }.task {
                //TODO: clean this up
                //                postListVM.fetchPosts()
                //                postListVM.fetchUser()
            }
            //            Button {
            //                print("New post")
            //                showNewPostView.toggle()
            //            } label: {
            //                Image("newPost")
            //                    .resizable()
            //                    .renderingMode(.template)
            //                    .frame(width: 28, height: 28)
            //                    .padding()
            //            }
            //            .background(Color.themeColor)
            //            .foregroundColor(.white)
            //            .clipShape(Circle())
            //            .padding()
            //            .padding(.trailing, 10)
            //            .padding(.bottom, 20)
            //            .fullScreenCover(isPresented: $showNewPostView, onDismiss: {
            //                viewModel.fetchPosts()
            //            }) {
            //               NewPostView()
            //            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    PostListView()
}
