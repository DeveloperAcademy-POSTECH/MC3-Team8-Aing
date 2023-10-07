//
//  ArchiveTabView.swift
//  Diptych
//
//  Created by Koo on 2023/07/17.
//

import SwiftUI

enum ArchiveTabInfo: String, CaseIterable {
    case calendar = "캘린더"
    case album = "앨범"
    case questions = "질문함"
}

struct ArchiveTabView: View {

    @State private var selection = ArchiveTabInfo.calendar

    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                archiveTabView
                Divider()
                    .overlay(Color.dtLightGray)
            }
            .padding(.top, 15)
            archiveTabDestinationView(for: selection)
            Spacer()
        }
        .background(Color.offWhite)
    }
}

// MARK: - UI Components

extension ArchiveTabView {

    var archiveTabView: some View {
        HStack(spacing: 0) {
            ForEach(ArchiveTabInfo.allCases, id: \.self) { tab in
                Spacer()
                VStack(spacing: 15) {
                    Text(tab.rawValue)
                        .font(.pretendard(.light, size: 20))
                        .foregroundColor(selection == tab ? .offBlack : .dtDarkGray)
                    Rectangle()
                        .foregroundColor(selection == tab ? .offBlack : .offWhite)
                        .frame(width: 76, height: selection == tab ? 2 : 0)
                }
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        selection = tab
                    }
                }
                Spacer()
            }
        }
    }

    @ViewBuilder
    private func archiveTabDestinationView(for archiveTab: ArchiveTabInfo) -> some View {
        switch archiveTab {
        case .calendar:
            Text("Calendar")
        case .album:
            Text("Album")
        case .questions:
            Text("Questions")
        }
    }
}

struct ArchiveTabView_Previews: PreviewProvider {
    static var previews: some View {
        DiptychTabView()
    }
}
