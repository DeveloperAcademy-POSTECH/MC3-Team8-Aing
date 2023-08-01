//
//  DiptychCompleteAlertView.swift
//  Diptych
//
//  Created by 김민 on 2023/08/01.
//

import SwiftUI

struct DiptychCompleteAlertView: View {
    @Binding var isDiptychCompleteAlertShown: Bool

    var body: some View {
        ZStack {
            Color.offWhite
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Image("icnXMark")
                        .onTapGesture {
                            isDiptychCompleteAlertShown = true
                        }
                    Spacer()
                }
                .padding(.top, 15)
                .padding(.leading, 15)

                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.systemSalmon)
                    .frame(width: 44, height: 44)
                    .overlay {
                        Image("icnCheck")
                    }
                    .padding(.top, 28)

                Text("오늘 딥틱 완성!")
                    .font(.pretendard(.light, size: 24))
                    .padding(.top, 34)
                Text("오늘의 딥틱이 완성되었어요\n확인해보세요")
                    .lineSpacing(3)
                    .font(.pretendard(.light, size: 16))
                    .foregroundColor(.darkGray)
                    .multilineTextAlignment(.center)
                    .padding(.top, 9)

                Button {
                    isDiptychCompleteAlertShown = true
                } label: {
                    Text("확인하기")
                        .font(.pretendard(.light, size: 20))
                        .foregroundColor(.offWhite)
                        .padding(.horizontal, 100)
                        .padding(.vertical, 16)
                        .frame(height: 60)
                        .background(Color.offBlack)
                }
                .padding(.top, 57)
                .padding(.bottom, 15)
            }
        }
    }
}

struct DiptychCompleteAlertView_Previews: PreviewProvider {
    static var previews: some View {
        DiptychCompleteAlertView(isDiptychCompleteAlertShown: .constant(false))
            .frame(width: 300, height: 360)
    }
}
