//
//  WeeklyCalenderView.swift
//  Diptych
//
//  Created by 김민 on 2023/07/13.
//

import SwiftUI

struct WeeklyCalenderView: View {
    @State var day: String

    var body: some View {
        VStack(spacing: 9) {
            Text(day)
                .font(.pretendard(.medium, size: 14))

            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.clear)
                    .frame(width: 44, height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.salmon, lineWidth: 2))

                Text("07")
                    .font(.pretendard(.bold, size: 16))
                    .foregroundColor(.offBlack)
                    .padding(.top, 7)
            }
        }
    }
}

struct WeeklyCalenderView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyCalenderView(day: "월")
    }
}
