//
//  IndividualChatView.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/3/24.
//

import SwiftUI

struct IndividualChatView: View {
    @EnvironmentObject var chatVM: ChatViewModel
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    chatVM.showIndividualChat = false
                } label: {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(.app)
                        .fontWeight(.bold)
                        .font(.title)
                        .padding()
                }
                Spacer()
            }
            ScrollViewReader { scrollView in
                ScrollView {
                    // add a dismiss button
                    VStack(spacing: 8) {
                        ForEach(Array(chatVM.messages.enumerated()), id: \.element) { idx, message in
                            MessageView(message: message)
                                .id(idx)
                        }
                        .onChange(of: chatVM.messages) { _ in
                            scrollView.scrollTo(chatVM.messages.count - 1, anchor: .bottom)
                        }
                    }
                }
                .onAppear() {
                    scrollView.scrollTo(chatVM.messages.count - 1, anchor: .bottom)
                }
            }
            
            HStack {
                TextField("Hello there", text: $chatVM.text, axis: .vertical)
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
    }
}

#Preview {
    IndividualChatView().environmentObject(ChatViewModel())
}
