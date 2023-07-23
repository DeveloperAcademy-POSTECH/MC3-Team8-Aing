//
//  TestViewModel.swift
//  Diptych
//
//  Created by HAN GIBAEK on 2023/07/19.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
class TestViewModel: ObservableObject {
    var listener: ListenerRegistration?
    
    init() {
        addListener1()
    }
    
    func addListener1() {
        self.listener = Firestore.firestore().collection("users").addSnapshotListener { snapshot, error in
            do {
                print("111111111")
            }
        }
    }
    
    func addListener2() {
        Firestore.firestore().collection("users").addSnapshotListener { snapshot, error in
            do {
                print("2222222")
            }
        }
    }
    
    func addListener3() {
        Firestore.firestore().collection("users").addSnapshotListener { snapshot, error in
            do {
                print("3333333333")
            }
        }
    }
    
    func deleteListener1() {
        self.listener?.remove()
    }
}
