//
//  OnBoardingView.swift
//  Diptych
//
//  Created by HAN GIBAEK on 2023/07/13.
//

import SwiftUI

struct OnBoardingView: View {
    @State var isLogInLinkActive = false
    @State var isSignUpLinkActive = false
    @EnvironmentObject var userViewModel: UserViewModel
//    @EnvironmentObject var authViewModel: AuthenticationViewModel
    var body: some View {
        NavigationView {
            ZStack {
                Color.offWhite
                    .ignoresSafeArea()
                VStack() {
                    Spacer()
                        .frame(height: 124)
                    Text("딥틱에서 매일 서로의 일상을 하나의 사진으로 완성해요")
                        .font(.pretendard(.light, size: 28))
                        .padding(.leading, 41)
                        .padding(.trailing, 41)
                    Spacer()
                        .frame(height: 28)
                    Image("diptych_sample1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 393, height: 393)
                    Spacer()
                    VStack(spacing: 10) { // (S) LogIn, SignUp
                        NavigationLink(destination: LogInView()) {
                            Text("로그인")
                                .frame(width: UIScreen.main.bounds.width-30, height:  60)
                                .background(Color.offBlack)
                                .foregroundColor(.offWhite)
                                .border(Color.offBlack)
                        }
                        NavigationLink(destination: SignUpFlowView()) {
                            Text("회원가입")
                                .frame(width: UIScreen.main.bounds.width-30, height:  60)
                                .background(Color.offWhite)
                                .foregroundColor(.offBlack)
                                .border(Color.offBlack)
                        }
                    }// (E) LogIn, SignUp
                    Spacer()
                        .frame(height: 55)
                }
                .ignoresSafeArea()
            }
//            .onAppear {
//                print("user: \(authViewModel.user)")
//                print("user: \(authViewModel.user?.isEmailVerified)")
//                print("state: \(authViewModel.authenticationState)")
//            }
        }
        .navigationViewStyle(.stack)
//        .onDisappear {
//            isSignUpLinkActive.toggle()
//        }
    }
}

struct OnBoardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnBoardingView()
            .environmentObject(AuthenticationViewModel())
    }
}
