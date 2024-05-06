//
//  ChatView.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/2/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct ChatView: View {
    @StateObject var chatVM = ChatViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Search", text: $chatVM.searchQuery)
                    .padding(7)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                
                Toggle(isOn: $chatVM.showOnlyFollowing) {
                    Text("Following")
                }
                .padding(.horizontal)
                ScrollView {
                    VStack {
                        if let currentUser = chatVM.currentUser {
                            ForEach(Array(chatVM.users.enumerated()), id: \.element) {
                                i, user in
                                if let userId = user.id, let currentUserId = currentUser.id, let displayName = user.displayName, (
                                    userId != currentUserId
                                ) && (
                                    !chatVM.showOnlyFollowing || currentUser.followingIds.contains(
                                        userId
                                    )
                                ) && (
                                    displayName.contains(
                                        chatVM.searchQuery
                                    ) || chatVM.searchQuery.isEmpty
                                ) {
                                    ZStack {
                                        NavigationLink {
                                            IndividualChatView(toUserId: userId).environmentObject(chatVM)
                                        } label: {
                                            HStack {
                                                if let photoURL = user.getPhotoURL() {
                                                    AnimatedImage(url: photoURL)
                                                        .resizable()
                                                        .indicator(.activity)
                                                        .frame(maxWidth: 32, maxHeight: 32)
                                                        .scaledToFill()
                                                        .clipShape(Circle())
                                                        .padding(.bottom, 4)
                                                } else {
                                                    Image(systemName: "person.circle.fill")
                                                        .resizable()
                                                        .frame(maxWidth: 32, maxHeight: 32)
                                                        .scaledToFill()
                                                        .foregroundColor(.app)
                                                        .padding(.bottom, 4)
                                                }
                                                
                                                Text(user.displayName ?? "")
                                                
                                                Spacer()
                                                
                                                Button(action: {
                                                    if currentUser.followingIds.contains(userId) {
                                                        chatVM.removeFriend(userId: userId)
                                                    } else {
                                                        chatVM.addFriend(userId: userId)
                                                    }
                                                }) {
                                                    Image(systemName: currentUser.followingIds.contains(userId) ? "person.badge.minus" : "person.badge.plus")
                                                }
                                            }
                                            
                                        }
                                        
                                    }
                                }
                            }
                        }
                        Spacer()
                    }
                    .navigationTitle("User Search")
                    .navigationBarTitleDisplayMode(.inline)
                    .padding()
                }
            }
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
