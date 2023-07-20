//
//  ProfileView.swift
//  Diptych
//
//  Created by 김민 on 2023/07/13.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        ZStack {
            Color.offWhite.edgesIgnoringSafeArea(.top)
            
            VStack {
                
                HStack(spacing: 0) {
                    Image("heart")
                        .frame(width: 24, height: 24)
                        .padding(.horizontal, 60)
                } // HStack
                
                Divider()
                    .padding(.top, 80) // 임의로 조정했음
                    .padding(.bottom, 103)

                Text("D+233")
                    .font(.pretendard(.light, size: 28))
                    .foregroundColor(.offBlack)
                    .padding(.bottom, 30)

                Text("99번째 딥틱 중")
                    .font(.pretendard(.light, size: 28))
                    .foregroundColor(.offBlack)
                    .padding(.bottom, 179)

                Text("버전 정보 1.0.0.0")
                    .font(.pretendard(.light, size: 18))
                    .foregroundColor(.darkGray)
                    .padding(.bottom, 22)

                Text("개인정보처리방침")
                    .font(.pretendard(.light, size: 18))
                    .foregroundColor(.darkGray)
                
            } // VStack
            
            
            
            
        } // ZStack
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
