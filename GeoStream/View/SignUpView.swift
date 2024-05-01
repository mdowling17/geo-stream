//
//  SignUpView.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/1/24.
//

import SwiftUI

struct SignUpView: View {
    @StateObject var signUpVM = SignUpViewModel()
    
    var body: some View {
        VStack {
            AppHeader()
            
            VStack(spacing: 40) {
                CustomTextField(placeholder: "Email", icon: "envelope", text: $signUpVM.email)
                CustomTextField(placeholder: "Password", icon: "lock", text: $signUpVM.password, secure: true, showPassword: $signUpVM.showPassword)
                CustomTextField(placeholder: "Confirm Password", icon: "lock", text: $signUpVM.confirmPassword, secure: true, showPassword: $signUpVM.showConfirmPassword)
            }
            .padding(.vertical)
            
            Button {
                signUpVM.signUp()
            } label: {
                Text("Sign Up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                    .background(Color.app)
                    .clipShape(Capsule())
                    .padding(.top, 20)
            }
            .shadow(radius: 10)
            
            if let error = signUpVM.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding(.top)
            }
            
            Spacer()
        }
        .ignoresSafeArea()
        .padding(.horizontal, 40)
        .onAppear() {
            signUpVM.errorMessage = nil
        }
    }
}

#Preview {
    SignUpView()
}
