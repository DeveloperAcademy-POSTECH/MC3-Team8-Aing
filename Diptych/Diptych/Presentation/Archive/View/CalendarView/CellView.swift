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
    @State var daySubscript: Int = 0
    
    
    let imageUrl1 : String = "https://file.notion.so/f/s/1ed8775d-60cc-4907-b8f2-edf0acfb484f/%E1%84%89%E1%85%A6%E1%84%85%E1%85%A9_3_copy_5_%E1%84%87%E1%85%A9%E1%86%A8%E1%84%89%E1%85%A1%E1%84%87%E1%85%A9%E1%86%AB_2.jpg?id=8dc957fa-bf1e-4daf-a72a-6be8e69213d6&table=block&spaceId=794074b4-a62e-40a9-9a73-2dc5a7035226&expirationTimestamp=1689933600000&signature=-ZApnHNSBN05IfP5KQJWDd_MUXwXBrAUPvTwjjdI-40&downloadName=%E1%84%89%E1%85%A6%E1%84%85%E1%85%A9+3+copy+5+%E1%84%87%E1%85%A9%E1%86%A8%E1%84%89%E1%85%A1%E1%84%87%E1%85%A9%E1%86%AB+2.jpg"
     
    let imageUrl2 : String = "https://file.notion.so/f/s/19b32819-43e4-446d-bcb8-917b17cfe2cd/%E1%84%89%E1%85%A6%E1%84%85%E1%85%A9_3_copy_5_%E1%84%87%E1%85%A9%E1%86%A8%E1%84%89%E1%85%A1%E1%84%87%E1%85%A9%E1%86%AB.jpg?id=7fddf6e5-976e-4ed6-af14-be1ff9662108&table=block&spaceId=794074b4-a62e-40a9-9a73-2dc5a7035226&expirationTimestamp=1689933600000&signature=QECxg7nvN5ew0ajmMq5oCJmCV0SqyR7e7n8SwOAI804&downloadName=%E1%84%89%E1%85%A6%E1%84%85%E1%85%A9+3+copy+5+%E1%84%87%E1%85%A9%E1%86%A8%E1%84%89%E1%85%A1%E1%84%87%E1%85%A9%E1%86%AB.jpg"
    
    
    var body: some View {

        ZStack{
            Text("\(VM.startDay[0].day)")
            
//            RoundedRectangle(cornerRadius: 18)
//                .stroke(Color.systemSalmon, lineWidth: isToday ? 2 : 0)
//                .frame(width: 44, height: 50)
//
//            /// document의 날짜가 캘린더 날짜와 일치 한다면
//            if day == VM.photos[day - VM.startDay[0].day < 0 ? 0 : day - VM.startDay[0].day].day{
//
//                /// 썸네일 완성
//                if VM.photos[day - VM.startDay[0].day < 0 ? 0 : day - VM.startDay[0].day].isCompleted{
//                    NavigationLink {
//                        PhotoDetailView(
//                            date: "2023년 7월 30일", questionNum: 20,
//                            question: "\"상대방의 표정 중 당신이\n 가장 좋아하는 표정은?\"",
//                            imageUrl1: imageUrl1, imageUrl2: imageUrl2)
//                    } label: {
//                        RoundedRectangle(cornerRadius: 18)
//                            .fill( isToday ? Color.systemSalmon : Color.lightGray)
//                    }//】 Navigation
//                }
//                /// 썸네일 미완성
//                else{
//                    EmptyView()
//                }
//            }
//            else {
//                EmptyView()
//            }
//
//            Text("\(day)")
//                .font(.pretendard(.bold, size: 16))
//                .foregroundColor(.offBlack)
//                .offset(y: -10)
            
        }//】 ZStack
        .padding(.bottom, 19)
        .onAppear {
//            daySubscript = day - VM.startDay[0].day < 0 ? 0 : day - VM.startDay[0].day
            print(VM.startDay, VM.photos)
            print(daySubscript)
        }
        
    }//】 Body
}

//
//struct ImageView: View {
//    @StateObject private var imageLoader: ImageLoader
//    private let imageURL: String
//
//    init(imageURL: String) {
//        self.imageURL = imageURL
//        _imageLoader = StateObject(wrappedValue: ImageLoader(imageURL: imageURL))
//    }
//
//    var body: some View {
//        if let image = imageLoader.image {
//            Image(uiImage: image)
//                .resizable()
//                .scaledToFill()
//                .clipped()
//        } else {
//            ProgressView()
//        }
//    }
//}



struct CellView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            CellView(VM: AlbumViewModel(), day: 24, isToday: true)
            CellView(VM: AlbumViewModel(), day: 22, isToday: false)
        }
    }
}
