//
//  CalendarScrollView.swift
//  Diptych
//
//  Created by Koo on 2023/07/17.
//

import SwiftUI

struct CalendarScrollView: View {
    
    @EnvironmentObject var VM : ArchiveViewModel
    let scrollToID = 5 // 스크롤뷰 시작 위치 지정
    
    var body: some View {
            ScrollViewReader { scrollViewProxy in
                
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        ForEach(0...scrollToID, id:\.self) { index in
                            CalendarView(date: Date.now, changeMonthInt: index - scrollToID)
                                .environmentObject(VM)
                        }
                    }
                    .padding(.bottom, 40)
                }//】 Scroll
                .background(Color.offWhite)
                .onAppear{
                    scrollViewProxy.scrollTo(scrollToID, anchor: .bottom)
                }
                .padding(.bottom, 15)
            }//】 ScrollViewReader

    }//】 Body
}



// MARK: - Previews
struct CalendarScrollView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarScrollView()
    }
}

