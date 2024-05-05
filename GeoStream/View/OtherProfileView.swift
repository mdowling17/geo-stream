//
//  OtherProfileView.swift
//  GeoStream
//
//  Created by Zirui Wang on 5/5/24.
//

import Foundation

import Foundation
import SwiftUI
import SDWebImageSwiftUI

struct OtherProfileView: View {
//    @State var otherProfileVM = OtherProfileViewModel()
//    @State var selectedPost: Post?
//    var user: User
    
    @StateObject var otherProfileVM: OtherProfileViewModel
    @State var selectedPost: Post?
    var user: User
    
    init(user: User) {
        self.user = user
        _otherProfileVM = StateObject(wrappedValue: OtherProfileViewModel(userId: user.id!))
    }
    
    var body: some View {
        NavigationView{
            List{
                Section {
                    HStack(spacing: 20){
                        if let photoURL = user.photoURL, let url = URL(string: photoURL) {
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
                            Text("@\(user.displayName ?? "")").bold().font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                            Text(user.email)
                            HStack(spacing: 40) {
                                Text("Follower")
                                Text("Following")
                            }
                        }
                    }
                }
                
                Section("About User"){
                    Text(user.description ?? "")
                }
                
                
                ZStack(alignment: .bottomTrailing) {
                    ScrollView {
                        LazyVStack {
                            ForEach(otherProfileVM.posts) { post in
                                PostRowView(post: post, user: user)
                                    .onTapGesture{
                                        otherProfileVM.showSheet = true
                                        selectedPost = post
                                    }
                            }
                        }
                    }
                }.sheet(isPresented: $otherProfileVM.showSheet) {
                    PostSheetView(post: selectedPost!, user: user)
                }
            }
        }
    }
}

class OtherProfileViewModel: ObservableObject {
    @Published var posts = [Post]()
    @Published var showSheet: Bool = false
    
    init(userId: String) {
        fetchPosts(userId)
    }
    
    func fetchPosts(_ userId: String) {
        Task {
            do {
                let fetchedPosts = try await PostService.shared.fetchPostsByUserId(userId)
                posts = fetchedPosts
            } catch {
                print("[DEBUG ERROR] PostListViewModel:fetchPosts() Error: \(error.localizedDescription)\n")
            }
        }
    }
}

