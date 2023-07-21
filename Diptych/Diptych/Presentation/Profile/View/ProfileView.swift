//
//  ProfileView.swift
//  Diptych
//
//  Created by 김민 on 2023/07/13.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        VStack{
            Spacer()
            Text("ProfileView")
            Spacer()
            HStack {
                Button{
                    userViewModel.signOut()
                } label: {
                    Text("로그아웃")
                        .padding()
                        .background(Color.offBlack)
                        .foregroundColor(.offWhite)
                }
                Button{
                    userViewModel.deleteAccount()
                } label: {
                    Text("회원탈퇴")
                        .padding()
                        .background(Color.offBlack)
                        .foregroundColor(.offWhite)
                }
            }
            Spacer()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
