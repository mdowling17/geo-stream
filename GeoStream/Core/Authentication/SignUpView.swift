//
//  SignUpView.swift
//  GeoStream
//
//  Created by Zirui Wang on 4/29/24.
//

import SwiftUI

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showProfileEdit = false
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        VStack{
            VStack{
                TextField("Email", text: $email)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                SecureField("Password", text: $password)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            NavigationLink(destination: ProfileEditView(), isActive: $showProfileEdit) {
                    EmptyView()
            }.hidden()
            
            Button(action:{
                authVM.signUp(email: email, password: password, confirmPassword: confirmPassword) {result in
                    if result == true {
                        showProfileEdit = true
                    }
                }
            }) {
                Text("Sign Up")
                    .foregroundColor(.white)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.vertical)
            
            
            if let error = authVM.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding(.top)
            }
            
        }
        .navigationBarTitle("Register")
        .onAppear {
            authVM.errorMessage = ""
        }
    }
}

#Preview {
    SignUpView()
        .environmentObject(AuthViewModel())
}
