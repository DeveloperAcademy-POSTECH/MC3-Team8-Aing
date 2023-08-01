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

enum UserFlow: String {
    case initialized = "initialized"
    case signedUp = "signedUp"
    case emailVerified = "emailVerified"
    case coupled = "coupled"
    case completed = "completed"
}

@MainActor
class UserViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var currentUser: DiptychUser?
    @Published var flow: UserFlow = .initialized
    
    @Published var couplingCode: String?
    @Published var lover: DiptychUser?
    @Published var coupleAlbum: DiptychAlbum?
//    @Published var isCompleted: Bool = false
    
//    @EnvironmentObject var todayDiptychViewModel: TodayDiptychViewModel
    
    var listenerAboutAuth: AuthStateDidChangeListenerHandle?
    var listenerAboutUserData: ListenerRegistration?
    
    init() {
        Task {
            await fetchUserData()
            await fetchLoverData() // 이걸 안 불러주니까 프로필뷰에 상대방 닉네임이 안 떠서 수정했습니다!
            listenerAboutUserData = Firestore.firestore().collection("users").addSnapshotListener() { snapshot, error in
                Task {
                    await self.fetchUserData()
                    await self.fetchLoverData()
                }
            }
//            listenerAboutUserData
            try await generatedCouplingCode()
        }
    }
    
    //MARK: - Singing, Authentication
    func signInWithEmailPassword(email: String, password: String) async throws -> String {
        do {
            print("[DEBUG] signInWithEmailPassword -> email: \(email), password: \(password)")
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            print("[DEBUG] signInWithEmailPassword -> result:  \(result)")
            await fetchUserData()
            await fetchLoverData()
            return ""
        }
        catch {
            print(error.localizedDescription)
            return error.localizedDescription
        }
    }
    
    func signUpWithEmailPassword(email: String, password: String, name: String) async throws -> String {
        do {
            print("DEBUG: signUpWithEmailPassword (Start)")
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let user = DiptychUser(id: result.user.uid, email: email, flow: "signedUp", name: name)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            print("DEBUG: signUpWithEmailPassword (End)")
            return ""
        }
        catch {
            print(error.localizedDescription)
            return error.localizedDescription
        }
    }
    
    func sendEmailVerification() async throws {
        do {
            print("DEBUG: sendEmailVerification (Start)")
            try await Auth.auth().currentUser?.sendEmailVerification()
            print("DEBUG: sendEmailVerification (End)")
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
            print("DEBUG: checkEmailVerification3 (Start)\n")
            await wait()
            print("DEBUG: checkEmailVerification3/ currentUser: \(Auth.auth().currentUser)\n")
            try await Auth.auth().currentUser?.reload()
//            guard let currentUser = Auth.auth().currentUser else {
//                await signInWithEmailPassword(email: self.email, password: <#T##String#>)
//            }
            if let isEmailVerified = Auth.auth().currentUser?.isEmailVerified {
                if isEmailVerified {
                    print("DEBUG: checkEmailVerification3 / before: \(self.currentUser)\n")
                    print("DEBUG: checkEmailVerification3 / self.flow: \(self.flow), self.flow.rawVlaue: \(self.flow.rawValue)\n")
                    if var currentUser = self.currentUser {
                        currentUser.flow = "emailVerified"
                        print("DEBUG: checkEmailVerification3 / mid: \(currentUser)\n")
                        let encodedUser = try Firestore.Encoder().encode(currentUser)
                        print("DEBUG: checkEmailVerification3 / encoded: \(encodedUser)\n")
                        try await Firestore.firestore().collection("users").document(currentUser.id).setData(encodedUser, merge: true)
//                        await fetchUserData()
                        print("DEBUG: checkEmailVerification3 / after: \(self.currentUser)\n")
                    }
                }
            }
            print("DEBUG: checkEmailVerification3 (End)")
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func signOut() {
        do {
            print("[DEBUG] signOut is called")
            try Auth.auth().signOut()
            self.currentUser = nil
            self.flow = .initialized
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteAccount(password: String) async throws {
        do {
            print("[DEBUG] deleteAccount is called")
            
            if let currentUserData = self.currentUser, let currentUserAuth = Auth.auth().currentUser {
                print("assigning is done")
                let credential = EmailAuthProvider.credential(withEmail: currentUserData.email, password: password)
                try await currentUserAuth.reauthenticate(with: credential)
                try await currentUserAuth.delete()
//                currentUserAuth.delete() { error in
//                    print(error?.localizedDescription)
//                }
                print("DEBUG : auth account delete done")
                try await Firestore.firestore().collection("users").document(currentUserData.id).delete()
                print("DEBUG : user data delete done")
                
//                print("currentUserAuth : \(currentUserAuth)")
                
//                try await currentUserAuth.delete()
//                let user = Auth.auth().currentUser
//                user?.delete(completion: { error in
//                    guard error == nil else {
//                        print("delete -> error -> \(error?.localizedDescription)")
//                        return
//                    }
//                    return
//                })
                
                
                self.currentUser = nil
                self.flow = .initialized
            } else {
                print("something is wrong")
                print("\t self.currentUser : \(self.currentUser)")
                print("\t self.currentUser : \(Auth.auth().currentUser)")
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchUserData() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.flow = .initialized
            return }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        if let currentUser = try? snapshot.data(as: DiptychUser.self) {
            self.currentUser = currentUser
            self.flow = UserFlow(rawValue: currentUser.flow) ?? .initialized
        }
        print("DEBUG : fetchUserData self.currentUser : \(self.currentUser)\n")
        print("[DEBUG] flow : \(self.flow)")
    }
    
    func fetchLoverData() async {
        guard let uid = self.currentUser?.loverId else { return }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        if let lover = try? snapshot.data(as: DiptychUser.self) {
            self.lover = lover
        }
        print("DEBUG : fetchLoverData self.lover : \(self.lover)\n")
    }
    
    func fetchCoupleAlbumData() async {
        print("DEBUG : fetchCoupleAlbumData self.coupleAlbum : \(self.coupleAlbum)")
        guard let uid = self.currentUser?.coupleAlbumId else { return }
        guard let snapshot = try? await Firestore.firestore().collection("albums").document(uid).getDocument() else { return }
        if let coupleAlbum = try? snapshot.data(as: DiptychAlbum.self) {
            self.coupleAlbum = coupleAlbum
            print("DEBUG: fetchCoupleAlbum Done")
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

//MARK: - Coupling
extension UserViewModel {
    func generatedCouplingCode() async throws {
        do {
            guard let snapshot = try? await Firestore.firestore().collection("users").getDocuments() else {
                print("ERROR: (generatedCouplingCode) getAllusers")
                return
            }
            var codes: [Any] = []
            for document in snapshot.documents {
                if let code = document.get("couplingCode") {
                    codes.append(code)
                }
            }
//            self.couplingCode = String(Int.random(in: 10000000 ... 99999999))
            var code = ""
            repeat {
                code = String(Int.random(in: 10000000 ... 99999999))
            } while codes.contains(where: { element in return String(describing: element) == code})
            
            self.couplingCode = code
            if var currentUser = self.currentUser {
                currentUser.couplingCode = code
                let encodedCurrentUser = try Firestore.Encoder().encode(currentUser)
                try await Firestore.firestore().collection("users").document(currentUser.id).setData(encodedCurrentUser, merge: true)
            }
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
            for document in snapshot.documents {
                if let id = document.get("loverId"), let currentUserId = self.currentUser?.id {
                    print("id itself : \(id)")
                    print("id to String : \(String(describing: id))")
                    if String(describing: id) == currentUserId {
                        self.lover = try document.data(as: DiptychUser.self)
                        break
                    }
                } else {
                    self.lover = try document.data(as: DiptychUser.self)
                    break
                }
            }
//            if snapshot.documents.count == 1 {
//                self.lover = try snapshot.documents[0].data(as: DiptychUser.self)
//            }
        }
    }
    
    func setCoupleData(code: String) async throws {
        do {
            try await getLoverDataWithCode(code: code)

//            if var currentUser = self.currentUser, var lover = self.lover {
            if var currentUser = self.currentUser {
                currentUser.loverId = self.lover?.id
//                lover.loverId = self.currentUser?.id

                currentUser.flow = "coupled"
//                lover.flow = "coupled"
                let encodedCurrentUser = try Firestore.Encoder().encode(currentUser)
//                let encodedLover = try Firestore.Encoder().encode(lover)
                try await Firestore.firestore().collection("users").document(currentUser.id).setData(encodedCurrentUser, merge: true)
//                try await Firestore.firestore().collection("users").document(lover.id).setData(encodedLover, merge: true)
//                self.isCompleted = true
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
            var data = DiptychAlbum(id: "")
            var ref: DocumentReference? = nil
            var encodedData = try Firestore.Encoder().encode(data)
            ref = try await Firestore.firestore().collection("albums").addDocument(data: encodedData)
            data.id = ref!.documentID
            data.startDate = Date()
            encodedData = try Firestore.Encoder().encode(data)
            try await ref?.setData(encodedData, merge: true)
            self.coupleAlbum = data
            if let coupleAlbum = self.coupleAlbum {
                print("Document added with ID: \(coupleAlbum.id)")
            }
        }
    }
    
    func setProfileData(name: String, startDate: Date) async throws {
        do {
            print("[DEBUG] setProfileDate -> name: \(name), startDate: \(startDate)")
            if var currentUser = self.currentUser, var lover = self.lover {
                currentUser.name = name
                currentUser.startDate = startDate
                try await addCoupleAlbumData()
                if let coupleAlbum = self.coupleAlbum {
                    print("[DEBUG] check!!!! coupleAlbumId: \(coupleAlbum.id)")
                    currentUser.coupleAlbumId = coupleAlbum.id
                    lover.coupleAlbumId = coupleAlbum.id
                }
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
            try await Task.sleep(nanoseconds: 1_000_000_000)
            print("Done")
        }
        catch {
            print(error.localizedDescription)
        }
    }
}
