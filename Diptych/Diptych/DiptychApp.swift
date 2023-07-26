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
    @StateObject var todayDiptychViewModel = TodayDiptychViewModel()
    
    var body: some Scene {
        WindowGroup {
            

            if isSplashCompleted {
                if userViewModel.flow == .initialized {
                    OnBoardingView()
                        .environmentObject(userViewModel)
                        .environmentObject(todayDiptychViewModel)
                } else if userViewModel.flow == .signedUp {
                    LoadingVerificationView()
                        .environmentObject(userViewModel)
                } else if userViewModel.flow == .emailVerified {
                    CouplingView()
                        .environmentObject(userViewModel)
                } else if userViewModel.flow == .coupled {
                    ProfileSettingView()
                        .environmentObject(userViewModel)
                        .environmentObject(todayDiptychViewModel)
                } else {
                    DiptychTabView()
                        .environmentObject(userViewModel)
                        .environmentObject(todayDiptychViewModel)
                }
            } else {
                DiptychTabView2()
                    .environmentObject(userViewModel)
            }
            
 
        }
    }
}
