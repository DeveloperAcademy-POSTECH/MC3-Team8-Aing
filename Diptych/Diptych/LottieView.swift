//
//  SplashView.swift
//  Diptych
//
//  Created by HAN GIBAEK on 2023/07/24.
//

import Foundation
import Lottie
import SwiftUI
import UIKit

//struct SplashView: View {
//    var animationCompletionHandler: (() -> Void)
//
//    var body: some View {
//        LottieView() { isSplashCompleted in
//            animationCompletionHandler()
////            isSplashCompleted = true
//        }
//    }
//}

struct LottieView: UIViewRepresentable {
    var name: String = "DiptychSplashLogo"
    var loopMode: LottieLoopMode = .playOnce
    var animationCompletionHandler: ((Bool) -> Void)? = nil
    
    init(_ jsonName: String = "DiptychSplashLogo", loopMode: LottieLoopMode = .playOnce, completionHandler: ((Bool) -> Void)?) {
        self.name = jsonName
        self.loopMode = loopMode
        self.animationCompletionHandler = completionHandler
    }

    func makeUIView(context: Context) -> UIView {
        print("[DEBUG] lottie view is called")
        let view = UIView(frame: .zero)

        let animationView = LottieAnimationView()
        let animation = LottieAnimation.named(self.name)
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.play() { isSplashCompleted in
            self.animationCompletionHandler?(isSplashCompleted)
        }

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        print("[DEBUG] lottie view is updated")
    }
}
