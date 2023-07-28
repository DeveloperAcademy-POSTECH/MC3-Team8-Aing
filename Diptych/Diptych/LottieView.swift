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

struct LottieView: View {
    var animationCompletionHandler: (() -> Void)? = nil
    var body: some View {
        ZStack {
            Color.offWhite
            AnimationView(completionHandler: animationCompletionHandler)
        }
        .ignoresSafeArea()
    }
}

struct AnimationView: UIViewRepresentable {
    var name: String = "DiptychSplashLogo"
    var loopMode: LottieLoopMode = .playOnce
    var animationCompletionHandler: (() -> Void)? = nil
    
    init(_ jsonName: String = "DiptychSplashLogo3sec", loopMode: LottieLoopMode = .playOnce, completionHandler: (() -> Void)?) {
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
        animationView.play() { _ in
            self.animationCompletionHandler?()
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
