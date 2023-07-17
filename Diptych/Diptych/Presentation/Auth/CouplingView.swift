//
//  CouplingView.swift
//  Diptych
//
//  Created by HAN GIBAEK on 2023/07/17.
//

import SwiftUI

struct CouplingView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct CouplingView_Previews: PreviewProvider {
    static var previews: some View {
        CouplingView()
            .environmentObject(AuthenticationViewModel())
    }
}
