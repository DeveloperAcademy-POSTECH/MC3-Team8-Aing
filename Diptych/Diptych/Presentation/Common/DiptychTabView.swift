//
//  DiptychTabView.swift
//  Diptych
//
//  Created by 김민 on 2023/07/12.
//

import SwiftUI

struct DiptychTabView: View {
    @State private var selection = 0

    var body: some View {
        TabView(selection: $selection) {
            
            ///[1] 홈
            TodayDiptychView()
                .tabItem {
                    selection == 0 ? Image("imgTodayDiptychTabSelected") : Image("imgTodayDiptychTab")
                    Text("오늘의 딥틱")
                }
                .tag(0)
            
            ///[2] 아카이브
            ArchiveTabView(currentTab: selection)
                .tabItem {
                    selection == 1 ? Image("imgArchiveTabSelected") : Image("imgArchiveTab")
                    Text("보관함")
                }
                .tag(1)

            ///[3] 프로필
            ProfileView()
                .tabItem {
                    selection == 2 ? Image("imgProfileTabSelected") : Image("imgProfileTab")
                    Text("프로필")
                }
                .tag(2)
        }// TabView
        .tint(.black)
        .background(Color.white)
        .onAppear {
            UITabBar.appearance().unselectedItemTintColor = .darkGray
        }
    }
}



struct DiptychTabView_Previews: PreviewProvider {
    static var previews: some View {
        DiptychTabView()
    }
}
