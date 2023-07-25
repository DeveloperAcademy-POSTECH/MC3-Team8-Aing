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
            
            CalendarView(date: Date(), changeMonthInt: 0)

            /// 잠시 주석 처리
//            if userViewModel.flow == .initialized {
//                OnBoardingView()
//                    .environmentObject(userViewModel)
//            } else if userViewModel.flow == .signedUp {
//                LoadingVerificationView()
//                    .environmentObject(userViewModel)
//            } else if userViewModel.flow == .emailVerified {
//                CouplingView()
//                    .environmentObject(userViewModel)
//            } else if userViewModel.flow == .coupled {
//                ProfileSettingView()
//                    .environmentObject(userViewModel)
//            } else {
//                DiptychTabView2()
//                    .environmentObject(userViewModel)
//            }
            
            
//            if userViewModel.flow == .initialized {
//                OnBoardingView()
//                    .environmentObject(userViewModel)
//            } else if userViewModel.flow == .signedUp {
//                LoadingVerificationView()
//                    .environmentObject(userViewModel)
//            } else if userViewModel.flow == .emailVerified {
//                CouplingView()
//                    .environmentObject(userViewModel)
//            } else if userViewModel.flow == .coupled {
//                ProfileSettingView()
//                    .environmentObject(userViewModel)
//            } else {
//                DiptychTabView()
//                    .environmentObject(userViewModel)
//            }
            
            /// 원래 주석이었던것
//            if userViewModel.flow == .completed {
//                DiptychTabView()
//            } else {
//                OnBoardingView()
//                    .environmentObject(userViewModel)
//            }
            
//            switch userViewModel.flow {
//            case .initialized :
//                OnBoardingView()
////                    .environmentObject(authViewModel)
//                    .environmentObject(userViewModel)
//            case .emailVerified :
//                SignUpView()
////                    .environmentObject(authViewModel)
//                    .environmentObject(userViewModel)
//            case .emailVerified:
//                CouplingView()
////                    .environmentObject(authViewModel)
//                    .environmentObject(userViewModel)

//            switch authViewModel.flow {
//            case .isInitialized :
//                OnBoardingView()
//                    .environmentObject(authViewModel)
//            case .isSignedUp :
//                EmailVerificationView()
//                    .environmentObject(authViewModel)
//            case .isEmailVerified:
//                CouplingView()
//                    .environmentObject(authViewModel)

//            default:
//                DiptychTabView()
//            }
        }
    }
}
