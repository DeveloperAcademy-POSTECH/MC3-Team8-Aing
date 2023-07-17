//
//  Test.swift
//  Diptych
//
//  Created by HAN GIBAEK on 2023/07/14.
//

//import SwiftUI
//
//struct Test: View {
//    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//    }
//}
//
//struct Test_Previews: PreviewProvider {
//    static var previews: some View {
//        Test()
//    }
//}

import SwiftUI
import Combine

struct TestView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
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
                        TextField("이메일", text: $authViewModel.email)
                            .font(.pretendard(.light, size: 18))
                            .foregroundColor(.darkGray)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                        Divider()
                    }
                }
                .padding([.leading, .trailing], 15)
            
                Spacer()
                Button {
                    Task {
                        await authViewModel.sendSignInLink()
                    }
                    print(authViewModel.email)
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

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
            .environmentObject(AuthViewModel())
    }
}
