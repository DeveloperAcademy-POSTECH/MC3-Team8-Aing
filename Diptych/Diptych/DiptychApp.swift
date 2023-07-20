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
    
    var body: some Scene {
        WindowGroup {
//                        DiptychTabView()
            
            switch authViewModel.flow {
            case .isInitialized :
                OnBoardingView()
                    .environmentObject(authViewModel)
            case .isSignedUp :
                EmailVerificationView()
                    .environmentObject(authViewModel)
            case .isEmailVerified:
                CouplingView()
                    .environmentObject(authViewModel)
            default:
                DiptychTabView()
            }
        }
    }
}
