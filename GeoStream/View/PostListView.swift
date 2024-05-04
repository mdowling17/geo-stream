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
    //@State private var showNewPostView = false
    @ObservedObject var postListVM = PostListViewModel()
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                LazyVStack {
                    ForEach(postListVM.posts, id: \.id) { post in
                            PostRowView(post: post, user: postListVM.user)
                                .padding()
                        }
                }
            }.task {
                postListVM.fetchPosts()
                postListVM.fetchUser()
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

struct PostRowView: View {
    var post: Post
    var user: User
    var age: Int {
        let diffs = Calendar.current.dateComponents([.hour, .minute], from: post.timestamp, to: Date())
        return diffs.hour ?? 0
    }
    @StateObject var PostRowVM = PostRowViewModel()
    @State var showComment: Bool = false
    
    var body: some View{
        VStack(alignment: .leading) {
            HStack(alignment: .top, spacing: 20) {
                if let img = PostRowVM.img {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .frame(width: 56, height: 56)
                        .foregroundColor(Color.green)
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 56, height: 56)
                        .foregroundColor(Color.green)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("@\(user.displayName ?? "NA")")
                            .font(.subheadline).bold()
                        Spacer()
                    }
                    Text(post.content)
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                }
            }.task {
                PostRowVM.fetchUserImg(post.userId)
            }
            ButtonsView
            Divider()
            
            if showComment {
                CommentsView()
                    .environmentObject(PostRowVM)
            }
            
        }
    }
}

extension PostRowView {
    var ButtonsView: some View {
        HStack {
            Button {
                if showComment {
                    showComment = false
                } else {
                    showComment = true
                }
            } label: {
                 Image(systemName: "bubble.left")
                    .font(.subheadline)
            }
            
            Spacer()
            Button {
                //viewModel.post.didLike ?? false ? viewModel.unlikePost() : viewModel.likePost()
            } label: {
                Image(systemName:"heart")
//                Image(systemName: viewModel.post.didLike ?? false ? "heart.fill" : "heart")
//                    .font(.subheadline)
//                    .foregroundColor(viewModel.post.didLike ?? false ? .red : .gray)
            }
            
            Spacer()
            HStack{
                Image(systemName: "clock")
                    .foregroundColor(.gray)
                Text("\(age) hours ago")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .foregroundColor(.gray)
    }
}

struct CommentsView: View {
    @EnvironmentObject var PostRowVM: PostRowViewModel
    
    var body: some View {
        Text("abc")
        List(PostRowVM.comments) { comment in
            Text(comment.content)
        }
    }
}


#Preview {
    PostRowView(post: Post(id: "first",
                        userId: "q5m1AGTK84owC1KShCEt",
                        timestamp: Date(),
                        likes: 0,
                        content: "love this app",
                        type: "event",
                        location: CLLocationCoordinate2D(latitude: 37.78815531914898, longitude: -122.40754586877463),
                        imageUrl: [],
                        commentId: []),
             user: User(email: "abc", displayName: "def", description: "cdf", photoURL: "dfs", followers: [], following: [], favPost:[]) )
}
