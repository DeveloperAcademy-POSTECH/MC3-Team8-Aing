//
//  CouplingView.swift
//  Diptych
//
//  Created by HAN GIBAEK on 2023/07/17.
//

import SwiftUI

struct CouplingView: View {
    @State private var sample: String = ""
    @State private var loverCode: String = ""
    @State private var isProfileSettingLinkActive = false
    
    @FocusState var isCodeInputFocused: Bool
    
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        ZStack {
            Color.offWhite
            VStack {
                Spacer()
                    .frame(height: 124)
                Text("서로의 초대코드를 입력하여 연결해주세요")
                    .font(.pretendard(.light, size: 28))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                Spacer()
                    .frame(height: 65)
                VStack(spacing: 50) {
                    VStack(alignment: .leading){
                        Text("내 초대코드")
                            .font(.pretendard(.light, size: 16))
                        HStack {
                            Text(userViewModel.couplingCode ?? "")
                                .font(.pretendard(.bold, size: 24))
                            Spacer()
                            Button {
                                UIPasteboard.general.string = userViewModel.couplingCode ?? "error"
                            } label: {
                                Text("복사하기")
                                    .font(.pretendard(size: 16))
                                    .frame(width: 74, height: 34)
                                    .foregroundColor(.offWhite)
                                    .background(Color.offBlack)
                            }
                        }
                        Divider()
                            .frame(height: 1)
                            .foregroundColor(.darkGray)
                    }
                    VStack(alignment: .leading) {
                        Text("상대방 코드를 전달받으셨나요?")
                            .font(.pretendard(.light, size: 16))
                        TextField("", text: $loverCode, prompt: Text("전달받은 초대코드 입력")
                            .font(.pretendard(.light, size: 24))
                            .foregroundColor(.darkGray))
                        .font(.pretendard(.light, size: 24))
                        .foregroundColor(.darkGray)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .focused($isCodeInputFocused)
                        Divider()
                            .frame(height: 1)
                            .overlay(Color.darkGray)
                    }
                }
                Spacer()
                Button {
                    Task {
//                        try await userViewModel.setCouplingCode()
                        try await userViewModel.setCoupleData(code: loverCode)
                    }
                } label: {
                    Text("연결하기")
                        .frame(width: UIScreen.main.bounds.width-30, height:  60)
                        .background(Color.offBlack)
                        .foregroundColor(.offWhite)
                }
                Spacer()
                    .frame(height: 47)
            }
            .padding([.leading, .trailing], 15)
        }
        .ignoresSafeArea()
        .onTapGesture {
            isCodeInputFocused = false
        }
        .onAppear() {
            Task {
                try await userViewModel.setCouplingCode()
            }
        }
    }
}

struct CouplingView_Previews: PreviewProvider {
    static var previews: some View {
        CouplingView()
            .environmentObject(UserViewModel())
    }
}
