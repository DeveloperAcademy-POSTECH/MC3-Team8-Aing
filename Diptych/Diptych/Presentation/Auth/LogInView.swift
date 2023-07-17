//
//  LogInView.swift
//  Diptych
//
//  Created by HAN GIBAEK on 2023/07/13.
//

import SwiftUI

struct LogInView: View {
    @State var email: String = ""
    @State var password: String = ""
    var body: some View {
        ZStack {
            Color.offWhite
                .ignoresSafeArea()
            VStack {
                Spacer()
                    .frame(height: 124)
                Text("로그인")
                    .font(.pretendard(.light, size: 28))
                Spacer()
//                        .frame(height: 138)
                VStack(spacing: 37) {
                    VStack(alignment: .leading) {
                        TextField("이메일", text: $email)
                            .font(.pretendard(.light, size: 18))
                            .foregroundColor(.darkGray)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                        Divider()
                    }
                    VStack(alignment: .leading) {
                        SecureField("비밀번호", text: $password)
                            .font(.pretendard(.light, size: 18))
                            .foregroundColor(.darkGray)
                        Divider()
                    }
                }
                .padding([.leading, .trailing], 15)
                Spacer()
                    .frame(height: 33)
                HStack {
                    Button{
                        print("입력: 아이디 찾기")
                    } label: {
                        Text("아이디 찾기")
                            .font(.pretendard(.thin, size: 15))
                            .foregroundColor(.darkGray)
                    }
                    Text("|")
                        .font(.pretendard(.thin, size: 15))
                        .foregroundColor(.darkGray)
                    Button{
                        print("입력: 비밀번호 찾기")
                    } label: {
                        Text("비밀번호 찾기")
                            .font(.pretendard(.thin, size: 15))
                            .foregroundColor(.darkGray)
                    }
                }
                Spacer()
                Button {
                    print("로그인 시도")
                } label: {
                    Text("로그인하기")
                        .frame(width: UIScreen.main.bounds.width-30, height:  60)
                        .background(Color.offBlack)
                        .foregroundColor(.offWhite)
                }
                Spacer()
                    .frame(height: 55)
            }
            .ignoresSafeArea()
        }
    }
}

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView()
    }
}
