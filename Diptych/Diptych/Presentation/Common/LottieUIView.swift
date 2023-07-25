//
//  LottieUIView.swift
//  Diptych
//
//  Created by 윤범태 on 2023/07/25.
//

import UIKit
import Lottie

class LottieUIViews {
    
    static let shared = LottieUIViews()
    
    func lottieView(name: String = "LoadingLottie", frame: CGRect, backgroundColor: UIColor? = UIColor(named: "OffWhite")) -> UIView {
        let view = UIView(frame: frame)
        
        view.backgroundColor = backgroundColor
        let animationView = LottieAnimationView(name: name)
        
        animationView.center = view.center
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        animationView.play()
        
        return view
    }
}
