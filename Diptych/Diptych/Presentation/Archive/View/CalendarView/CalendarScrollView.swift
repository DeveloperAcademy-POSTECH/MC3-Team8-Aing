//
//  CalendarScrollView.swift
//  Diptych
//
//  Created by Koo on 2023/07/17.
//

import SwiftUI

struct CalendarScrollView: View {
    
    let scrollToID = 11 // 스크롤뷰 시작 위치 지정
    
    var body: some View {
        
//        NavigationView{
            ScrollViewReader { scrollViewProxy in
                
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        ForEach(0...11, id:\.self) { index in
                            CalendarView(date: Date.now, changeMonthInt: index-11)
                        }
                    }
                    .background(Color.gray.opacity(0.1))
                }//】 Scroll
                .onAppear{
                    scrollViewProxy.scrollTo(scrollToID, anchor: .bottom)
                }
            }//】 ScrollViewReader
//        }//】 Navigation
    }//】 Body
}



// MARK: - Previews
struct CalendarScrollView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarScrollView()
    }
}

