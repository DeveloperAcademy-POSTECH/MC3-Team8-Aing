//
//  SecureInputView.swift
//  Diptych
//
//  Created by HAN GIBAEK on 2023/07/27.
//

import SwiftUI

struct SecureInputTextField: View {
    @Binding var isHidden: Bool
    @Binding var password: String

    var isFocused: FocusState<Bool>.Binding
    var prompt: String = ""
    
    var body: some View {
        ZStack(alignment: .trailing) {
            if isHidden {
                SecureField("", text: $password,
                            prompt: Text(prompt)
                    .font(.pretendard(.light, size: 18))
                    .foregroundColor(.dtDarkGray))
                .frame(height: 30)
                .font(.pretendard(.light, size: 18))
                .foregroundColor(.dtDarkGray)
                .keyboardType(.asciiCapable)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .focused(isFocused)
            } else {
                TextField("", text: $password, prompt: Text(prompt)
                    .font(.pretendard(.light, size: 18))
                    .foregroundColor(.dtDarkGray))
                .frame(height: 30)
                .font(.pretendard(.light, size: 18))
                .foregroundColor(.dtDarkGray)
                .keyboardType(.asciiCapable)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .focused(isFocused)
                
            }
        }
    }
}

struct SecureInputView_Previews: PreviewProvider {
    static var previews: some View {
        SecureInputTextField(isHidden: .constant(true),
                        password: .constant("test!1234"),
                        isFocused: FocusState<Bool>().projectedValue)
    }
}
