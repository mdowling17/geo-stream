//
//  PostListView.swift
//  GeoStream
//
//  Created by Zirui Wang on 5/3/24.
//

import Foundation
import SwiftUI
import CoreLocation
import SDWebImageSwiftUI
import MapKit

struct FavPostView: View {
    var body: some View {
        Text("placeholder ViewModel fetch Posts by [postId], view is mostly identical")
    }
}

struct HistoryPostView: View {
    @StateObject var postListVM = HistoryPostViewModel()
    @State var selectedPost: Post?
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                LazyVStack {
                    ForEach(postListVM.posts) { post in
                        PostRowView(post: post, user: postListVM.user)
                            .padding()
                            .onTapGesture{
                                postListVM.showSheet = true
                                selectedPost = post
                            }
                    }
                }
            }
        }.sheet(isPresented: $postListVM.showSheet) {
            PostSheetView(post: selectedPost!, user: postListVM.user)
        }
    }
}

struct PostSheetView: View {
        // using same ViewModel class becasue most data displayed is identical
        @StateObject var postRowVM: PostRowViewModel
        
        init(post: Post, user: User?) {
            _postRowVM = StateObject(wrappedValue: PostRowViewModel(post: post, user: user))
        }
        
        func getAge(time: Date) -> Int {
            return Calendar.current.dateComponents([.hour], from: time, to: Date()).hour ?? 0
        }
        
        var body: some View{
            VStack {
                HStack(alignment: .top, spacing: 20) {
                    if let user = postRowVM.user, let photoURL = user.getPhotoURL() {
                        AnimatedImage(url: photoURL)
                            .resizable()
                            .indicator(.activity)
                            .frame(maxWidth: 56, maxHeight: 56)
                            .scaledToFill()
                            .clipShape(Circle())
                            .padding(.bottom, 4)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 56, height: 56)
                            .foregroundColor(Color.green)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("@\(postRowVM.user?.displayName ?? "NA")")
                                .font(.subheadline).bold()
                            Spacer()
                        }
                        Text(postRowVM.post.content)
                            .font(.subheadline)
                            .multilineTextAlignment(.leading)
                    }
                }
                mapLayer
                ButtonsView//(age: postRowVM.age).environmentObject(postRowVM)
                Divider()
                if postRowVM.showComment {
                    VStack{
                        ForEach(postRowVM.comments) { comment in
                            HStack {
                                Text("@\(comment.posterName)").bold()
                                Text(comment.content)
                                Spacer()
                                Text("\(getAge(time: comment.timestamp)) hours ago")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Divider()
                            
                        }
                    }
                }
            }
        }
    }


extension PostSheetView {
    var ButtonsView: some View {
        HStack {
            Button {
                postRowVM.toggleShowComment()
            } label: {
                Image(systemName: "bubble.left")
                    .font(.subheadline)
            }
            
            Spacer()
            HStack{
                Image(systemName: postRowVM.isLiked ?? false ? "heart.fill" : "heart")
                    .font(.subheadline)
                    .foregroundColor(postRowVM.isLiked ?? false ? .red : .gray)
                Text("\(postRowVM.post.likes)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
//            Button {
//                postRowVM.isLiked ?? false ? postRowVM.unlikePost() : postRowVM.likePost()
//            } label: {
//                Image(systemName: postRowVM.isLiked ?? false ? "heart.fill" : "heart")
//                    .font(.subheadline)
//                    .foregroundColor(postRowVM.isLiked ?? false ? .red : .gray)
//            }
            
            Button {
                postRowVM.deletePost()
            } label: {
                Image(systemName: "trash")
                    .font(.subheadline)
                    .foregroundColor(postRowVM.isLiked ?? false ? .red : .gray)
            }
            
            Spacer()
            HStack{
                Image(systemName: "clock")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("\(getAge(time: postRowVM.post.timestamp)) hours ago")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var mapLayer: some View {
        Map(coordinateRegion: .constant(MKCoordinateRegion(
            center: postRowVM.post.location,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))),
            annotationItems: [postRowVM.post]) { post in
            MapAnnotation(coordinate: post.location) {
                MapPinView(type: postRowVM.post.type)
                    .frame(width: 50, height: 50)
                    .shadow(color: .app, radius: 10)
            }
        }
            .allowsHitTesting(false)
            .aspectRatio(1, contentMode: .fit)
            .cornerRadius(30)
    }
}


#Preview {
    HistoryPostView()
}
