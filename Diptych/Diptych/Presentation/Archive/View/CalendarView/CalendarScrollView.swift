//
//  CalendarScrollView.swift
//  Diptych
//
//  Created by Koo on 2023/07/17.
//

import SwiftUI

struct CalendarScrollView: View {
    
    let scrollToID = 1 // 스크롤뷰 시작 위치 지정
    
    var body: some View {
        
            ScrollViewReader { scrollViewProxy in
                
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        ForEach(0...1, id:\.self) { index in
                            CalendarView(date: Date.now, changeMonthInt: index-1)
                        }
                    }
                    .padding(.bottom,40)
                }//】 Scroll
                .background(Color.gray.opacity(0.1))
                .onAppear{
                    scrollViewProxy.scrollTo(scrollToID, anchor: .bottom)
                }
            }//】 ScrollViewReader

    }//】 Body
}



// MARK: - Previews
struct CalendarScrollView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarScrollView()
    }
}

