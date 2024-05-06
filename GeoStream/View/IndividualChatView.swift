//
//  IndividualChatView.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/3/24.
//

import SwiftUI

struct IndividualChatView: View {
    @EnvironmentObject var chatVM: ChatViewModel
    var toUserId: String
    
    var body: some View {
        VStack {
            ScrollViewReader { scrollView in
                ScrollView {
                    // add a dismiss button
                    VStack(spacing: 8) {
                        if let currentUser = chatVM.currentUser, let currentUserId = currentUser.id {
                            ForEach(Array(chatVM.messages.filter { message in
                                let isValid = (message.fromUserId == currentUserId && message.toUserId == toUserId) || (message.fromUserId == toUserId && message.toUserId == currentUserId)
                                return isValid
                            }.enumerated()), id: \.element) { idx, message in
                                // only show messages between the currentUser and the toUser
                                MessageView(message: message)
                                    .id(idx)
                            }
                            .onChange(of: chatVM.messages) {
                                scrollView.scrollTo(chatVM.messages.count - 1, anchor: .bottom)
                            }
                        }
                    }
                }
                .onAppear() {
                    scrollView.scrollTo(chatVM.messages.count - 1, anchor: .bottom)
                }
            }
            
            HStack {
                TextField("Say hi", text: $chatVM.text, axis: .vertical)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .padding([.bottom, .top, .leading])
                Button {
                    if chatVM.text.count > 0 {
                        chatVM.sendChatMessage(text: chatVM.text)
                        chatVM.text = ""
                    }
                } label: {
                    Image(systemName: "arrow.up")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .padding(5)
                        .background(.app)
                        .clipShape(Circle())
                }
                .padding([.bottom, .top, .trailing])
            }
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.gray, lineWidth: 2)
            }
            .padding()
        }
        .onAppear {
            chatVM.toUserId = toUserId
        }
    }
}

#Preview {
    IndividualChatView(toUserId: "BLq7A3itHffkzJtQHU5Vv23iCMG2").environmentObject(ChatViewModel())
}
