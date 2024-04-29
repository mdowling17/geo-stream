//
//  SignInView.swift
//  GeoStream
//
//  Created by Zirui Wang on 4/29/24.
//

import SwiftUI

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack {
                    TextField("Email", text: $email)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                    SecureField("Password", text: $password)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Button(action: {
                    authVM.signIn(email: email, password: password)
                }){
                    Text("Sign In")
                        .foregroundColor(.white)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.vertical)
                NavigationLink(destination: SignUpView()
                    .environmentObject(authVM))
                {
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.gray)
                        Text("Sign Up")
                            .foregroundColor(.blue)
                            .fontWeight(.semibold)
                    }
                }
                if let error = authVM.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding(.top)
                }
            }
            .navigationBarTitle("Sign In")
            .onAppear {
                authVM.errorMessage = ""
            }
        }
    }
}

#Preview {
    SignInView()
        .environmentObject(AuthViewModel())
}
