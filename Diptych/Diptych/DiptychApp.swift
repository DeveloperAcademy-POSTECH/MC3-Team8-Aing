//
//  DiptychApp.swift
//  Diptych
//
//  Created by 김민 on 2023/07/12.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct DiptychApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authViewModel: AuthenticationViewModel = AuthenticationViewModel()
    @StateObject var userViewModel: UserViewModel = UserViewModel()
    
    var body: some Scene {
        WindowGroup {
            //            DiptychTabView()
//            TestView()
            switch authViewModel.flow {
            case .isInitialized :
                OnBoardingView()
                    .environmentObject(authViewModel)
                    .environmentObject(userViewModel)
            case .isSignedUp :
                EmailVerificationView()
                    .environmentObject(authViewModel)
                    .environmentObject(userViewModel)
            case .isEmailVerified:
                CouplingView()
                    .environmentObject(authViewModel)
                    .environmentObject(userViewModel)
            default:
                DiptychTabView()
            }
        }
    }
}
