//
//  VisualEffectView.swift
//  Diptych
//
//  Created by 김민 on 2023/07/31.
//

import SwiftUI

struct VisualEffectView: UIViewRepresentable {
    
    let effect: UIVisualEffect

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: effect)
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = effect
    }
}
