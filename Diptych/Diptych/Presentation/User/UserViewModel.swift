//
//  UserViewModel.swift
//  Diptych
//
//  Created by HAN GIBAEK on 2023/07/20.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

//extension UserViewModel {
//    @Published var isLogInLinkActive = false
//    @Published var isSignUpLinkActive = false
//    @Published var isEmailVerificationLinkActive = false
//    @Published var isProfileSettingLinkActive = false
//}

enum UserFlow: String {
    case initialized = "initialized"
    case signedUp = "signedUp"
    case emailVerified = "emailVerified"
    case coupled = "coupled"
    case completed = "completed"
}

@MainActor
class UserViewModel: ObservableObject {
    @Published var currentUser: DiptychUser?
    @Published var flow: UserFlow = .initialized
    
    @Published var couplingCode: String?
    @Published var lover: DiptychUser?
    @Published var coupleAlbum: DiptychAlbum?
    @Published var isCompleted: Bool = false
    
    var listenerAboutAuth: AuthStateDidChangeListenerHandle?
    var listenerAboutUserData: ListenerRegistration?
    
    //    @Published var isEmailVerified: Bool = false
    
    init() {
        //        self.userSession = Auth.auth().currentUser //currentUser가 없으면 nil이 할당
        Task {
            await fetchUserData()
//            if let currentUser = self.currentUser {
//                self.flow = UserFlow(rawValue: currentUser.flow) ?? .initialized
//            }
            print("[DEBUG] currentUser : \(self.currentUser) /// flow : \(self.flow)")
            listenerAboutUserData = Firestore.firestore().collection("users").addSnapshotListener() { snapshot, error in
                Task{
                    await self.fetchUserData()
                }
            }
            try await generatedCouplingCode()
        }
    }
    
    // MARK : Singing, Authentication
    func signInWithEmailPassword(email: String, password: String) async throws {
        do {
            print("[DEBUG] signInWithEmailPassword -> email: \(email), password: \(password)")
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            print("[DEBUG] signInWithEmailPassword -> result:  \(result)")
            await fetchUserData()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func signUpWithEmailPassword(email: String, password: String, name: String) async throws {
        do {
            print("DEBUG: signUpWithEmailPassword")
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let user = DiptychUser(id: result.user.uid, email: email, flow: "signedUp", name: name)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func sendEmailVerification() async throws {
        do {
            print("DEBUG: sendEmailVerification")
            try await Auth.auth().currentUser?.sendEmailVerification()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func checkEmailVerification() async throws {
        do {
            print("DEBUG: checkEmailVerification")
            repeat {
                await wait()
                try await Auth.auth().currentUser?.reload()
                if let isEmailVerified = Auth.auth().currentUser?.isEmailVerified {
                    if isEmailVerified{
                        self.flow = .emailVerified
                    }
                }
            } while self.flow != .emailVerified
            if var currentUser = self.currentUser {
                currentUser.flow = self.flow.rawValue
                let encodedUser = try Firestore.Encoder().encode(currentUser)
                try await Firestore.firestore().collection("users").document(currentUser.id).setData(encodedUser, merge: true)
            }
        }
    }
    
//    func checkEmailVerification2() async {
//        do {
//            self.listenerAboutAuth = Auth.auth().addStateDidChangeListener{ auth, user in
//                if let isEmailVerified = Auth.auth().currentUser?.isEmailVerified {
//                    if isEmailVerified {
//                        self.flow = .emailVerified
//                        if var currentUser = self.currentUser {
//                            currentUser.flow = self.flow.rawValue
//                            let encodedUser = try Firestore.Encoder().encode(currentUser)
//                            try await Firestore.firestore().collection("users").document(currentUser.id).setData(encodedUser, merge: true)
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    func checkEmailVerification3() async {
        do {
            print("DEBUG: checkEmailVerification2")
            await wait()
            try await Auth.auth().currentUser?.reload()
            if let isEmailVerified = Auth.auth().currentUser?.isEmailVerified {
                if isEmailVerified{
                    self.flow = .emailVerified
                }
            }
            if var currentUser = self.currentUser {
                currentUser.flow = self.flow.rawValue
                let encodedUser = try Firestore.Encoder().encode(currentUser)
                try await Firestore.firestore().collection("users").document(currentUser.id).setData(encodedUser, merge: true)
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func signOut() {
        do {
            print("[DEBUG] signOut is called")
            try Auth.auth().signOut()
            //            self.userSession = nil
            self.currentUser = nil
            self.flow = .initialized
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteAccount() {
        print("[DEBUG] deleteAccount is called")
        
        if let currentUser = self.currentUser {
            Firestore.firestore().collection("users").document(currentUser.id).delete() { error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("[DEBUG] deleteAccount is processing. Delete in DB")
                }
            }
        }
        
        let user = Auth.auth().currentUser
        user?.delete { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("DEBUG : delete done")
            }
        }
        self.currentUser = nil
        self.flow = .initialized
    }
    
    func fetchUserData() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        if let currentUser = try? snapshot.data(as: DiptychUser.self) {
            self.currentUser = currentUser
            self.flow = UserFlow(rawValue: currentUser.flow) ?? .initialized
        }
        
    }
    
    func fetchLoverData() async {
        print("DEBUG : fetchLoverData self.lover : \(self.lover)")
        guard let uid = self.currentUser?.loverId else { return }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        if let lover = try? snapshot.data(as: DiptychUser.self) {
            self.lover = lover
            print("DEBUG: fetchLoverData Done")
        }
    }
    
    func setUserData() async {
        do {
            if var currentUser = self.currentUser {
                let encodedUser = try Firestore.Encoder().encode(currentUser)
                try await Firestore.firestore().collection("users").document(currentUser.id).setData(encodedUser, merge: true)
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }
}

// MARK : Coupling
extension UserViewModel {
    func generatedCouplingCode() async throws {
        do {
            self.couplingCode = String(Int.random(in: 10000000 ... 99999999))
        }
    }
    
    func setCouplingCode() async throws {
        do {
            if var currentUser = self.currentUser {
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
                currentUser.flow = "coupled"
                lover.flow = "coupled"
                let encodedCurrentUser = try Firestore.Encoder().encode(currentUser)
                let encodedLover = try Firestore.Encoder().encode(lover)
                try await Firestore.firestore().collection("users").document(currentUser.id).setData(encodedCurrentUser, merge: true)
                try await Firestore.firestore().collection("users").document(lover.id).setData(encodedLover, merge: true)
                self.isCompleted = true
            }
        }
    }
    
    func checkStartDate(startDate: Date) async throws -> Bool {
        do {
            print("DEBUG : checkStartDate -> startDate : \(startDate)")
            await fetchLoverData()
            if let lover = self.lover {
                if lover.startDate == nil {
                    print("DEBUG : lover startDate is nil")
                    setFirstSecond(isFirst: true)
                    return true
                } else {
                    print((lover.startDate?.get(.day) == startDate.get(.day)) && (lover.startDate?.get(.month) == startDate.get(.month)) && (lover.startDate?.get(.year) == startDate.get(.year)))
                    setFirstSecond(isFirst: false)
                    return (lover.startDate?.get(.day) == startDate.get(.day)) && (lover.startDate?.get(.month) == startDate.get(.month)) && (lover.startDate?.get(.year) == startDate.get(.year))
//                    return lover.startDate == startDate
                }
            }
        }
        return false
    }
    
    func setFirstSecond(isFirst: Bool)  {
        if self.currentUser != nil {
            self.currentUser?.isFirst = isFirst
        }
    }
    
    func addCoupleAlbumData() async throws {
        do {
            print("[DEBUG] addCoupleAlbumData start!!!")
            // Add a new document with a generated id.
            var data = DiptychAlbum(id: "")
            var ref: DocumentReference? = nil
//            ref = try Firestore.firestore().collection("albums").addDocument(from: data) { err in
//                if let err = err {
//                    print("Error adding document: \(err)")
//                } else {
//                    data.id = ref!.documentID
//                    // 업데이트된 데이터를 Firestore에 다시 저장
////                    let encodedCoupleAlbum = try Firestore.Encoder().encode(data)
////                    try await Firestore.firestore().collection("albums").document(data.id).setData(encodedCoupleAlbum, merge: true)
//                    try? ref!.setData(from: data) { error in
//                        if let error = error {
//                            print(error.localizedDescription)
//                        } else {
//                            self.coupleAlbum = data
//                            if let coupleAlbum = self.coupleAlbum {
//                                print("Document added with ID: \(coupleAlbum.id)")
//                            }
//                        }
//                    }
//                }
//            }
            var encodedData = try Firestore.Encoder().encode(data)
            ref = try await Firestore.firestore().collection("albums").addDocument(data: encodedData)
            data.id = ref!.documentID
            encodedData = try Firestore.Encoder().encode(data)
            try await ref?.setData(encodedData, merge: true)
            self.coupleAlbum = data
            if let coupleAlbum = self.coupleAlbum {
                print("Document added with ID: \(coupleAlbum.id)")
            }
//            print(data.id)
        }
    }
    
    func setProfileData(name: String, startDate: Date) async throws {
        do {
            print("[DEBUG] setProfileDate -> name: \(name), startDate: \(startDate)")
            if var currentUser = self.currentUser, var lover = self.lover {
                currentUser.name = name
                currentUser.startDate = startDate
                try await addCoupleAlbumData()
                let coupleAlbumId = self.coupleAlbum?.id
                print("[DEBUG] check!!!! coupleAlbumId: \(coupleAlbumId)")
                currentUser.coupleAlbumId = coupleAlbumId
                lover.coupleAlbumId = coupleAlbumId
                currentUser.flow = "completed"
                let encodedCurrentUser = try Firestore.Encoder().encode(currentUser)
                let encodedLover = try Firestore.Encoder().encode(lover)
                try await Firestore.firestore().collection("users").document(currentUser.id).setData(encodedCurrentUser, merge: true)
                try await Firestore.firestore().collection("users").document(lover.id).setData(encodedLover, merge: true)
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    private func wait() async {
        do {
            print("Wait")
            try await Task.sleep(nanoseconds: 2_000_000_000)
            print("Done")
        }
        catch {
            print(error.localizedDescription)
        }
    }
}
