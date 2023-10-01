//
//  NavigationBackButton.swift
//  Diptych
//
//  Created by 김민 on 2023/10/01.
//

import SwiftUI

struct NavigationBackButton: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.backward")
                .foregroundColor(.offBlack)
        }
    }
}

struct NavigationBackButton_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBackButton()
    }
}
