//
//  UserViewModel.swift
//  Diptych
//
//  Created by HAN GIBAEK on 2023/07/20.
//

import Foundation

class UserViewModel: ObservableObject {
    @Published var isLogInLinkActive = false
    @Published var isSignUpLinkActive = false
    @Published var isEmailVerificationLinkActive = false
    @Published var isProfileSettingLinkActive = false
}
