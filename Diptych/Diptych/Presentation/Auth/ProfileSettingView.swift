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
    
    @EnvironmentObject var userViewModel: UserViewModel
    
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
                        TextField("닉네임", text: $name)
                            .font(.pretendard(.light, size: 18))
                            .foregroundColor(.darkGray)
                        Divider()
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
                    }
                }
                Spacer()
                Button {
                    
                } label: {
                    Text("딥틱 시작하기")
                        .frame(width: UIScreen.main.bounds.width-30, height:  60)
                        .background(Color.offBlack)
                        .foregroundColor(.offWhite)
                }
                Spacer()
                    .frame(height: 55)
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
}

struct ProfileSettingView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSettingView()
    }
}
