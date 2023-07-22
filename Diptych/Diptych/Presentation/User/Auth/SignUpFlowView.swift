//
//  SignUpFlowView.swift
//  Diptych
//
//  Created by HAN GIBAEK on 2023/07/21.
//

import SwiftUI

struct SignUpFlowView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    var body: some View {
        if userViewModel.flow == .initialized {
            SignUpView()
        } else if userViewModel.flow == .signedUp {
            LoadingVerificationView()
        } else if userViewModel.flow == .emailVerified {
            CouplingView()
        } else if userViewModel.flow == .coupled {
            ProfileSettingView()
        }
    }
}

struct SignUpFlowView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpFlowView()
            .environmentObject(UserViewModel())
    }
}
