//
//  CreatePostView.swift
//  GeoStream
//
//  Created by Zirui Wang on 4/30/24.
//

import SwiftUI

struct CreatePostView: View {
    @State private var content = ""
    @State private var selectedType = "Event"
    var type = ["Event", "Alert", "Review", "All"]
    @ObservedObject var CreatePostVM = CreatePostViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack{
            HStack(alignment: .center) {
//                if let user = authViewModel.currentUser {
//                    KFImage(URL(string: user.avatarUrl))
//                        .resizable()
//                        .scaledToFill()
//                        .clipShape(Circle())
//                        .frame(width: 64, height: 64)
//                }
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
                    .frame(width: 50, height: 50)
                Text("is posting")
                Picker("Type", selection: $selectedType) {
                    ForEach(type, id: \.self) {
                        Text($0)
                    }
                }
                Text("at")
            }
            TextArea("What's happening?", text: $content)
        }.toolbar{
            Button {
                CreatePostVM.createPost(content: content, type: selectedType)
            } label: {
                Text("Post")
                    .bold()
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
//        .onReceive(viewModel.$didUploadTweeet) { success in
//            if success {
//                viewModel.didUploadTweeet = false
//                presentationMode.wrappedValue.dismiss()
//            }
//       }
    }
}

struct TextArea: View {
    @Binding var text: String
    let placeholder: String
    
    init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(Color.gray)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 12)
            }
            TextEditor(text: $text)
                .padding(4)
                .disableAutocorrection(true)
        }
        .font(.body)
    }
}

#Preview {
    CreatePostView().environmentObject(AuthViewModel())
}
