//
//  ArchiveTabView.swift
//  Diptych
//
//  Created by Koo on 2023/07/17.
//

import SwiftUI

struct ArchiveTabView: View {
    
    ///Property
    @EnvironmentObject var VM : ArchiveViewModel
    @State var currentTab : Int = 0
    @Namespace var namespace
    var tabBarOptions: [String] = ["캘린더", "앨범"] //"질문함"
    
    var body: some View {
        NavigationView{
        VStack(spacing: 0){
                /// 상단 탭바
                HStack(spacing: 70) {
                    ForEach(tabBarOptions.indices, id: \.self) { index in
                        let title = tabBarOptions[index]
                        Button {
                            currentTab = index
                        } label: {
                            ArchiveTabBarItem(isSelected: currentTab == index,
                                       namespace: namespace,
                                       title: title)
                        }//】 Button
                        .buttonStyle(.plain)
                    }//】 Loop
                }//】 HStack
                .frame(maxWidth: .infinity)
                .padding(.horizontal,30)
                .background(Color.offWhite)
                
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: 1.5)
                    .foregroundColor(.lightGray)

                
                /// 각 뷰로 이동
                if currentTab == 0 {
                    CalendarScrollView()
                        .environmentObject(VM)
                } else if currentTab == 1 {
                    AlbumListView()
                        .environmentObject(VM)
                }
//                else if currentTab == 2 {
//                    QuestionListView()
//                        .environmentObject(VM)
//                }
        }//】 VStack
        }//】 Navigation
    }//】 Body
}


struct ArchiveTabBarItem: View {
    
    ///Property
    var isSelected: Bool
    let namespace: Namespace.ID
    var title: String
    
    var body: some View {
        
            VStack(spacing: 0) {
               
                    /// 탭바 텍스트
                    Text(title)
                        .font(.system(size:24, weight: .light))
                        .foregroundColor(isSelected ? .offBlack : .offBlack.opacity(0.8))
                        .padding(.top, 30)
                        .padding(.bottom,18)
                
                    /// 탭바 밑줄
                    if isSelected{
                        Color.black
                            .frame(width: 76, height: 2)
                            .matchedGeometryEffect(id: "underline", in: namespace) //→애니메이션
                    } else {
                        Color.clear
                            .frame(width: 76, height: 2)
                    }
                
            }//】 VStack
            .animation(.spring(), value: isSelected) // 애니메이션 타입
    }//】 Body
}



struct ArchiveTabView_Previews: PreviewProvider {
    static var previews: some View {
        ArchiveTabView()
    }
}
