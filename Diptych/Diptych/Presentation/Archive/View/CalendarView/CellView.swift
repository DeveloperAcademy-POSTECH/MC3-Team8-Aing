//
//  CellView.swift
//  Diptych
//
//  Created by Koo on 2023/07/24.
//

import SwiftUI
import FirebaseStorage

struct CellView: View {
    
    ///Property
    @State var day: Int
    @State var isToday: Bool
    @State var isCompleted: Bool
    @State var thumbnail: String?
    @State var thumbnailURL: URL?
    
    
    var body: some View {

        ZStack{
            /// 오늘 날짜일때 빨간 테두리
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.systemSalmon, lineWidth: isToday ? 2 : 0)
                .frame(width: 44, height: 50)
                .overlay{
                    /// 썸네일 사진 불러오기
                    if isCompleted {
                        ZStack {
                            AsyncImage(url: thumbnailURL) { image in
                                image
                                    .resizable()
                                    .clipShape(RoundedRectangle(cornerRadius: 18))
                            } placeholder: {
                                ProgressView()
                            }
                            Color.offBlack.opacity(0.5)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                        }//】 ZStack
                    } else {
                        EmptyView()
                    }
                }//:overlay
            
            /// 날짜 표시
            Text("\(day)")
                .font(.pretendard(.bold, size: 16))
                .foregroundColor(.offBlack)
                .offset(y: -10)
            
        }//】 ZStack
        .padding(.bottom, 19)
        .onAppear {
            Task {
                await downloadImage()
            }
        }
    }//】 Body
    
    
    /// 이미지 불러오기
    func downloadImage() async {
        if let thumbnail = thumbnail, !thumbnail.isEmpty {
            do {
                let url = try await Storage.storage().reference(forURL: thumbnail).downloadURL()
                   thumbnailURL = url
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    
    
}


struct CellView_Previews: PreviewProvider {
    static var previews: some View {
        HStack{
            CellView(day: 26, isToday: true, isCompleted: false)
            CellView(day: 25, isToday: false, isCompleted: false)
        }
    }
}
