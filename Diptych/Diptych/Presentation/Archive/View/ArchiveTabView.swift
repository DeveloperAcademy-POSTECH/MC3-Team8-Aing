//
//  ArchiveTabView.swift
//  Diptych
//
//  Created by Koo on 2023/07/17.
//

import SwiftUI

struct ArchiveTabView: View {
    
    ///Property
    @State var currentTab : Int = 0
    @Namespace var namespace
    var tabBarOptions: [String] = ["캘린더", "앨범", "질문함"]
    
    var body: some View {
        VStack(spacing: 0){
            
            /// 상단 탭바
            HStack(spacing: 40) {
                ForEach(tabBarOptions.indices, id: \.self) { index in
                    let title = tabBarOptions[index]
                    Button {
                        currentTab = index
                    } label: {
                        TabBarItem(isSelected: currentTab == index,
                                   namespace: namespace,
                                   title: title)
                    }//】 Button
                    .buttonStyle(.plain)
                }//】 Loop
            }//】 HStack
            .padding(.horizontal,30)
            
            Divider()
                .frame(width: 363, height: 1)
            
            
            /// 각 뷰로 이동
            if currentTab == 0 {
                CalendarScrollView()
            } else if currentTab == 1 {
                AlbumNavigationView()
            } else if currentTab == 2 {
               QuestionListView()
            }
               
        }//】 VStack
    }//】 Body
}


struct TabBarItem: View {
    
    ///Property
    var isSelected: Bool
    let namespace: Namespace.ID
    var title: String
    
    var body: some View {
        
            VStack(spacing: 0) {
               
                
                VStack(spacing: 0){
                    /// 탭바 텍스트
                    if isSelected{
                        Text(title)
                            .font(.system(size:24, weight: .light))
                            
                    } else {
                        Text(title)
                            .font(.system(size:24, weight: .light))
                            .foregroundColor(.gray.opacity(0.5))
                    }
                }//】 VStack
                .padding(.top, 30)
                .padding(.bottom,18)
                
                VStack(spacing: 0){
                    /// 탭바 밑줄
                    if isSelected{
                        Color.black
                            .frame(width: 76, height: 2)
                            .matchedGeometryEffect(id: "underline", in: namespace) //→애니메이션
                    } else {
                        Color.clear.frame(width: 76, height: 2)
                    }
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
