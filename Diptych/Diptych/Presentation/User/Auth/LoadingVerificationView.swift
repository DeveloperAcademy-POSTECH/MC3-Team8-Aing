//
//  LoadingVerificationView.swift
//  Diptych
//
//  Created by HAN GIBAEK on 2023/07/21.
//

import SwiftUI

struct LoadingVerificationView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        VStack {
            Text("입력하신 이메일로 인증 링크를 보냈습니다.")
                .font(.pretendard(.light, size: 18))
                .foregroundColor(.offBlack)
            Text("인증 완료 후 아래 버튼을 눌러주세요.")
                .font(.pretendard(.light, size: 18))
                .foregroundColor(.offBlack)
            Button {
                Task {
                    await userViewModel.checkEmailVerification3()
                }
            } label: {
                Text("인증 완료")
            }
        }
    }
}

struct LoadingVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingVerificationView()
    }
}
