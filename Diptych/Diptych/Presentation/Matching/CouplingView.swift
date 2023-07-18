//
//  CouplingView.swift
//  Diptych
//
//  Created by HAN GIBAEK on 2023/07/17.
//

import SwiftUI

struct CouplingView: View {
    @State var sample: String = ""
    @State var loverCode: String = ""
    @StateObject var couplingViewModel: CouplingViewModel = CouplingViewModel()
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        ZStack {
            Color.offWhite
                .ignoresSafeArea()
            VStack {
                Spacer()
                Text("커플 연결")
                Spacer()
                HStack {
                    Text(couplingViewModel.couplingCode ?? "error")
                    Button {
                        Task {
                            try await couplingViewModel.generatedCouplingCode()
                            print("인증번호 받기 클릭")
                        }
                    } label: {
                        Text("인증번호 받기")
                    }
                }
                Spacer()
                VStack {
                    VStack {
                        Text("연인의 인증번호를 입력하세요.")
                        TextField("인증번호", text: $loverCode)
                    }
                    Button {
                        Task {
                            print("커플연결 클릭")
                            try await couplingViewModel.setCoupleData(code: loverCode)
                            await authViewModel.fetchUser()
                            if couplingViewModel.isCompleted {
                                authViewModel.flow = .completed
                            }
                        }
                    } label: {
                        Text("커플 연결하기")
                    }
                }
                Spacer()
            }
            .ignoresSafeArea()
        }
    }
}

struct CouplingView_Previews: PreviewProvider {
    static var previews: some View {
        CouplingView()
            .environmentObject(AuthenticationViewModel())
    }
}
