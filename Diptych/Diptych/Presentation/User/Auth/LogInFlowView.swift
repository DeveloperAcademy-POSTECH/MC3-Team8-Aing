//
//  LogInFlowView.swift
//  Diptych
//
//  Created by HAN GIBAEK on 2023/07/21.
//

import SwiftUI

struct LogInFlowView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    var body: some View {
        if userViewModel.flow == .initialized {
            LogInView()
        } else if userViewModel.flow == .signedUp {
            LoadingVerificationView()
        } else if userViewModel.flow == .emailVerified {
            CouplingView()
        } else if userViewModel.flow == .coupled {
            ProfileSettingView()
        }
    }
}

struct LogInFlowView_Previews: PreviewProvider {
    static var previews: some View {
        LogInFlowView()
    }
}
