//
//  SignInView.swift
//  GeoStream
//
//  Created by Matthew Dowling on 4/30/24.
//

import SwiftUI

struct SignInView: View {
    @StateObject var signInVM = SignInViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                AppHeader()
                
                VStack(spacing: 40) {
                    CustomTextField(placeholder: "Email", icon: "envelope", text: $signInVM.email)
                    CustomTextField(placeholder:"Password", icon: "lock", text: $signInVM.password, secure: true, showPassword: $signInVM.showPassword)
                }
                .padding(.top)
                
                HStack {
                    Spacer()
                    
                    NavigationLink {
                        ForgotPasswordView()
                    } label: {
                        Text("Forgot Password?")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color.app)
                            .padding(.top, 4)
                    }
                }
                
                Button {
                    signInVM.signIn()
                } label: {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                        .background(Color.app)
                        .clipShape(Capsule())
                        .padding(.top, 20)
                }
                .shadow(radius: 10)
                
                if let error = signInVM.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding(.top)
                }
                
                Spacer()
                
                NavigationLink(destination: SignUpView()) {
                    HStack {
                        Text("Need an account?")
                            .font(.footnote)
                        
                        Text("Sign Up")
                            .font(.footnote)
                            .fontWeight(.bold)
                    }
                }
                .padding(.bottom, 60)
                .foregroundColor(Color.app)
            }
            .ignoresSafeArea()
            .padding(.horizontal, 40)
        }
        .navigationBarHidden(true)
        .onAppear() {
            signInVM.errorMessage = nil
        }
    }
}

#Preview {
    SignInView()
}
