//
//  PhotoDetailView.swift
//  Diptych
//
//  Created by Nyla on 2023/07/20.
//

import SwiftUI

// MARK: - Property

struct PhotoDetailView {
    var date: String
    var questionNum: Int
    var question: String
    var imageUrl1: String
    var imageUrl2: String
    
    @State private var image1: UIImage?
    @State private var image2: UIImage?
    
}

// MARK: - View

extension PhotoDetailView: View {
    var body: some View {
        ZStack {
            Color.offWhite.edgesIgnoringSafeArea(.top)
            // 이렇게 안 하면 탭바까지 offWhite가 덮어져버려서 해두었습니다

            VStack(spacing: 0) {
                
                /// [1] 해더
                HStack(spacing: 8) {
                    textLabel(text: date)
                    textLabel(text: "\(questionNum)번째 질문")
                    Spacer()
                }//: HStack
                .padding(.leading, 15)
                .padding(.top,20)
                .padding(.bottom, 15)
                // 이슈 1. NavigationLink가 들어가면 위에 그 공간만큼 밑으로 밀리기 때문에 정확한 픽셀 값 맞추기 어려움. 눈 대중으로 맞춰둠.
                
                /// [2] 질문
                HStack(spacing: 0) {
                    Text(question)
                        // 이슈 2. 자간이 약간 다름
                        // 이슈 3. 문장마다 자동 줄바꿈은 어떻게 할 수 있을까?
                        // 이슈 4. padding 값에 따라 글자 짤릴 수 있음
                        .font(.custom(PretendardType.light.rawValue, size: 24))
                        .foregroundColor(.offBlack)
                        .multilineTextAlignment(.leading)
                        .padding(.leading, 15)
                    Spacer()
                }//: HStack

                
                /// [3] 사진 프레임
                // photoA와 photoB가 각각 따로 띄워져야 함, 저장할 때 합쳐져서 저장됨
                // 일단 인터넷에서 url 이미지 임시로 넣어둔 상태
                HStack(spacing: 0) {
                    AsyncImage(
                        url: URL(string: imageUrl1),
                        content: { image in
                            image
                                .resizable()
                                .frame(width: 196.5, height: 393)
//                                .padding(.top, 20)
//                                .padding(.bottom, 44)
                        },
                        placeholder: { ProgressView() }
                    )
                    AsyncImage(
                        url: URL(string: imageUrl2),
                        content: { image in
                            image
                                .resizable()
                                .frame(height: 393)
                                .frame(width: 196.5, height: 393)
//                                .padding(.top, 20)
//                                .padding(.bottom, 44)
                        },
                        placeholder: { ProgressView() }
                    )
                }//: HStack
//                .frame(height: 393, alignment: .center)
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .padding(.top, 20)
                .padding(.bottom,44)
                
                
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
    }
}

// MARK: - Component

extension PhotoDetailView {
    
//    private func DiptychImage() -> UIImage? {
//        guard let image1 = image1, let image2 = image2
//            else{
//            return nil
//        }
//
//        let size = CGSize(width: 200, height: 200)
//
//        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 200, height: 200))
//        let image = renderer.image { ctx in
//
//            let rect1 = CGRect(x: 0, y: 0, width: 100, height: 200)
//            let rect2 = CGRect(x: 0, y: 0, width: 100, height: 200)
//        }
//        return image
//    }
    
    
    
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
            date: "2023년 7월 30일",
            questionNum: 20,
            question: "\"상대방의 표정 중 당신이\n 가장 좋아하는 표정은?\"",
            imageUrl1: "https://file.notion.so/f/s/1ed8775d-60cc-4907-b8f2-edf0acfb484f/%E1%84%89%E1%85%A6%E1%84%85%E1%85%A9_3_copy_5_%E1%84%87%E1%85%A9%E1%86%A8%E1%84%89%E1%85%A1%E1%84%87%E1%85%A9%E1%86%AB_2.jpg?id=8dc957fa-bf1e-4daf-a72a-6be8e69213d6&table=block&spaceId=794074b4-a62e-40a9-9a73-2dc5a7035226&expirationTimestamp=1689933600000&signature=-ZApnHNSBN05IfP5KQJWDd_MUXwXBrAUPvTwjjdI-40&downloadName=%E1%84%89%E1%85%A6%E1%84%85%E1%85%A9+3+copy+5+%E1%84%87%E1%85%A9%E1%86%A8%E1%84%89%E1%85%A1%E1%84%87%E1%85%A9%E1%86%AB+2.jpg",
            imageUrl2: "https://file.notion.so/f/s/19b32819-43e4-446d-bcb8-917b17cfe2cd/%E1%84%89%E1%85%A6%E1%84%85%E1%85%A9_3_copy_5_%E1%84%87%E1%85%A9%E1%86%A8%E1%84%89%E1%85%A1%E1%84%87%E1%85%A9%E1%86%AB.jpg?id=7fddf6e5-976e-4ed6-af14-be1ff9662108&table=block&spaceId=794074b4-a62e-40a9-9a73-2dc5a7035226&expirationTimestamp=1689933600000&signature=QECxg7nvN5ew0ajmMq5oCJmCV0SqyR7e7n8SwOAI804&downloadName=%E1%84%89%E1%85%A6%E1%84%85%E1%85%A9+3+copy+5+%E1%84%87%E1%85%A9%E1%86%A8%E1%84%89%E1%85%A1%E1%84%87%E1%85%A9%E1%86%AB.jpg"
        )
    }
}
