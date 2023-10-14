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
        NavigationView {
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
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

// MARK: - UI Components

extension ArchiveTabView {

    var archiveTabView: some View {
        HStack(spacing: 37) {
            ForEach(ArchiveTabInfo.allCases, id: \.self) { tab in
                VStack(spacing: 15) {
                    Text(tab.rawValue)
                        .font(.pretendard(.light, size: 24))
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
            }
        }
        .background(Color.offWhite)
    }

    @ViewBuilder
    private func archiveTabDestinationView(for archiveTab: ArchiveTabInfo) -> some View {
        switch archiveTab {
        case .calendar:
            Text("Calendar")
        case .album:
            AlbumListView()
        case .questions:
            QuestionListView()
        }
    }
}

struct ArchiveTabView_Previews: PreviewProvider {
    static var previews: some View {
        DiptychTabView()
    }
}
