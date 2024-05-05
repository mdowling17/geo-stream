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
                            .onTapGesture{
                                postListVM.showSheet = true
                                selectedPost = post
                            }
                    }
                }
            }
        }.sheet(isPresented: $postListVM.showSheet) {
            PostSheetView(post: selectedPost!, user: postListVM.user)
        }.navigationTitle("Post History")
    }
}

struct PostSheetView: View {
        @StateObject var postSheetVM: PostSheetViewModel
        
        init(post: Post, user: User?) {
            _postSheetVM = StateObject(wrappedValue: PostSheetViewModel(post: post, user: user))
        }
        
        func getAge(time: Date) -> Int {
            return Calendar.current.dateComponents([.hour], from: time, to: Date()).hour ?? 0
        }
        
        var body: some View{
            VStack(){
                PostRowView(post: postSheetVM.post, user: postSheetVM.user)
                mapLayer
                Divider()
                ButtonsView
                Divider()
                
                if postSheetVM.showComment {
                    VStack{
                        ForEach(postSheetVM.comments) { comment in
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
                postSheetVM.toggleShowComment()
            } label: {
                Image(systemName: "bubble.left")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            Button {
                postSheetVM.isLiked ?? false ? postSheetVM.unlikePost() : postSheetVM.likePost()
            } label: {
                Image(systemName: postSheetVM.isLiked ?? false ? "heart.fill" : "heart")
                    .font(.subheadline)
                    .foregroundColor(postSheetVM.isLiked ?? false ? .red : .gray)
                Text("\(postSheetVM.post.likes)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            Button {
                postSheetVM.deletePost()
            } label: {
                Image(systemName: "trash")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            HStack{
                Image(systemName: "clock")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("\(getAge(time: postSheetVM.post.timestamp)) hours ago")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }.frame(width: 365)
    }
    
    private var mapLayer: some View {
        Map(coordinateRegion: .constant(MKCoordinateRegion(
            center: postSheetVM.post.location,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))),
            annotationItems: [postSheetVM.post]) { post in
            MapAnnotation(coordinate: post.location) {
                MapPinView(type: postSheetVM.post.type)
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
