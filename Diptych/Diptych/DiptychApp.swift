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
    @State var isSplashCompleted: Bool = false
    
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var userViewModel: UserViewModel = UserViewModel()
    @StateObject var VM : ArchiveViewModel = ArchiveViewModel()
    
    
    var body: some Scene {
        WindowGroup {
            

            if isSplashCompleted {
                if userViewModel.flow == .initialized {
                    OnBoardingView()
                        .environmentObject(userViewModel)
                } else if userViewModel.flow == .signedUp {
                    LoadingVerificationView()
                        .environmentObject(userViewModel)
                } else if userViewModel.flow == .emailVerified {
                    CouplingView()
                        .environmentObject(userViewModel)
                } else if userViewModel.flow == .coupled {
                    ProfileSettingView()
                        .environmentObject(userViewModel)
                } else {
                    DiptychTabView2()
                        .environmentObject(userViewModel)
                        .environmentObject(VM)
                }
            } else {
                LottieView() {isSplashCompleted in
                    self.isSplashCompleted = true
                }
            }
            
 
        }
    }
}
