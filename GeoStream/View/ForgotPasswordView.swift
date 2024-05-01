//
//  ForgotPasswordView.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/1/24.
//

import SwiftUI

struct ForgotPasswordView: View {
    @StateObject var forgotPasswordVM = ForgotPasswordViewModel()

    var body: some View {
        VStack {
            AppHeader()
            
            VStack(spacing: 40) {
                CustomTextField(placeholder: "Email", icon: "envelope", text: $forgotPasswordVM.email)
            }
            .padding(.vertical)
            
            Button {
                forgotPasswordVM.resetPassword()
            } label: {
                Text("Reset Password")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                    .background(Color.app)
                    .clipShape(Capsule())
                    .padding(.top, 20)
            }
            .shadow(radius: 10)
            
            if let error = forgotPasswordVM.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding(.top)
            }
            
            Spacer()
        }
        .ignoresSafeArea()
        .padding(.horizontal, 40)
        .onAppear() {
            forgotPasswordVM.errorMessage = nil
        }
    }
}

#Preview {
    ForgotPasswordView()
}
