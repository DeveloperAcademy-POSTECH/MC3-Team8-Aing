//
//  CouplingView.swift
//  Diptych
//
//  Created by HAN GIBAEK on 2023/07/17.
//

import SwiftUI

struct CouplingView: View {
    /// 카메라 표시 여부
    @State var isShowCamera = false
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        VStack {
            Text("abc")
            Divider()
            Button {
               isShowCamera = true
            } label: {
                Label("[임시] 카메라 열기", systemImage: "camera.fill")
            }
        }.fullScreenCover(isPresented: $isShowCamera) {
            CameraRepresentableView()
                 .toolbar(.hidden, for: .tabBar)
        }
    }
}

struct CouplingView_Previews: PreviewProvider {
    static var previews: some View {
        CouplingView()
            .environmentObject(AuthenticationViewModel())
    }
}
