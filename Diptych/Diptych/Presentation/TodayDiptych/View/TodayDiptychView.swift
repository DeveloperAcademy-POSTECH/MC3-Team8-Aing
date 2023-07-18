//
//  TodayDiptychView.swift
//  Diptych
//
//  Created by 김민 on 2023/07/13.
//

import SwiftUI

struct TodayDiptychView: View {
    @State var isShowCamera = false
    
    var body: some View {
        VStack {
            Text("TodayDiptychView")
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

struct TodayDiptychView_Previews: PreviewProvider {
    static var previews: some View {
        TodayDiptychView()
    }
}
