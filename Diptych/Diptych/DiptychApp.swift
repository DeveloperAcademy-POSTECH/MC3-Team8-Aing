//
//  DiptychApp.swift
//  Diptych
//
//  Created by 김민 on 2023/07/12.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
}

@main
struct DiptychApp: App {

    @State var isSplashCompleted: Bool = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var userViewModel: UserViewModel = UserViewModel()
    @StateObject var archiveViewModel : ArchiveViewModel = ArchiveViewModel()
    
    var body: some Scene {
        WindowGroup {
            if isSplashCompleted {
//                 if userViewModel.flow == .initialized {
//                     OnboardingView()
//                         .environmentObject(userViewModel)
//                 } else if userViewModel.flow == .signedUp {
//                     LoadingVerificationView()
//                         .environmentObject(userViewModel)
//                 } else if userViewModel.flow == .emailVerified {
//                     CouplingView()
//                         .environmentObject(userViewModel)
//                 } else if userViewModel.flow == .coupled {
//                     ProfileSettingView()
//                         .environmentObject(userViewModel)
//                 } else {
//                     DiptychTabView()
// //                        .environmentObject(userViewModel)
// //                        .environmentObject(DiptychCompleteAlertObject())
// //                        .environmentObject(VM)
//                 }
                
                // 댓글 뷰 테스트 - 말풍선 아이콘 버튼 누르면 열림
                PhotoDetailView(currentIndex: 0).environmentObject(archiveViewModel)
                
                // OnBoardingView().environmentObject(userViewModel)
            } else {
                LottieView() { isSplashCompleted in
                    self.isSplashCompleted = true
                }
            }
        }
    }
}
