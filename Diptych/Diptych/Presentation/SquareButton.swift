//
//  SquareButton.swift
//  Diptych
//
//  Created by 김민 on 2023/10/01.
//

import SwiftUI

struct SquareButton: View {
    @State var buttonTitle = ""
    @State var buttonBackgroundColor = Color.offBlack
    @State var titleColor = Color.dtLightGray

    var body: some View {
        Text(buttonTitle)
            .font(.pretendard(.light, size: 20))
            .foregroundColor(titleColor)
            .padding(.vertical, 16)
            .padding(.horizontal, 15)
            .frame(maxWidth: .infinity)
            .background(buttonBackgroundColor)
    }
}

struct SquareButton_Previews: PreviewProvider {
    static var previews: some View {
        SquareButton(buttonTitle: "로그인하기", buttonBackgroundColor: .offBlack)
    }
}
