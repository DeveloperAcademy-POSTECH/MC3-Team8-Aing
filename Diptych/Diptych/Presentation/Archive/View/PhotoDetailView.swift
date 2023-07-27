//
//  PhotoDetailView.swift
//  Diptych
//
//  Created by Nyla on 2023/07/20.
//

import SwiftUI
import FirebaseStorage

// MARK: - Property

struct PhotoDetailView {
    var date: Date
    var questionNum: Int
    var question: String
    var isLoading: Bool
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy. MM. d"
        return formatter
    }()
    
    @State var index : Int = 2
    @State var image1: String?
    @State var image2: String?
    @State var imageUrl1: URL?
    @State var imageUrl2: URL?
    @State private var isImageLoaded = false

}

// MARK: - View

extension PhotoDetailView: View {
    var body: some View {
        ZStack {
            Color.offWhite.edgesIgnoringSafeArea(.top)
            // 이렇게 안 하면 탭바까지 offWhite가 덮어져버려서 해두었습니다

            VStack(spacing: 0) {
                
                /// [1] 해더
                HStack{
                    previousButton
                    
                    VStack(spacing: 5) {
                        Text("\(questionNum)번째 딥틱")
                        Text("( \(dateFormatter.string(from: date)) )")
                    }//: VStack
                    .padding(.horizontal, 25)
                    .padding(.top,20)
                    .padding(.bottom,20)
                    
                    nextButton
                }
                
//                HStack(spacing: 8) {
//                    Text("\(questionNum)번째 딥틱 입니다")
//                    Spacer()
//                    textLabel(text: dateFormatter.string(from: date))
//                }//: HStack
//                .padding(.horizontal, 17)
//                .padding(.top,20)
//                .padding(.bottom, 15)
                
                
                /// [2] 질문
                ZStack{
                    RoundedRectangle(cornerRadius:0)
                        .stroke(Color.lightGray, lineWidth: 1)
                        .frame(height: 90)
                    
                    Text("❝  \(question)  ❞")
                        .font(.custom(PretendardType.light.rawValue, size: 20))
                        .foregroundColor(.offBlack)
                        .multilineTextAlignment(.leading)
                    
                }//: ZStack
                
//                HStack(spacing:0){
//                    Text("\(question)")
//                        // 이슈 2. 자간이 약간 다름
//                        // 이슈 3. 문장마다 자동 줄바꿈은 어떻게 할 수 있을까?
//                        // 이슈 4. padding 값에 따라 글자 짤릴 수 있음
//                        .font(.custom(PretendardType.light.rawValue, size: 24))
//                        .foregroundColor(.offBlack)
//                        .multilineTextAlignment(.leading)
//                        .padding(.leading, 17)
//                    Spacer()
//                }//: HStack

                
                /// [3] 사진 프레임
                // photoA와 photoB가 각각 따로 띄워져야 함, 저장할 때 합쳐져서 저장됨
                // 일단 인터넷에서 url 이미지 임시로 넣어둔 상태
              
                ZStack{
                    RoundedRectangle(cornerRadius: 0)
                        .foregroundColor(Color.darkGray)
//                        .stroke(Color.lightGray, lineWidth: 1)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                    
                    HStack(spacing: 0) {
                            ///왼쪽 사진
                            AsyncImage(url: imageUrl1) { image in
                                image
                                    .resizable()
                                    .frame(width: 196.5, height: 393)
                                
                            } placeholder: {
                                if !isLoading {
                                    ProgressView()
                                }
                            }
                            .frame(width: 196.5)
                            
                            
                            /// 오른쪽 사진
                            AsyncImage(url: imageUrl2) { image in
                                image
                                    .resizable()
                                    .frame(width: 196.5, height: 393)
                            } placeholder: {
                                if !isLoading {
                                    ProgressView()
                                }
                            }
                            .frame(width: 196.5)
                            
                        }//】 HStack
                    }//】 ZStack
                    .frame(height: 393, alignment: .center)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .padding(.bottom,30)
                
                
                
                
                /// [4]버튼
                HStack {
                    ShareSheetView()
//                    Image("upload")
                        .foregroundColor(.offBlack)
                        .frame(width: 30, height: 30)
                        .padding(.leading, 70)
                    Image("whiteHeart")
                        .foregroundColor(.offBlack)
                        .frame(width: 30, height: 30)
                        .padding(.horizontal, 80)
                    Image("comment")
                        .foregroundColor(.offBlack)
                        .frame(width: 30, height: 30)
                        .padding(.trailing, 70)
                }
                .padding(.bottom,48)
                
                Spacer()
            } // VStack
            
        } // ZStack
        .onAppear {
            Task {
                await downloadImage()
            }
        }
    }//】 Body
    
    
}

// MARK: - Component

extension PhotoDetailView {
    
    /// 이전 필터 버튼
    private var previousButton: some View {
        Button {
            index - 1
        } label: {
            ZStack{
                Circle()
                    .frame(width: 25, height: 25)
                    .foregroundColor(.offBlack.opacity(0.5))
                
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .font(.headline)
                    .fontWeight(.medium)
                    
            }
        }//】 Button
    }// 이전 필터 버튼
    
    
    /// 다음 필터 버튼
    private var nextButton: some View {
        Button {
            index + 1
        } label: {
            ZStack{
                Circle()
                    .frame(width: 25, height: 25)
                    .foregroundColor(.offBlack.opacity(0.5))
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white)
                    .font(.headline)
                    .fontWeight(.medium)
                    
            }
        }//】 Button
    }// 다음 필터 버튼
    
    /// 이미지 불러오기
    func downloadImage() async {
        if let image1 = image1, !image1.isEmpty {
            do {
                let url = try await Storage.storage().reference(forURL: image1).downloadURL()
                imageUrl1 = url
            } catch {
                print(error.localizedDescription)
            }
        }
        
        if let image2 = image2, !image2.isEmpty {
            do {
                let url = try await Storage.storage().reference(forURL: image2).downloadURL()
                imageUrl2 = url
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    
    func textLabel(text: String) -> some View {
        return Text(text)
            .font(.custom(PretendardType.medium.rawValue, size: 16))
            .foregroundColor(.offBlack)
            .padding(.vertical, 7)
            .padding(.horizontal, 8)
            .background(
                Rectangle()
                    .fill(Color.lightGray)
            )
    }
    
    
    
    
    
}

// MARK: - Preview

struct PhotoDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoDetailView(
            date: Date.now,
            questionNum: 20,
            question: "\"상대방의 표정 중 당신이\n 가장 좋아하는 표정은?\"",
            isLoading: false
        )
    }
}
