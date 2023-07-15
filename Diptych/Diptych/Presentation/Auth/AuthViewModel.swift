//
//  AuthViewModel.swift
//  Diptych
//
//  Created by HAN GIBAEK on 2023/07/13.
//

import Foundation
import Firebase
import FirebaseAuth

class AuthViewModel: ObservableObject {
    func emailAuthSignUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("error: \(error.localizedDescription)")
                return
            }
            
            if result != nil {
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = email
                print("사용자 이메일: \(String(describing: result?.user.email))")
            }
        }
    }
    
    func signInWithEmailLink(email: String) async {
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.url = URL(string: "")
        do {
            try await Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings)
        } catch {
            print("ERROR (Sign with email link) : \(error.localizedDescription)")
        }
    }
    
    func verifyEmail(email: String, password: String) {
        Auth.auth().currentUser?.sendEmailVerification() { error in
            if let error = error {
                print("----------Verify Email Error: \(error.localizedDescription)")
            }
        }
    }
}
