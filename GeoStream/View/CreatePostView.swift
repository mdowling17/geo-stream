//
//  CreatePostView.swift
//  GeoStream
//
//  Created by Zirui Wang on 4/30/24.
//

import SwiftUI
import SDWebImageSwiftUI
import MapKit

struct CreatePostView: View {
    var types = ["Event", "Alert", "Review"]
    @EnvironmentObject var mapVM: MapViewModel
    @StateObject var createPostVM = CreatePostViewModel()
    
    var body: some View {
        VStack {
            EmptyView()
                .onChange(of: createPostVM.newPost) {
                    mapVM.selectedPost = createPostVM.newPost
                    mapVM.showCreatePost = false
                    mapVM.showPostList = false
                }
            Spacer()
            HStack(spacing: 0){
                if let user = createPostVM.user, let photoURL = user.getPhotoURL() {
                    AnimatedImage(url: photoURL)
                        .resizable()
                        .indicator(.activity)
                        .frame(maxWidth: 50, maxHeight: 50)
                        .scaledToFill()
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .frame(width: 50, height: 50)
                }
                
                Text("  share")
                Picker("Type", selection: $createPostVM.type) {
                    ForEach(types, id: \.self) {
                        Text($0)
                    }
                }
                Text("at  ")
                Image(systemName: "mappin.and.ellipse")
                Text("  [\(createPostVM.lat, specifier: "%.2f"), \(createPostVM.lon, specifier: "%.2f")]")
            }.padding()
            
            
            Divider()
            TextEditorWithPlaceholder(text: $createPostVM.content)
            
            if let image = createPostVM.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .shadow(radius: 10)
            } else if let photoURL = createPostVM.photoURL, let url = URL(string: photoURL) {
                AnimatedImage(url: url)
                    .resizable()
                    .indicator(.activity)
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .shadow(radius: 10)
            }
            
            HStack{
                Spacer()
                Button{
                    createPostVM.isConfirmationDialogPresented = true
                } label: {
                    Image(systemName: "camera.viewfinder")
                        .resizable()
                        .frame(width: 36.0, height: 36.0)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .padding(18)
                        .background(.app)
                        .clipShape(Circle())
                }
                .padding()
                Button {
                    if createPostVM.content.count > 0 {
                        createPostVM.createPost()
                    }
                } label: {
                    Image(systemName: "arrow.up")
                        .resizable()
                        .frame(width: 32.0, height: 32.0)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .padding(18)
                        .background(.app)
                        .clipShape(Circle())
                }
            }.frame(width: 320)
        }
        .confirmationDialog("Choose an option", isPresented: $createPostVM.isConfirmationDialogPresented) {
            Button("Camera") {
                createPostVM.sourceType = .camera
                createPostVM.isImagePickerPresented = true
            }
            Button("Photo Library") {
                createPostVM.sourceType = .photoLibrary
                createPostVM.isImagePickerPresented = true
            }
        }
        .sheet(isPresented: $createPostVM.isImagePickerPresented) {
            if createPostVM.sourceType == .camera {
                CameraPicker(isPresented: $createPostVM.isImagePickerPresented, image: $createPostVM.image, sourceType: .camera)
            } else {
                PhotoLibraryPicker(selectedImage: $createPostVM.image)
            }
        }
    }
}


struct TextEditorWithPlaceholder: View {
    @Binding var text: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                VStack {
                    Text("What's happening?")
                        .padding(.top, 10)
                        .padding(.leading, 6)
                        .opacity(1)
                    Spacer()
                }
            }
            VStack {
                TextEditor(text: $text)
                    .frame(minHeight: 10, maxHeight: 200)
                    .opacity(text.isEmpty ? 0.85 : 1)
                Spacer()
            }
        }.frame(width: 370)
    }
}

#Preview {
    CreatePostView()
}
