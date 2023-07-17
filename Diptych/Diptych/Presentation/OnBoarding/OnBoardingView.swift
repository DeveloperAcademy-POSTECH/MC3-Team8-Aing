//
//  OnBoardingView.swift
//  Diptych
//
//  Created by HAN GIBAEK on 2023/07/13.
//

import SwiftUI

struct OnBoardingView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.offWhite
                    .ignoresSafeArea()
                VStack(spacing: 28) {
                    Text("딥틱에서 매일 서로의 일상을 하나의 사진으로 완성해요")
                        .font(.pretendard(.light, size: 28))
                        .padding(.leading, 41)
                        .padding(.trailing, 41)
                    Image("diptych_sample1")
                        .resizable()
                        .scaledToFit()
                    VStack(spacing: 10) { // (S) LogIn, SignUp
                        NavigationLink(destination: LogInView()) {
                            Text("로그인")
                                .frame(width: UIScreen.main.bounds.width-30, height:  60)
                                .background(Color.offBlack)
                                .foregroundColor(.offWhite)
                                .border(Color.offBlack)
                        }
                        NavigationLink(destination: SignUpView()) {
                            Text("회원가입")
                                .frame(width: UIScreen.main.bounds.width-30, height:  60)
                                .background(Color.offWhite)
                                .foregroundColor(.offBlack)
                                .border(Color.offBlack)
                        }
                    } // (E) LogIn, SignUp
                }
            }
        }
    }
}

struct OnBoardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnBoardingView()
    }
}
