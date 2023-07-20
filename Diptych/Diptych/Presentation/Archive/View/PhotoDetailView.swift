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
    var imageUrl: String
}

// MARK: - View

extension PhotoDetailView: View {
    var body: some View {
        ZStack {
            Color.offWhite.edgesIgnoringSafeArea(.top)
            // 이렇게 안 하면 탭바까지 offWhite가 덮어져버려서 해두었습니다

            VStack {
                HStack {
                    textLabel(text: date)
                    textLabel(text: "\(questionNum)번째 질문")
                    Spacer()
                }
                .padding(.leading, 15)
                // 이슈 1. NavigationLink가 들어가면 위에 그 공간만큼 밑으로 밀리기 때문에 정확한 픽셀 값 맞추기 어려움. 눈 대중으로 맞춰둠.
                .padding(.bottom, 15)

                HStack {
                    Text(question)
                        // 이슈 2. 자간이 약간 다름
                        // 이슈 3. 문장마다 자동 줄바꿈은 어떻게 할 수 있을까?
                        // 이슈 4. padding 값에 따라 글자 짤릴 수 있음
                        .font(.custom(PretendardType.light.rawValue, size: 24))
                        .foregroundColor(.offBlack)
                        .multilineTextAlignment(.leading)
                        .padding(.leading, 15)
                    Spacer()
                }

                // photoA와 photoB가 각각 따로 띄워져야 함, 저장할 때 합쳐져서 저장됨
                // 일단 인터넷에서 url 이미지 임시로 넣어둔 상태
                HStack(spacing: 0) {
                    AsyncImage(
                        url: URL(string: imageUrl),
                        content: { image in
                            image
                                .resizable()
                                .frame(width: 196.5, height: 393)
                                .padding(.top, 20)
                                .padding(.bottom, 44)
                        },
                        placeholder: { ProgressView() }
                    )
                    AsyncImage(
                        url: URL(string: imageUrl),
                        content: { image in
                            image
                                .resizable()
                                .frame(width: 196.5, height: 393)
                                .padding(.top, 20)
                                .padding(.bottom, 44)
                        },
                        placeholder: { ProgressView() }
                    )
                }

                HStack {
                    Image("download")
                        .foregroundColor(.offBlack)
                        .frame(width: 30, height: 30)
                        .padding(.leading, 118)
                        .padding(.trailing, 97)
                    Image("send")
                        .foregroundColor(.offBlack)
                        .frame(width: 30, height: 30)
                        .padding(.trailing, 118)
                }
                .padding(.bottom, 48)
            } // VStack
        } // ZStack
    }
}

// MARK: - Component

extension PhotoDetailView {
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
            imageUrl: "https://www.alleycat.org/wp-content/uploads/2019/03/FELV-cat.jpg"
        )
    }
}
