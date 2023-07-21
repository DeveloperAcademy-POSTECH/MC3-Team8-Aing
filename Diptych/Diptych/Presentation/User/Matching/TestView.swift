//
//  TestView.swift
//  Diptych
//
//  Created by HAN GIBAEK on 2023/07/19.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct TestView: View {
    @StateObject var testViewModel = TestViewModel()
//    @State var listener
    var body: some View {
        VStack {
            Button {
                testViewModel.addListener2()
            } label: {
                Text("Listener2 추가")
            }
            Button {
                testViewModel.addListener3()
            } label: {
                Text("Listener3 추가")
            }
            Button {
                testViewModel.deleteListener1()
            } label: {
                Text("Listener1 삭제")
            }
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
