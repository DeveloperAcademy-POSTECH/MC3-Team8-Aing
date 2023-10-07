//
//  DiptychTabView.swift
//  Diptych
//
//  Created by 김민 on 2023/07/12.
//

import SwiftUI

enum DiptychTab: Int, CaseIterable {
    case todyDiptych, archive, profile

    var tabTitle: String {
        switch self {
        case .todyDiptych:
            return "오늘의 딥틱"
        case .archive:
            return "보관함"
        case .profile:
            return "프로필"
        }
    }

    var selectedImage: String {
        switch self {
        case .todyDiptych:
            return "imgTodayDiptychTabSelected"
        case .archive:
            return "imgArchiveTabSelected"
        case .profile:
            return "imgProfileTabSelected"
        }
    }

    var unselectedImage: String {
        switch self {
        case .todyDiptych:
            return "imgTodayDiptychTab"
        case .archive:
            return "imgArchiveTab"
        case .profile:
            return "imgProfileTab"
        }
    }
}

struct DiptychTabView: View {
    @State private var selection = DiptychTab.todyDiptych

    var body: some View {
        TabView(selection: $selection) {
            ForEach(DiptychTab.allCases, id: \.self) { tab in
                diptychTabDestinationView(for: tab)
                    .tabItem {
                        selection == tab ?
                        Image(tab.selectedImage) : Image(tab.unselectedImage)
                        Text(tab.tabTitle)
                    }
            }
        }
        .accentColor(.offBlack)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            UITabBar.appearance().unselectedItemTintColor = .darkGray
            UITabBar.appearance().backgroundColor = .white
        }
    }

    @ViewBuilder
    private func diptychTabDestinationView(for diptychTab: DiptychTab) -> some View {
        switch diptychTab {
        case .todyDiptych:
            TodayDiptychView()
        case .archive:
            ArchiveTabView()
        case .profile:
            ProfileView()
        }
    }
}

struct DiptychTabView_Previews: PreviewProvider {
    static var previews: some View {
        DiptychTabView()
    }
}
