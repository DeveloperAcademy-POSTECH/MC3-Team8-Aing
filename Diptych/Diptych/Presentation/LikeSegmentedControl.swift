//
//  LIkeSegmentedControl.swift
//  Diptych
//
//  Created by 김민 on 2023/10/08.
//

import SwiftUI

enum LikeFilter: String, CaseIterable {
    case all = "전체"
    case like = "좋아요"
}

struct LikeSegmentedControl: View {
    @Binding var selection: LikeFilter

    var body: some View {
        HStack(spacing: 0) {
            ForEach(LikeFilter.allCases, id: \.self) { filter in
                ZStack {
                    Rectangle()
                        .foregroundColor(selection == filter ? Color.offBlack : Color.clear)
                    Text(filter.rawValue)
                        .font(.pretendard(.medium, size: 16))
                        .foregroundColor(selection == filter ? .offWhite : .dtDarkGray)
                }
                .onTapGesture {
                    withAnimation(.easeOut) {
                        selection = filter
                    }
                }
            }
        }
        .frame(height: 33)
        .border(Color.dtDarkGray)
    }
}

struct LikeSegmentedControl_Previews: PreviewProvider {
    static var previews: some View {
        LikeSegmentedControl(selection: .constant(.all))
    }
}
