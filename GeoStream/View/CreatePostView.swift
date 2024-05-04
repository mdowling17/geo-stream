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
    var types = ["Event", "Alert", "Review", "All"]
    @EnvironmentObject var mapVM: MapViewModel
    @ObservedObject var createPostVM = CreatePostViewModel()
    
    var body: some View {
        VStack{
            HStack(alignment: .center) {
                if let user = createPostVM.user, let photoURL = user.getPhotoURL() {
                    AnimatedImage(url: photoURL)
                        .resizable()
                        .indicator(.activity)
                        .frame(maxWidth: 32, maxHeight: 32)
                        .scaledToFill()
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .frame(width: 32, height: 32)
                }
                
                Text("is posting")
                Picker("Type", selection: $createPostVM.type) {
                    ForEach(types, id: \.self) {
                        Text($0)
                    }
                }
                Text("at lat: \(createPostVM.lat), lon: \(createPostVM.lon)")
            }
            VStack {
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
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray, lineWidth: 2) // Set border color and width
                                    )
                                    .frame(width: 200, height: 200)
                    }
                }
            }
            .onTapGesture {
                createPostVM.isConfirmationDialogPresented = true
            }
            
            Text("Upload a photo")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.app)
                .padding(.top, 20)
            HStack {
                TextField("Title?", text: $createPostVM.title, axis: .vertical)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .padding([.bottom, .top, .leading])
                TextField("What's happening?", text: $createPostVM.content, axis: .vertical)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .padding([.bottom, .top, .leading])
                Button {
                    if createPostVM.content.count > 0 {
                        createPostVM.createPost()
                        mapVM.showCreatePost = false
                        let id = UUID().uuidString
                        let userId = createPostVM.user?.id ?? ""
                        let timestamp = Date()
                        let likes = 0
                        let content = createPostVM.content
                        let type = createPostVM.type
                        let location = LocationManager().location ?? CLLocationCoordinate2D(latitude: 37.778008, longitude: -122.431272)
                        let address = ""
                        let city = ""
                        let country = ""
                        let title = createPostVM.title
                        let imageUrl = [createPostVM.photoURL ?? ""]
                        let commentIds = [String]()
                        let newPost = Post(id: id, userId: userId, timestamp: timestamp, likes: likes, content: content, type: type, location: location, address: address, city: city, country: country, title: title, imageUrl: imageUrl, commentIds: commentIds)
                        mapVM.posts.append(newPost)
                        mapVM.selectedPost = newPost
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
    CreatePostView()
}
