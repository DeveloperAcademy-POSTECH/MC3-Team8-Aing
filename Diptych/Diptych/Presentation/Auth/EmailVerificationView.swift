//
//  EmailVerificationView.swift
//  Diptych
//
//  Created by HAN GIBAEK on 2023/07/17.
//

import SwiftUI

struct EmailVerificationView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    var body: some View {
        if authViewModel.authenticationState == .authenticated {
            Text("인증 완료")
            NavigationLink(destination: CouplingView().environmentObject(authViewModel)) {
                Text("커플 연결하기")
            }
        } else {
            Text("잠시만 기다려주세요. 인증 중입니다.")
        }
    }
}

struct EmailVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        EmailVerificationView()
            .environmentObject(AuthenticationViewModel())
    }
}
