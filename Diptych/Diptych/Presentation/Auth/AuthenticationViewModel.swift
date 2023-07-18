//
//  AuthViewModel.swift
//  Diptych
//
//  Created by HAN GIBAEK on 2023/07/13.
//
import Foundation
//import FirebaseAuth
import Firebase
import FirebaseFirestoreSwift

enum AuthenticationFlow: String {
    case isInitialized = "isInitialized"
    case isSignedUp = "isSignedUp"
    case isEmailVerified = "isEmailVerified"
    case completed = "completed"
}

@MainActor
class AuthenticationViewModel: ObservableObject {
    //    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: DiptychUser?
    @Published var flow: AuthenticationFlow = .isInitialized
    @Published var isEmailVerified: Bool = false
    
    init() {
        //        self.userSession = Auth.auth().currentUser //currentUser가 없으면 nil이 할당
        Task {
            await fetchUser()
            if let currentUser = self.currentUser {
                self.flow = AuthenticationFlow(rawValue: currentUser.flow) ?? .isInitialized
            }
        }
    }
    
    func signInWithEmailPassword(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            //            self.userSession = result.user
            await fetchUser()
            if let currentUser = self.currentUser {
                self.flow = AuthenticationFlow(rawValue: currentUser.flow) ?? .isInitialized
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func signUpWithEmailPassword(email: String, password: String, name: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            //            self.userSession = result.user
            let user = DiptychUser(id: result.user.uid, email: email, name: name, flow: "isSignedUp")
            //            print(user.id)
            //            print(user.email)
            let encodedUser = try Firestore.Encoder().encode(user)
            //            print(encodedUser)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            await fetchUser()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func sendEmailVerification() async throws {
        do {
            try await Auth.auth().currentUser?.sendEmailVerification()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func checkEmailVerification() async throws {
        do {
            repeat {
                await wait()
                try await Auth.auth().currentUser?.reload()
                if let isEmailVerified = Auth.auth().currentUser?.isEmailVerified {
                    self.isEmailVerified = isEmailVerified
                }
            } while !self.isEmailVerified
            await fetchUser()
            self.currentUser?.flow = AuthenticationFlow.isEmailVerified.rawValue
            if let currentUser = self.currentUser {
                let encodedUser = try Firestore.Encoder().encode(currentUser)
                try await Firestore.firestore().collection("users").document(currentUser.id).setData(encodedUser, merge: true)
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            //            self.userSession = nil
            self.currentUser = nil
            self.flow = .isInitialized
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteAccount() {
        print("pass: DELETE")
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: DiptychUser.self)
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
}


//enum AuthenticationState {
//    case unauthenticated
//    case authenticating
//    case authenticated
//}
//
//enum AuthenticationFlow {
//    case login
//    case signUp
//}
//
//@MainActor
//class AuthenticationViewModel: ObservableObject {
//    @Published var email = ""
//    @Published var password = ""
//    @Published var confirmPassword = ""
//
//    @Published var flow: AuthenticationFlow = .login
//
//    @Published var isEmailVerified = false
//    @Published var isValid  = false
//    @Published var authenticationState: AuthenticationState = .unauthenticated
//    @Published var errorMessage = ""
//    @Published var user: User?
//    @Published var displayName = ""
//
//    init() {
//        registerAuthStateHandler()
//
//        $flow
//            .combineLatest($email, $password, $confirmPassword)
//            .map { flow, email, password, confirmPassword in
//                flow == .login
//                ? !(email.isEmpty || password.isEmpty)
//                : !(email.isEmpty || password.isEmpty || confirmPassword.isEmpty)
//            }
//            .assign(to: &$isValid)
//    }
//
//    private var authStateHandler: AuthStateDidChangeListenerHandle?
//
//    func registerAuthStateHandler() {
//        if authStateHandler == nil {
//            authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
//                self.user = user
//                self.authenticationState = user == nil ? .unauthenticated : .authenticated
//                self.displayName = user?.email ?? ""
//            }
//        }
//    }
//
//    func switchFlow() {
//        flow = flow == .login ? .signUp : .login
//        errorMessage = ""
//    }
//
//    private func wait() async {
//        do {
//            print("Wait")
//            try await Task.sleep(nanoseconds: 1_000_000_000)
//            print("Done")
//        }
//        catch {
//            print(error.localizedDescription)
//        }
//    }
//
//    func reset() {
//        flow = .login
//        email = ""
//        password = ""
//        confirmPassword = ""
//    }
//}
//
//// MARK: - Email and Password Authentication
//
//extension AuthenticationViewModel {
//    func signInWithEmailPassword() async -> Bool {
//        print("func: signInWithEmailPassword")
//        authenticationState = .authenticating
//        do {
//            try await Auth.auth().signIn(withEmail: self.email, password: self.password)
//            return true
//        }
//        catch  {
//            print(error)
//            errorMessage = error.localizedDescription
//            authenticationState = .unauthenticated
//            return false
//        }
//    }
//
//    func signUpWithEmailPassword() async -> Bool {
//        print("func: signUpWithEmailPassword")
//        authenticationState = .authenticating
//        do  {
//            try await Auth.auth().createUser(withEmail: email, password: password)
//            return true
//        }
//        catch {
//            print(error)
//            errorMessage = error.localizedDescription
//            authenticationState = .unauthenticated
//            return false
//        }
//    }
//
//    func createUser(withEmail: email: String){
//        do {
//            let result = try await Auth.auth().createUser(withEmail: <#T##String#>, password: <#T##String#>)
//        }
//    }
//
//    func sendVerificationEmail() async -> Void {
//        print("func: sendVerificationEmail")
//        authenticationState = .authenticating
//        do {
//            try await Auth.auth().currentUser?.sendEmailVerification()
//        }
//        catch {
//            print(error)
//            errorMessage = error.localizedDescription
//        }
//    }
//
//    func checkVerificationByReloading() async {
//        print("func: checkVerificationByReloading")
//        do {
//            repeat {
//                await wait()
//                try await Auth.auth().currentUser?.reload()
//                if let isEmailVerified = Auth.auth().currentUser?.isEmailVerified {
//                    self.isEmailVerified = isEmailVerified
//                }
//            } while !isEmailVerified
//            authenticationState = .authenticated
//        }
//        catch {
//            print(error)
//            errorMessage = error.localizedDescription
//            authenticationState = .unauthenticated
//        }
//    }
//
//    func signOut() {
//        do {
//            try Auth.auth().signOut()
//        }
//        catch {
//            print(error)
//            errorMessage = error.localizedDescription
//        }
//    }
//
//    func deleteAccount() async -> Bool {
//        do {
//            try await user?.delete()
//            return true
//        }
//        catch {
//            errorMessage = error.localizedDescription
//            return false
//        }
//    }
//}
