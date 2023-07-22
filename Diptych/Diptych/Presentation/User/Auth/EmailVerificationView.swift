//
//  EmailVerificationView.swift
//  Diptych
//
//  Created by HAN GIBAEK on 2023/07/17.
//

import SwiftUI

struct EmailVerificationView: View {
    @EnvironmentObject var userViewModel: UserViewModel
//    @EnvironmentObject var authViewModel: AuthenticationViewModel
    var body: some View {
        if userViewModel.flow == .emailVerified {
            CouplingView()
        } else {
            VStack {
                Text("입력하신 이메일로 인증 링크를 보냈습니다.")
                    .font(.pretendard(.light, size: 18))
                    .foregroundColor(.offBlack)
                Text("링크 클릭 후 앱으로 돌아와 주세요.")
                    .font(.pretendard(.light, size: 18))
                    .foregroundColor(.offBlack)
            }
        }
    }
}

struct EmailVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        EmailVerificationView()
            .environmentObject(AuthenticationViewModel())
    }
}
