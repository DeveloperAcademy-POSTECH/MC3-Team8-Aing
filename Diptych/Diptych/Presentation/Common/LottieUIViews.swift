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
    
    var label: UILabel!
    
    private init() {}
    
    func lottieView(name: String = "LoadingLottie", frame: CGRect,
                    lottieFrame: CGRect = .init(x: 0, y: 0, width: 200, height: 200),
                    backgroundColor: UIColor? = .offWhite,
                    text: String? = nil) -> UIView {
        let view = UIView(frame: frame)
        
        view.backgroundColor = backgroundColor
        let animationView = LottieAnimationView(name: name)
        
        animationView.frame = .init(x: 0, y: 0, width: 200, height: 200)
        animationView.center = view.center
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        
        view.addSubview(animationView)
        
        if let text {
            label = UILabel(frame: .init(x: 0, y: 0, width: view.frame.width, height: 30))
            label.center = .init(x: view.center.x, y: view.center.y + 67)
            label.textAlignment = .center
            view.addSubview(label)
            
            label.text = text
            label.textColor = .black
            label.font = UIFont(name: "Pretendard-Light", size: 16)
            
            animationView.play()
        }
        
        return view
    }
}
