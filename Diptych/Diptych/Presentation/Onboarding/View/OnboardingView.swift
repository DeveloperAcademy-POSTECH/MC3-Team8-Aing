//
//  OnBoardingView.swift
//  Diptych
//
//  Created by HAN GIBAEK on 2023/07/13.
//

import SwiftUI

enum LoginMethod {
    case kakao, apple

    var imageTitle: String {
        switch self {
        case .kakao:
            return "icnKakao"
        case .apple:
            return "icnApple"
        }
    }

    var title: String {
        switch self {
        case .kakao:
            return "카카오 로그인"
        case .apple:
            return "Apple로 계속하기"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .kakao:
            return Color("KakaoLoginYellow")
        case .apple:
            return .black
        }
    }

    var foregroundColor: Color {
        switch self {
        case .kakao:
            return .black
                .opacity(0.85)
        case .apple:
            return .offWhite
        }
    }

    func loginButtonDidTap() {
        switch self {
        case .kakao:
            print("카카오 로그인 실행")
        case .apple:
            print("애플 로그인 실행")
        }
    }
}

struct OnboardingView: View {

    var body: some View {
        NavigationView {
            ZStack {
                Color.offWhite
                    .ignoresSafeArea()
                VStack {
                    diptychLabel
                        .padding(.top, 80)
                    Spacer()
                    VStack(spacing: 0) {
                        loginButton(.kakao)
                            .padding(.bottom, 12)
                        loginButton(.apple)
                            .padding(.bottom, 17)
                        emailLoginButton
                    }
                    .padding(.horizontal, 15)
                    .padding(.bottom, 36)
                }
            }
        }
    }
}

// MARK: - UI Components

extension OnboardingView {

    var diptychLabel: some View {
        Text("딥틱에서 매일 서로의 일상을\n하나의 사진으로 완성해요")
            .font(.pretendard(.light, size: 28))
            .multilineTextAlignment(.center)
            .lineSpacing(6)
    }

    var emailLoginButton: some View {
        NavigationLink {
            LoginView()
        } label: {
            VStack(spacing: 0) {
                Text("이메일로 로그인하기")
                    .font(.pretendard(.medium, size: 16))
                    .foregroundColor(.dtDarkGray)
                Rectangle()
                    .foregroundColor(.dtDarkGray)
                    .frame(width: 130, height: 1)
            }
        }
    }

    private func loginButton(_ loginMethod: LoginMethod) -> some View {
        HStack(spacing: 16) {
            Image(loginMethod.imageTitle)
            Text(loginMethod.title)
        }
        .foregroundColor(loginMethod.foregroundColor)
        .font(.pretendard(.light, size: 20))
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(loginMethod.backgroundColor)
        .onTapGesture {
            loginMethod.loginButtonDidTap()
        }
    }
}

struct OnBoardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(UserViewModel())
    }
}
