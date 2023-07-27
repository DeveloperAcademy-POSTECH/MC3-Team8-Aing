//
//  SecureInputView.swift
//  Diptych
//
//  Created by HAN GIBAEK on 2023/07/27.
//

import SwiftUI

struct SecureInputView: View {
    @Binding var isHidden: Bool
    @Binding var password: String
    var isFocused: FocusState<Bool>.Binding
    
    var prompt: String = ""
    
    var body: some View {
        ZStack(alignment: .trailing) {
            if isHidden {
                SecureField("", text: $password, prompt: Text(prompt)
                    .font(.pretendard(.light, size: 18))
                    .foregroundColor(.darkGray))
                .frame(height: 30)
                .font(.pretendard(.light, size: 18))
                .foregroundColor(.darkGray)
                .keyboardType(.asciiCapable)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .focused(isFocused)
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
                .focused(isFocused)
//                .padding(.bottom, 7)
//                .overlay(
//                    Rectangle().frame(width: nil, height: 1, alignment: .bottom)
//                        .foregroundColor(Color.darkGray),
//                    alignment: .bottom
//                )
                //                .background(Color.yellow)
                //                .frame(height: 100)
                
            }
        }
    }
}

struct SecureInputView_Previews: PreviewProvider {
    static var previews: some View {
        SecureInputView(isHidden: .constant(true), password: .constant("test!1234"), isFocused: FocusState<Bool>().projectedValue)
    }
}
