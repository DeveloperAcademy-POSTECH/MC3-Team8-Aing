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
//            HStack {
                if isHiding {
                    SecureField("", text: $password, prompt: Text(prompt)
                        .font(.pretendard(.light, size: 18))
                        .foregroundColor(.darkGray))
                    .font(.pretendard(.light, size: 18))
                    .foregroundColor(.darkGray)
                    .keyboardType(.asciiCapable)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                } else {
                    TextField("", text: $password, prompt: Text(prompt)
                        .font(.pretendard(.light, size: 18))
                        .foregroundColor(.darkGray))
                    .font(.pretendard(.light, size: 18))
                    .foregroundColor(.darkGray)
                    .keyboardType(.asciiCapable)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
//                    .textFieldStyle(.)
                }
//            }
//            HStack {
                Spacer()
                Button {
                    isHiding.toggle()
                } label: {
                    Image(systemName: isHiding ? "eye" : "eye.slash")
                        .foregroundColor(.darkGray)
                }
//            }
        }
    }
}

struct SecureInputView_Previews: PreviewProvider {
    static var previews: some View {
        SecureInputView(password: .constant("test!1234"))
    }
}
