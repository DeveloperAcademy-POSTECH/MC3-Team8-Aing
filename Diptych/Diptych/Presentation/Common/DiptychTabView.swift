//
//  DiptychTabView.swift
//  Diptych
//
//  Created by 김민 on 2023/07/12.
//

import SwiftUI

struct DiptychTabView: View {
    
    @State private var selection = 0
    @EnvironmentObject var userViewModel: UserViewModel

    var body: some View {
        TabView(selection: $selection) {
            TodayDiptychView()
                .tabItem {
                    selection == 0 ? Image("imgTodayDiptychTabSelected") : Image("imgTodayDiptychTab")
                    Text("오늘의 딥틱")
                }
                .tag(0)

            ArchiveTabView(currentTab: selection)
                .tabItem {
                    selection == 1 ? Image("imgArchiveTabSelected") : Image("imgArchiveTab")
                    Text("보관함")
                }
                .tag(1)

            ProfileView()
                .tabItem {
                    selection == 2 ? Image("imgProfileTabSelected") : Image("imgProfileTab")
                    Text("프로필")
                }
                .tag(2)
        }
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
            .environmentObject(UserViewModel())
    }
}
