//
//  ProfileEditView.swift
//  GeoStream
//
//  Created by Zirui Wang on 4/29/24.
//

import SwiftUI

struct ProfileEditView: View {
    @State private var userName = ""
    @State private var number = ""
    @State private var org = ""
    @State var showImagePicker = false
    @State var image: UIImage?
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        VStack{
            Button {
                showImagePicker.toggle()
            } label: {
                VStack {
                    if let image = self.image {
                        Image (uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 128, height: 128)
                            .cornerRadius (64)
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size:64))
                            .padding()
                    }
                }.overlay(RoundedRectangle(cornerRadius: 64)
                    .stroke(Color.black, lineWidth:3))
            }
            TextField("User Name", text: $userName)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Number", text: $number)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Organization", text: $org)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button(action: {
                authVM.profileAdded = true
                if let img = image {
                    authVM.imageVM.uploadProfilePic(img: img, userVM: userVM)
                }
                Task {
                    await userVM.updateUser(userName: userName, number: number, org: org)
                }
            }){
                Text("Save")
                    .foregroundColor(.white)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }.navigationBarTitle("Edit Profile")
            .fullScreenCover(isPresented: $showImagePicker, onDismiss: nil, content: {
                ImagePicker(image: $image)
        })
    }
}

#Preview {
    ProfileEditingView()
        .environmentObject(UserViewModel())
        .environmentObject(ImageViewModel())
        .environmentObject(AppStateViewModel())
}
