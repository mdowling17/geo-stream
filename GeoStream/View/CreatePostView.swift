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
            
//            ZStack {
//                RoundedRectangle(cornerRadius: 10)
//                    .fill(.white)
//                    .overlay(RoundedRectangle(cornerRadius: 10)
//                        .stroke(Color.gray, lineWidth: 2) // Set border color and width
//                    )
//                    .frame(width: 60, height: 60)
//                Image(systemName: "camera.viewfinder")
//                    .frame(width: 140, height: 140)
//            }.onTapGesture {
//                createPostVM.isConfirmationDialogPresented = true
//            }
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
//                        mapVM.showCreatePost = false
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
//            VStack {
//                if let image = createPostVM.image {
//                    Image(uiImage: image)
//                        .resizable()
//                        .scaledToFill()
//                        .frame(width: 200, height: 200)
//                        .shadow(radius: 10)
//                } else if let photoURL = createPostVM.photoURL, let url = URL(string: photoURL) {
//                    AnimatedImage(url: url)
//                        .resizable()
//                        .indicator(.activity)
//                        .scaledToFill()
//                        .frame(width: 200, height: 200)
//                        .shadow(radius: 10)
//                } else {
//                    ZStack {
//                        RoundedRectangle(cornerRadius: 10)
//                            .fill(.white)
//                            .overlay(RoundedRectangle(cornerRadius: 10)
//                                    .stroke(Color.gray, lineWidth: 2) // Set border color and width
//                                    )
//                            .frame(width: 60, height: 60)
//                        Image(systemName: "camera.viewfinder")
//                            .frame(width: 120, height: 120)
                        
                        
                        
//                        Text("Upload a photo")
//                            .font(.headline)
//                            .fontWeight(.bold)
//                            .foregroundColor(.app)
//                            .padding(.top, 20)
//                    }
//                }
//            }
//            .onTapGesture {
//                createPostVM.isConfirmationDialogPresented = true
//            }
            
//            HStack {
//                TextField("Title?", text: $createPostVM.title, axis: .vertical)
//                    .textInputAutocapitalization(.never)
//                    .disableAutocorrection(true)
//                    .padding([.bottom, .top, .leading])
//                TextField("What's happening?", text: $createPostVM.content, axis: .vertical)
//                    .textInputAutocapitalization(.never)
//                    .disableAutocorrection(true)
//                    .padding([.bottom, .top, .leading])
//                Button {
//                    if createPostVM.content.count > 0 {
//                        createPostVM.createPost()
//                        mapVM.showCreatePost = false
//                        let id = UUID().uuidString
//                        let userId = createPostVM.user?.id ?? ""
//                        let timestamp = Date()
//                        let likes = 0
//                        let content = createPostVM.content
//                        let type = createPostVM.type
//                        let location = LocationManager().location ?? CLLocationCoordinate2D(latitude: 37.778008, longitude: -122.431272)
//                        let address = ""
//                        let city = ""
//                        let country = ""
//                        let title = createPostVM.title
//                        let imageUrl = [createPostVM.photoURL ?? ""]
//                        let commentIds = [String]()
//                        let newPost = Post(id: id, userId: userId, timestamp: timestamp, likes: likes, content: content, type: type, location: location, address: address, city: city, country: country, title: title, imageUrl: imageUrl, commentIds: commentIds)
//                        mapVM.posts.append(newPost)
//                        mapVM.selectedPost = newPost
//                    }
//                } label: {
//                    Image(systemName: "arrow.up")
//                        .foregroundColor(.white)
//                        .fontWeight(.bold)
//                        .padding(5)
//                        .background(.app)
//                        .clipShape(Circle())
//                }
//                .padding([.bottom, .top, .trailing])
//            }
//            .background {
//                RoundedRectangle(cornerRadius: 20)
//                    .stroke(.gray, lineWidth: 2)
//            }
//            .padding()
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
//        .toolbar{
//            Button {
//                createPostVM.createPost()
//            } label: {
//                Text("Post")
//                    .bold()
//                    .padding(.horizontal)
//                    .padding(.vertical, 8)
//                    .background(Color.app)
//                    .foregroundColor(.white)
//                    .clipShape(Capsule())
//            }
//        }
//        .onReceive(viewModel.$didUploadTweeet) { success in
//            if success {
//                viewModel.didUploadTweeet = false
//                presentationMode.wrappedValue.dismiss()
//            }
//       }
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
