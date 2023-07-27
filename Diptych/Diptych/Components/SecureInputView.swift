//
//  SecureInputView.swift
//  Diptych
//
//  Created by HAN GIBAEK on 2023/07/27.
//

import SwiftUI

struct SecureInputView: View {
    @State private var isHiding: Bool = false
    @Binding var password: String
    var prompt: String = ""
    
    var body: some View {
        ZStack(alignment: .trailing) {
            if isHiding {
                SecureField("", text: $password, prompt: Text(prompt)
                    .font(.pretendard(.light, size: 18))
                    .foregroundColor(.darkGray))
                .frame(height: 30)
                .font(.pretendard(.light, size: 18))
                .foregroundColor(.darkGray)
                .keyboardType(.asciiCapable)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
//                .padding(.bottom, 7)
//                .overlay(
//                    Rectangle().frame(width: nil, height: 1, alignment: .bottom)
//                        .foregroundColor(Color.darkGray),
//                    alignment: .bottom
//                )
//                .frame(height: 50)
                //                .background(Color.yellow)
                //                .frame(height: 100)
            } else {
                TextField("", text: $password, prompt: Text(prompt)
                    .font(.pretendard(.light, size: 18))
                    .foregroundColor(.darkGray))
                .frame(height: 30)
                .font(.pretendard(.light, size: 18))
                .foregroundColor(.darkGray)
                .keyboardType(.asciiCapable)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
//                .padding(.bottom, 7)
//                .overlay(
//                    Rectangle().frame(width: nil, height: 1, alignment: .bottom)
//                        .foregroundColor(Color.darkGray),
//                    alignment: .bottom
//                )
                //                .background(Color.yellow)
                //                .frame(height: 100)
                
            }
            Spacer()
            Button {
                isHiding.toggle()
            } label: {
                Image(systemName: isHiding ? "eye" : "eye.slash")
                    .foregroundColor(.darkGray)
            }
        }
    }
}

struct SecureInputView_Previews: PreviewProvider {
    static var previews: some View {
        SecureInputView(password: .constant("test!1234"))
    }
}
