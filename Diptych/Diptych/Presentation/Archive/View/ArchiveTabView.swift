//
//  ArchiveTabView.swift
//  Diptych
//
//  Created by Koo on 2023/07/17.
//

import SwiftUI

struct ArchiveTabView: View {
    
    ////Property
    @State private var selection: Int = 0
    
    var body: some View {
        ///탭뷰로 구현
        TabView(selection: $selection) {

            ///[1] 캘린더 스크롤 뷰
            CalendarScrollView()
                .tabItem{ Text("캘린더") .font(.largeTitle)}
                .tag(0)

            ///[2] 앨범 뷰
            AlbumNavigationView()
                .tabItem { Text("앨범") .font(.largeTitle)}
                .tag(0)

            ///[3] 질문 보관함 뷰

        }// TabView
    }
}

struct ArchiveTabView_Previews: PreviewProvider {
    static var previews: some View {
        ArchiveTabView()
    }
}
