//
//  UserViewModel.swift
//  Diptych
//
//  Created by HAN GIBAEK on 2023/07/20.
//

import Foundation

enum UserFlow: String {
    case initialized = "initialized"
    case signedUp = "signedUp"
    case emailVerified = "emailVerified"
    case coupled = "coupled"
    case completed = "completed"
}

class AuthStateDidChangeListenerHandle {}
class ListenerRegistration {}

@MainActor
class UserViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var currentUser: DiptychUser?
    @Published var flow: UserFlow = .initialized
    
    @Published var couplingCode: String?
    @Published var lover: DiptychUser?
    @Published var coupleAlbum: DiptychAlbum?
    
    var listenerAboutAuth: AuthStateDidChangeListenerHandle?
    var listenerAboutUserData: ListenerRegistration?
    
    init() {
        Task {
            await fetchUserData()
            await fetchLoverData() // 이걸 안 불러주니까 프로필뷰에 상대방 닉네임이 안 떠서 수정했습니다!
            
            // TODO: - [Backend] ListenerAboutUserData
            Task {
                await self.fetchUserData()
                await self.fetchLoverData()
            }
            
            try await generatedCouplingCode()
        }
    }
    
    //MARK: - Singing, Authentication
    func signInWithEmailPassword(email: String, password: String) async throws -> String {
        print("[DEBUG] signInWithEmailPassword -> email: \(email), password: \(password)")
        // TODO: - [Backend] 이메일과 패스워드로 로그인
        let result = ""
        print("[DEBUG] signInWithEmailPassword -> result:  \(result)")
        await fetchUserData()
        await fetchLoverData()
        
        // TODO: - [Backend] 로그인 성공했을 때 리턴
        currentUser?.isFirst = true
        return "fake_login"
    }
    
    func signUpWithEmailPassword(email: String, password: String, name: String) async throws -> String {
        print("DEBUG: signUpWithEmailPassword (Start)")
        // TODO: - [Backend] 이메일과 패스워드로 가입
        let result = ""
        let user = DiptychUser(id: "", email: "", flow: "signedUp", name: name)
        // TODO: - [Backend] 서버에 회원가입한 유저 등록
        print("DEBUG: signUpWithEmailPassword (End)")
        return ""
    }
    
    func sendEmailVerification() async throws {
        print("DEBUG: sendEmailVerification (Start)")
        // TODO: - [Backend] 등록한 이메일로 이메일 인증요청 전송
        self.flow = .signedUp
        print("DEBUG: sendEmailVerification (End)")
    }
    
    func checkEmailVerification() async throws {
        print("DEBUG: checkEmailVerification")
        
        // TODO: - [Backend] 이메일 체크
        /*
         리스너로 추적하면서:
         
         이메일이 인증되었다면
         if isEmailVerified {
             self.flow = .emailVerified
         }
         */
        
        if var currentUser = self.currentUser {
            currentUser.flow = self.flow.rawValue
            // TODO: - [Backend] 서버에 반영
        }
    }
    
    func signOut() {
        print("[DEBUG] signOut is called")
        // TODO: - [Backend] 로그아웃
        self.currentUser = nil
        self.flow = .initialized
    }
    
    func deleteAccount(password: String) async throws {
        print("[DEBUG] deleteAccount is called")
        // TODO: - [Backend] 회원탈퇴
        self.currentUser = nil
        self.flow = .initialized
    }
    
    func fetchUserData() async {
        /*
         uid가 없는 경우
         self.flow = .initialized
         */
        
        // TODO: - [Backend]
        self.currentUser = DiptychUser(id: "", email: "", flow: "")
        // self.flow = currentUser?.flow ?? .initialized
        
        print("DEBUG : fetchUserData self.currentUser : \(self.currentUser)\n")
        print("[DEBUG] flow : \(self.flow)")
    }
    
    func fetchLoverData() async {
        guard let uid = self.currentUser?.loverId else { return }
        // TODO: - [Backend] Lover 설정
        self.lover = DiptychUser(id: "", email: "", flow: "")
        print("DEBUG : fetchLoverData self.lover : \(self.lover)\n")
    }
    
    func fetchCoupleAlbumData() async {
        print("DEBUG : fetchCoupleAlbumData self.coupleAlbum : \(self.coupleAlbum)")
        guard let uid = self.currentUser?.coupleAlbumId else { return }
        // TODO: - [Backend] CoupleAlbum 불러오기
        self.coupleAlbum = .init(id: "")
        print("DEBUG: fetchCoupleAlbum Done")
    }
    
    func setUserData() async {
        // TODO: - [Backend]
    }
}

//MARK: - Coupling
extension UserViewModel {
    func generatedCouplingCode() async throws {
        // TODO: - [Backend] 서버로부터 커플링 코드 받아옴
        var code = "AA"
        self.couplingCode = code
    }
    
    func setCouplingCode() async throws {
        // TODO: - [Backend] 현재 유저 정보에 커플링 코드 저장
    }
    
    func getLoverDataWithCode(code: String) async throws {
        do {
            // .collection("users").whereField("couplingCode", isEqualTo: code).getDocuments()
            // TODO: - [Backend]
            self.lover = .init(id: "", email: "", flow: "")
        }
    }
    
    func setCoupleData(code: String) async throws {
        do {
            try await getLoverDataWithCode(code: code)
            if var currentUser = self.currentUser {
                currentUser.loverId = self.lover?.id
                currentUser.flow = "coupled"
                // TODO: - [Backend] 커플 데이터 세팅
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
    
    func addCoupleAlbumData(startDate: Date) async throws {
        do {
            print("[DEBUG] addCoupleAlbumData start!!!")
            // TODO: - [Backend] Couple Album Data 추가
            var data = DiptychAlbum(id: "")
            data.id = "서버로부터 받아온 아이디"
            data.startDate = startDate
            self.coupleAlbum = .init(id: "")
            if let coupleAlbum = self.coupleAlbum {
                print("Document added with ID: \(coupleAlbum.id)")
            }
        }
    }
    
    func setProfileData(name: String, startDate: Date) async throws {
        print("[DEBUG] setProfileDate -> name: \(name), startDate: \(startDate)")
        
        if var currentUser = self.currentUser, var lover = self.lover {
            currentUser.name = name
            currentUser.startDate = startDate
            try await addCoupleAlbumData(startDate: startDate)
            if let coupleAlbum = self.coupleAlbum {
                print("[DEBUG] check!!!! coupleAlbumId: \(coupleAlbum.id)")
                currentUser.coupleAlbumId = coupleAlbum.id
                lover.coupleAlbumId = coupleAlbum.id
            }
            currentUser.flow = "completed"
            // TODO: - [Backend] 서버에 데이터 추가
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
