//
//  DiptychTabView2.swift
//  Diptych
//
//  Created by Koo on 2023/07/20.
//

import SwiftUI

struct DiptychTabView2: View {
    ///Property
    @EnvironmentObject var VM : ArchiveViewModel
    @State var currentTab : Int = 0
    @Namespace var namespace
    @EnvironmentObject var diptychCompleteAlertObject: DiptychCompleteAlertObject
    var tabBarTitle: [String] = ["오늘의 딥틱", "보관함", "프로필"]
    var selectedIcons: [String] = ["imgTodayDiptychTabSelected", "imgArchiveTabSelected", "imgProfileTabSelected"]
    var UnselectedIcons: [String] = ["imgTodayDiptychTab", "imgArchiveTab", "imgProfileTab"]
    
    var body: some View {
        NavigationView{
            ZStack{
                /// 각 뷰로 이동
                VStack(spacing: 0){
                    if currentTab == 0 {
                        TodayDiptychView()
                    }
                    else if currentTab == 1 {
                        ArchiveTabView(currentTab: 0)
                            .environmentObject(VM)
                    }
                    else if currentTab == 2 {
                        ProfileView()
                    }
                }//】 VStack
                .frame(maxWidth: .infinity)
                
                
                Spacer()
                
                /// 하단 탭바
                VStack{
                    Spacer()
                    HStack(spacing: 20) {
                        ForEach(tabBarTitle.indices, id: \.self) { index in
                            let title = tabBarTitle[index]
                            let icon1 = selectedIcons[index]
                            let icon2 = UnselectedIcons[index]
                            
                            Button {
                                currentTab = index
                            } label: {
                                DiptychTabBarItem(isSelected: currentTab == index, title: title,
                                                  selectedIcon: icon1, UnselectedIcon: icon2)
                            }//】 Button
                            .buttonStyle(.plain)
                        }//】 Loop
                    }//】 HStack
                    .frame(height: 100)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                }//】 VStack

                if !diptychCompleteAlertObject.isDiptychCompleteAlertShown && diptychCompleteAlertObject.isDiptychCompleted {
                    Color.black.opacity(0.54)
                    DiptychCompleteAlertView()
                        .frame(width: 300, height: 360)
                }
                
            }//】 ZStack
            .ignoresSafeArea()
        }//】 Navigation
        .accentColor(Color.offBlack)

    }//】 Body
}


struct DiptychTabBarItem: View {
    
    ///Property
    var isSelected: Bool
    var title: String
    var selectedIcon: String
    var UnselectedIcon: String
    
    var body: some View {
        
            VStack(spacing: 0) {
               
                /// 탭바 아이콘
                VStack(spacing: 0) {
                    if isSelected{
                        Image(selectedIcon)
                    } else {
                        Image(UnselectedIcon)
                            .opacity(0.5)
                    }
                    
                }//】 VStack
                .padding(.bottom,5)
                
                /// 탭바 텍스트
                VStack(spacing: 0){
                    if isSelected{
                        Text(title)
                            .font(.system(size:12, weight: .medium))
                            
                    } else {
                        Text(title)
                            .font(.system(size:12, weight: .medium))
                            .foregroundColor(.gray.opacity(0.5))
                    }
                }//】 VStack
               
                
            }//】 VStack
            .frame(width: 100)
            .offset(y:-7)
            .animation(.spring(), value: isSelected) // 애니메이션 타입
    }//】 Body
}


struct DiptychTabView2_Previews: PreviewProvider {
    static var previews: some View {
        DiptychTabView2()
            .environmentObject(DiptychCompleteAlertObject())
    }
}
