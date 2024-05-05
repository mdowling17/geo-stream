//
//  ImageService.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/1/24.
//

import Foundation
import SwiftUI
import PhotosUI
import SDWebImageSwiftUI

struct ProfileEditView: View {
    @StateObject private var profileEditVM = ProfileEditViewModel()
    
    var body: some View {
        VStack {
            AppHeader()
            VStack {
                VStack {
                    if let image = profileEditVM.image {
                        CircleImageView(image: image)
                    } else if let photoURL = profileEditVM.photoURL, let url = URL(string: photoURL) {
                        AnimatedImage(url: url)
                            .resizable()
                            .indicator(.activity)
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(radius: 10)
                    } else {
                        ProfilePicPlaceholderView()
                    }
                }
                .onTapGesture {
                    profileEditVM.isConfirmationDialogPresented = true
                }
                
                Text("Choose your profile picture")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.app)
                    .padding(.top, 20)
            }
            .padding(.vertical, 20)

            
            VStack(spacing: 40) {
                CustomTextField(placeholder: "Display name", icon: "person.text.rectangle", text: $profileEditVM.displayName)
                CustomTextField(placeholder:"Tell us about yourself", icon: "person.fill.questionmark", text: $profileEditVM.description)
            }
            .padding(.top)
            
            Button {
                profileEditVM.saveProfile()
            } label: {
                Text("Save Profile")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                    .background(Color.app)
                    .clipShape(Capsule())
                    .padding(.top, 20)
            }
            .shadow(radius: 10)
            
            if let error = profileEditVM.saveProfileMessage {
                Text(error)
                    .foregroundColor(profileEditVM.saveProfileMessageColor)
                    .padding(.top)
            }
                        
            Button {
                profileEditVM.signOut()
            } label: {
                Text("Sign Out")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                    .background(.red)
                    .clipShape(Capsule())
                    .padding(.top, 20)
            }
            .shadow(radius: 10)
            
            
            if let error = profileEditVM.signOutMessage {
                Text(error)
                    .foregroundColor(profileEditVM.signOutMessageColor)
                    .padding(.top)
            }
            
            Spacer()
        }
        .ignoresSafeArea()
        .onAppear() {
            profileEditVM.saveProfileMessage = nil
            profileEditVM.saveProfileMessageColor = .green
            profileEditVM.signOutMessage = nil
            profileEditVM.signOutMessageColor = .green
        }
        .padding(.horizontal, 40)
        .confirmationDialog("Choose an option", isPresented: $profileEditVM.isConfirmationDialogPresented) {
            Button("Camera") {
                profileEditVM.sourceType = .camera
                profileEditVM.isImagePickerPresented = true
            }
            Button("Photo Library") {
                profileEditVM.sourceType = .photoLibrary
                profileEditVM.isImagePickerPresented = true
            }
        }
        .sheet(isPresented: $profileEditVM.isImagePickerPresented) {
            if profileEditVM.sourceType == .camera {
                CameraPicker(isPresented: $profileEditVM.isImagePickerPresented, image: $profileEditVM.image, sourceType: .camera)
            } else {
                PhotoLibraryPicker(selectedImage: $profileEditVM.image)
            }
        }
    }
}

#Preview {
    ProfileEditView()
}
