//
//  PostSheetView.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/5/24.
//

import SwiftUI
import MapKit
import SDWebImageSwiftUI

struct PostSheetView: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    var post: Post
    var user: User?
    
    func getAge(time: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: time, to: Date()).hour ?? 0
    }
    
    var body: some View {
        ScrollView {
            VStack {
                PostRowView(post: post, user: user)
                mapLayer
                Divider()
                ButtonsView
                
                if let postId = post.id {
                    VStack {
                        Divider()
                        ForEach(profileVM.comments) { comment in
                            if comment.postId == postId {
                                HStack {
                                    if let user = profileVM.users.first(where: {$0.id == comment.posterId}), let displayName = user.displayName {
                                        if let url = user.getPhotoURL() {
                                            AnimatedImage(url: url)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(maxWidth: 50, maxHeight: 50)
                                                .clipShape(Circle())
                                        } else {
                                            ProfilePicPlaceholderView()
                                        }
                                        Text("@\(displayName)").bold()
                                        Text(comment.content)
                                        Spacer()
                                        Text("\(getAge(time: comment.timestamp)) hours ago")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding()
                            }
                        }
                        
                        HStack {
                            TextField("Add a comment...", text: $profileVM.commentContent)
                                .padding()
                                .background(.ultraThinMaterial)
                                .cornerRadius(10)
                            
                            Button {
                                profileVM.addComment(postId: post.id)
                                profileVM.commentContent = ""
                            } label: {
                                Image(systemName: "paperplane")
                                    .padding()
                                    .background(.app)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .padding(.vertical)
        }
    }
}


extension PostSheetView {
    var ButtonsView: some View {
        HStack {
            Button {
                
            } label: {
                HStack {
                    Image(systemName: "bubble.left")
                    Text("\(profileVM.posts.first(where: { $0.id == post.id })?.commentIds.count ?? 0)")
                }
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button {
                profileVM.toggleLikePost(postId: post.id)
            } label: {
                HStack {
                    if let postId = post.id, let user = profileVM.currentUser, user.likedPostIds.contains(postId) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                    } else {
                        Image(systemName: "heart")
                            .foregroundColor(.red)
                    }
                    // display the like count of the post in the profileVM posts array that is equal to the current post
                    Text("\(profileVM.posts.first(where: { $0.id == post.id })?.likes ?? 0)")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            HStack{
                Image(systemName: "clock")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("\(getAge(time: post.timestamp)) hours ago")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }.frame(width: 365)
    }
    
    private var mapLayer: some View {
        Map(coordinateRegion: .constant(MKCoordinateRegion(
            center: post.location,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))),
            annotationItems: [post]) { post in
            MapAnnotation(coordinate: post.location) {
                MapPinView(type: post.type)
                    .frame(width: 50, height: 50)
                    .shadow(color: .app, radius: 10)
            }
        }
            .allowsHitTesting(false)
            .aspectRatio(1, contentMode: .fit)
            .cornerRadius(30)
    }
}

//TODO: reenable preview
//#Preview {
//    PostSheetView()
//}
