//
//  CellView.swift
//  Diptych
//
//  Created by Koo on 2023/07/24.
//

import SwiftUI

struct CellView: View {
    
    ///Property
    @StateObject var VM = AlbumViewModel()
    @State var day: Int
    @State var isToday: Bool
    
    
    let imageUrl1 : String = "gs://diptych.appspot.com/cat1.jpeg"
    let imageUrl2 : String = "gs://diptych.appspot.com/cat1.jpeg"
    
    
    var body: some View {

        ZStack{
            
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.systemSalmon, lineWidth: isToday ? 2 : 0)
                .frame(width: 44, height: 50)

            /// 캘린더의 날짜가 document의 날짜와 일치 한다면
            if !VM.startDay.isEmpty && !VM.photos.isEmpty &&
                day - VM.startDay[0].day >= 0 &&
                day == VM.photos[day - VM.startDay[0].day].day{

                    /// 썸네일 완성시
                    if !VM.startDay.isEmpty && !VM.photos.isEmpty &&
                        day - VM.startDay[0].day >= 0 &&
                        VM.photos[day - VM.startDay[0].day].isCompleted == true{
                            NavigationLink {
                                PhotoDetailView(
                                    date: "2023년 7월 30일", questionNum: 20,
                                    question: "\"상대방의 표정 중 당신이\n 가장 좋아하는 표정은?\"",
                                    imageUrl1: imageUrl1, imageUrl2: imageUrl2)
                            } label: {
                                RoundedRectangle(cornerRadius: 18)
                                    .fill( isToday ? Color.systemSalmon : Color.lightGray)
                                    .frame(width: 44, height: 50)
                            }//】 Navigation
                    }
                    /// 썸네일 미완성시
                    else{
                        EmptyView()
                    }
            }
            /// 캘린더의 날짜가 document의 날짜에 없을 때
            else {
                EmptyView()
            }

            Text("\(day)")
                .font(.pretendard(.bold, size: 16))
                .foregroundColor(.offBlack)
                .offset(y: -10)
            
        }//】 ZStack
        .padding(.bottom, 19)
        .onAppear{
            if !VM.startDay.isEmpty {
            }
        }
       
        
    }//】 Body
}


struct CellView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            CellView(VM: AlbumViewModel(), day: 24, isToday: true)
            CellView(VM: AlbumViewModel(), day: 22, isToday: false)
        }
    }
}
