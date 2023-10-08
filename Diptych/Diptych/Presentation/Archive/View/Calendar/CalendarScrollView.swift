//
//  CalendarScrollView.swift
//  Diptych
//
//  Created by Koo on 2023/07/17.
//

import SwiftUI

struct CalendarScrollView: View {
    @EnvironmentObject var archiveViewModel: ArchiveViewModel
    let scrollToID = 12 // 스크롤뷰 시작 위치 지정

    var body: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    ForEach(0...scrollToID, id: \.self) { index in
                        CalendarView(date: Date.now,
                                     changeMonthInt: index - scrollToID)
                                .environmentObject(archiveViewModel)
                    }
                    Text("달력의 끝입니다.")
                        .foregroundColor(.offWhite)
                        .font(.pretendard(size: 10))
                        .frame(height: 30)
                        .id("bottom")
                }
                .padding(.bottom, 40)
                .background(Color.offWhite)
                .onAppear{
                    var timerCount = 0
                    // TODO: 자동 스크롤 로직 바꾸기
                    /*
                     Timer가 들어간 이유:
                     LazyVGrid로 인해 스크롤이 되어야만 사이즈가 정확하게 계산되기 때문에
                     처음에 한 번만 scrollTo를 하면 제 위치에 안들어감.
                     짧은 시간에 5~6번을 새로고침해서 스크롤한 뒤 모든 부분이 로딩되면 제 위치로 스크롤됨.
                     전혀 바람직한 코드가 아니며 (1)LazyVGrid와 (2)역방향이 최신인 컨텐츠를 고려한 다른 스크롤 방법을 전면적으로 생각해야됨.
                     */
                    Timer.scheduledTimer(withTimeInterval: 0.025, repeats: true) { timer in
                        if timerCount <= 5 {
                            scrollViewProxy.scrollTo(scrollToID, anchor: .bottom)
                            timerCount += 1
                        } else {
                            scrollViewProxy.scrollTo("bottom", anchor: .bottom)
                            timer.invalidate()
                        }
                    }
                }
                .padding(.bottom, 15)
            }
        }
    }
}



// MARK: - Previews
struct CalendarScrollView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarScrollView()
            .environmentObject(ArchiveViewModel())
    }
}

