//
//  DiptychApp.swift
//  Diptych
//
//  Created by 김민 on 2023/07/12.
//

import SwiftUI
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // if let path = Bundle.main.path(forResource: "GoogleService-Info-2", ofType: "plist") {
        //     guard let options = FirebaseOptions(contentsOfFile: path) else { return false }
        //     FirebaseApp.configure(options: options)
        // }
       FirebaseApp.configure()
        return true
    }
}

@main
struct DiptychApp: App {

    @State var isSplashCompleted: Bool = false
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
                    DiptychTabView()
                        .environmentObject(userViewModel)
                        .environmentObject(DiptychCompleteAlertObject())
                        .environmentObject(VM)
                }
                
                // OnBoardingView().environmentObject(userViewModel)
            } else {
                LottieView() { isSplashCompleted in
                    self.isSplashCompleted = true
                }
            }
        }
    }
}
