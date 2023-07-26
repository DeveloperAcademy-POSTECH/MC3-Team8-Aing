//
//  LottieUIViews.swift
//  Diptych
//
//  Created by 윤범태 on 2023/07/25.
//

import UIKit
import Lottie

class LottieUIViews {
    static let shared = LottieUIViews()
    
    private init() {}
    
    func lottieView(name: String = "LoadingLottie", frame: CGRect, lottieFrame: CGRect = .init(x: 0, y: 0, width: 200, height: 200), backgroundColor: UIColor? = .offWhite) -> UIView {
        let view = UIView(frame: frame)
        
        view.backgroundColor = backgroundColor
        let animationView = LottieAnimationView(name: name)
        
        animationView.frame = .init(x: 0, y: 0, width: 200, height: 200)
        animationView.center = view.center
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        
        // animationView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(animationView)
        // NSLayoutConstraint.activate([
        //     animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
        //     animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        // ])
        
        animationView.play()
        
        return view
    }
}
