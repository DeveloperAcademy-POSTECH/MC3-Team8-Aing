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
    @State var passwordWarning: String = ""
    @State var isAlertShown: Bool = false
    @State var alertMessage: String = ""
    @State var dividerColor: Color = .darkGray
    @State var isPasswordHidden: Bool = true
    
    @FocusState var isPasswordFocused: Bool
    
    @EnvironmentObject var userViewModel: UserViewModel
//    @EnvironmentObject var todayDiptychViewModel: TodayDiptychViewModel
    
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
                    .frame(height: 164)
                //                        .frame(height: 138)
                VStack(spacing: 37) {
                    VStack(alignment: .leading) {
                        TextField("", text: $email, prompt: Text("이메일")
                            .font(.pretendard(.light, size: 18))
                            .foregroundColor(.darkGray))
                        .font(.pretendard(.light, size: 18))
                        .foregroundColor(.darkGray)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        Divider()
                            .overlay(dividerColor)
                    }
                    VStack(alignment: .leading) {
                        HStack {
                            SecureInputView(isHidden: $isPasswordHidden, password: $password, isFocused: $isPasswordFocused, prompt: "비밀번호")
                                .onTapGesture {
                                    isPasswordFocused = true
                                }
                            Button {
                                isPasswordHidden.toggle()
                            } label: {
                                Image(systemName: isPasswordHidden ? "eye" : "eye.slash")
                                    .foregroundColor(.darkGray)
                            }
                        }
                        Divider()
                            .overlay(passwordWarning == "" ? Color.darkGray : Color.systemRed)
//                        SecureField("", text: $password, prompt: Text("비밀번호")
//                            .font(.pretendard(.light, size: 18))
//                            .foregroundColor(.darkGray))
//                        .font(.pretendard(.light, size: 18))
//                        .foregroundColor(.darkGray)
//                        Divider()
//                            .overlay(dividerColor)
//                        Text(passwordWarning)
//                            .font(.pretendard(.light, size: 12))
//                            .foregroundColor(.systemRed)
                    }
                }
                .padding([.leading, .trailing], 15)
                Spacer()
                    .frame(height: 33)
                HStack {
                    Button{
                        print("pass: 아이디 찾기")
                    } label: {
                        Text("아이디 찾기")
                            .font(.pretendard(.light, size: 14))
                            .foregroundColor(.darkGray)
                    }
                    Text("|")
                        .font(.pretendard(.light, size: 14))
                        .foregroundColor(.darkGray)
                    Button{
                        print("pass: 비밀번호 찾기")
                    } label: {
                        Text("비밀번호 찾기")
                            .font(.pretendard(.light, size: 14))
                            .foregroundColor(.darkGray)
                    }
                }
                Spacer()
                Button {
                    Task {
                        let result = try await userViewModel.signInWithEmailPassword(email: email, password: password)
                        if result != "" {
                            alertMessage = result
                            isAlertShown = true
                        }
                    }
                } label: {
                    Text("로그인하기")
                        .frame(width: UIScreen.main.bounds.width-30, height:  60)
                        .background(Color.offBlack)
                        .foregroundColor(.offWhite)
                }
                .alert(isPresented: $isAlertShown) {
                    Alert(title: Text("로그인 에러"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
                }
//                NavigationLink(destination: EmailVerificationView()) {
//                    Text("로그인")
//                        .frame(width: UIScreen.main.bounds.width-30, height:  60)
//                        .background(Color.offBlack)
//                        .foregroundColor(.offWhite)
//                }
                Spacer()
                    .frame(height: 47)
            }
            .ignoresSafeArea()
        }
        .onTapGesture {
            isPasswordFocused = false
        }
        .navigationViewStyle(.stack)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationBackItem()
            }
        }
    }
}

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView()
            .environmentObject(UserViewModel())
    }
}
