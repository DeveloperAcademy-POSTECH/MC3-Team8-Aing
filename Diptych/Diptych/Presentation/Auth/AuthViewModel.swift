//
//  AuthViewModel.swift
//  Diptych
//
//  Created by HAN GIBAEK on 2023/07/13.
//
import SwiftUI
import Foundation
import Firebase
import FirebaseAuth

enum AuthenticationState {
    case unauthenticated
    case authenticating
    case authenticated
}

enum AuthenticationFlow {
    case login
    case signUp
}

enum EmailLinkStatus {
    case none
    case pending
}

@MainActor
class AuthViewModel: ObservableObject {
    @AppStorage("email-link") var emailLink: String?
    @Published var email = ""
    
    @Published var flow: AuthenticationFlow = .login
    
    @Published var isValid  = false
    @Published var authenticationState: AuthenticationState = .unauthenticated
    @Published var errorMessage = ""
    @Published var user: User?
    @Published var displayName = ""
    
    @Published var isGuestUser = false
    @Published var isVerified = false
    
    init() {
        registerAuthStateHandler()
        
        $email
            .map { email in
                !email.isEmpty
            }
            .assign(to: &$isValid)
        
        $user
            .compactMap { user in
                user?.isAnonymous
            }
            .assign(to: &$isGuestUser)
        
        $user
            .compactMap { user in
                user?.isEmailVerified
            }
            .assign(to: &$isVerified)
    }
    
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    func registerAuthStateHandler() {
        if authStateHandler == nil {
            authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
                self.user = user
                self.authenticationState = user == nil ? .unauthenticated : .authenticated
                self.displayName = user?.email ?? ""
            }
        }
    }
    
    func switchFlow() {
        flow = flow == .login ? .signUp : .login
        errorMessage = ""
    }
    
    private func wait() async {
        do {
            print("Wait")
            try await Task.sleep(nanoseconds: 1_000_000_000)
            print("Done")
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func reset() {
        flow = .login
        email = ""
        emailLink = nil
        errorMessage = ""
    }
}

// MARK: - Email and Link Authentication

extension AuthViewModel {
    func sendSignInLink() async {
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.url = URL(string: "https://diptych.page.link/email-link-auth")
        
        do {
            try await Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings)
            emailLink = email
        }
        catch {
            print(error.localizedDescription)
            errorMessage = error.localizedDescription
        }
    }
    
    var emailLinkStatus: EmailLinkStatus {
        emailLink == nil ? .none : .pending
    }
    
    func handleSignInLink(_ url: URL) async {
        guard let email = emailLink else {
            errorMessage = "Invalid email address. Most likely, the link you used has expired. Try signing in again."
            return
        }
        let link = url.absoluteString
        if Auth.auth().isSignIn(withEmailLink: link) {
            do {
                let result = try await Auth.auth().signIn(withEmail: email, link: link)
                let user = result.user
                print("User \(user.uid) signed in with email \(user.email ?? "(unknown)"). The email is \(user.isEmailVerified ? "" : "NOT") verified")
                emailLink = nil
            }
            catch {
                print(error.localizedDescription)
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        }
        catch {
            print(error)
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteAccount() async -> Bool {
        do {
            try await user?.delete()
            return true
        }
        catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
