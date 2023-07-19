//
//  CouplingViewModel.swift
//  Diptych
//
//  Created by HAN GIBAEK on 2023/07/18.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
class CouplingViewModel: ObservableObject {
    @Published var couplingCode: String?
    @Published var currentUser: DiptychUser?
    @Published var lover: DiptychUser?
    @Published var isCompleted: Bool = false
    var listener: ListenerRegistration?
    
    init() {
        listener = Firestore.firestore().collection("users").addSnapshotListener() { snapshot, error in
            Task{
                await self.fetchUser()
            }
        }
    }
    
    
    
    func generatedCouplingCode() async throws {
        do {
            self.couplingCode = String(Int.random(in: 10000000 ... 99999999))
            if var currentUser = self.currentUser {
                print(currentUser)
                currentUser.couplingCode = self.couplingCode
                let encodedUser = try Firestore.Encoder().encode(currentUser)
                try await Firestore.firestore().collection("users").document(currentUser.id).setData(encodedUser, merge: true)
            }
        }
    }
    
    
    func getLoverDataWithCode(code: String) async throws {
        do {
            guard let snapshot = try? await Firestore.firestore().collection("users").whereField("couplingCode", isEqualTo: code).getDocuments() else {
                print("ERROR: getLoverDataWithCode")
                return
            }
            print("snapshot doc: \(snapshot.documents)")
            if snapshot.documents.count == 1 {
                self.lover = try snapshot.documents[0].data(as: DiptychUser.self)
            }
            //                for doc in snapshot.documents {
            //                    self.lover = try doc.data(as: DiptychUser.self)
            //                }
        }
    }
    
    func setCoupleData(code: String) async throws {
        do {
            try await getLoverDataWithCode(code: code)
//            print("DEBUG setCoupleData : \(String(describing: self.currentUser))\n \(String(describing: self.lover))")
            if var currentUser = self.currentUser, var lover = self.lover {
//                print("1: \(currentUser.email) \(lover.email)")
                currentUser.loverId = self.lover?.id
                lover.loverId = self.currentUser?.id
//                print("2: \(currentUser.id) /// \(lover.id)")
//                print("3: \(String(describing: currentUser.loverId)) /// \(String(describing: lover.loverId))")
                currentUser.flow = "completed"
                lover.flow = "completed"
                let encodedCurrentUser = try Firestore.Encoder().encode(currentUser)
                let encodedLover = try Firestore.Encoder().encode(lover)
                try await Firestore.firestore().collection("users").document(currentUser.id).setData(encodedCurrentUser, merge: true)
                try await Firestore.firestore().collection("users").document(lover.id).setData(encodedLover, merge: true)
                self.isCompleted = true
            }
        }
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: DiptychUser.self)
    }
    
    //    func setCurrentUserData() async throws {
    //        do {
    //            Task {
    //                if var currentUser = self.currentUser {
    //                    currentUser.loverId = lover?.id
    //                    let encodedUser = try Firestore.Encoder().encode(currentUser)
    //                    try await Firestore.firestore().collection("users").document(currentUser.id).setData(encodedUser, merge: true)
    //                }
    //            }
    //        }
    //    }
    //
    //    func checkCoupling() async throws {
    //        do {
    //            Task {
    //                guard let currentUser = self.currentUser else { return }
    //                guard let lover = self.lover else { return }
    //                if currentUser.loverId == lover.id && currentUser.id == lover.loverId {
    //                    self.isCompleted.toggle()
    //                }
    //            }
    //        }
    //    }
}
