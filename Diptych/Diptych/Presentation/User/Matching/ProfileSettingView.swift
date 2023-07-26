//
//  ProfileSettingView.swift
//  Diptych
//
//  Created by HAN GIBAEK on 2023/07/20.
//

import SwiftUI

struct ProfileSettingView: View {
    @State var name: String = ""
    @State var selectedDate: Date = Date()
    @State var formattedDateString: String = "기념일"
    @State var isDatePickerShown: Bool = false
    @State var nameWarning: String = ""
    @State var selectedDateWarning: String = ""
    
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var todayDiptychViewModel: TodayDiptychViewModel
    
    var format = "yyyy년 MM월 dd일"
    var body: some View {
        ZStack {
            Color.offWhite
            VStack {
                Spacer()
                    .frame(height: 124)
                Text("연결에 성공했어요\n닉네임과 우리의 시작일을 알려주세요")
                    .font(.pretendard(.light, size: 28))
                Spacer()
                VStack(spacing: 37) {
                    VStack(alignment: .leading) {
                        TextField("", text: $name, prompt: Text("닉네임")
                            .font(.pretendard(.light, size: 18))
                            .foregroundColor(.darkGray))
                        .font(.pretendard(.light, size: 18))
                        .foregroundColor(.darkGray)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        Divider()
                            .overlay(Color.darkGray)
                        Text(nameWarning)
                            .font(.pretendard(.light, size: 12))
                            .foregroundColor(.systemRed)
                    }
                    VStack(alignment: .leading) {
                        HStack {
                            Text(formattedDateString)
                                .font(.pretendard(.light, size: 18))
                                .foregroundColor(.darkGray)
                                .onTapGesture(perform: {
                                    isDatePickerShown.toggle()
                                })
                                .sheet(isPresented: $isDatePickerShown, onDismiss: { formattedDateString = formattedDate(selectedDate, format: format) }, content: {
                                    datePicker
                                })
                            
                        }
                        Divider()
                            .overlay(Color.darkGray)
                        Text(selectedDateWarning)
                            .font(.pretendard(.light, size: 12))
                            .foregroundColor(.systemRed)
                    }
                }
                Spacer()
                Button {
                    selectedDateWarning = ""
                    nameWarning = ""
                    Task {
                        print("selectedDate: \(selectedDate)")
                        if try await userViewModel.checkStartDate(startDate: selectedDate) && checkName(input: name) {
                            try await userViewModel.setProfileData(name: name, startDate: selectedDate)
                            await todayDiptychViewModel.setUserCameraLoactionState()
                        }
                        if try await userViewModel.checkStartDate(startDate: selectedDate) == false {
                            selectedDateWarning = "상대가 설정한 시작일과 다릅니다."
                        }
                        if checkName(input: name) == false {
                            nameWarning = "닉네임은 최대 5글자의 한글이나 최대 6글자의 영어로 만들어주세요."
                        }
                    }
                } label: {
                    Text("딥틱 시작하기")
                        .frame(width: UIScreen.main.bounds.width-30, height:  60)
                        .background(Color.offBlack)
                        .foregroundColor(.offWhite)
                }
                Spacer()
                    .frame(height: 47)
            }
            .padding([.leading, .trailing], 15)
        }
        .ignoresSafeArea()
    }
    
    private var datePicker: some View {
        DatePicker("날짜를 선택하세요", selection: $selectedDate, displayedComponents: .date)
            .datePickerStyle(GraphicalDatePickerStyle())
            .labelsHidden() // 라벨을 숨깁니다.
            .padding()
            .frame(height: 300)
            .background(Color.white)
    }
    
    private func formattedDate(_ date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    private func checkName(input: String) -> Bool {
        let nameRegEx: String = "^[가-힣ㄱ-ㅎㅏ-ㅣ]{1,5}|[A-Za-z]{1,6}$"
        return NSPredicate(format: "SELF MATCHES %@", nameRegEx).evaluate(with: input)
    }
}

struct ProfileSettingView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSettingView()
            .environmentObject(UserViewModel())
    }
}
