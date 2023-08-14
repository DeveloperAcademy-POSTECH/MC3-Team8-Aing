//
//  BlurPopupUIView.swift
//  Diptych
//
//  Created by 윤범태 on 2023/07/29.
//

import UIKit

class BlurPopupUIView: UIView {
    
    private var blurEffectView: UIVisualEffectView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.backgroundColor = .clear
        
        let blurEffect = UIBlurEffect(style: .systemMaterialDark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.layer.cornerCurve = .continuous
        blurEffectView.layer.cornerRadius = 20
        blurEffectView.clipsToBounds = true
        
        self.addSubview(blurEffectView)
    }
    
    func setCorner(radius: CGFloat, curve: CALayerCornerCurve = .continuous) {
        blurEffectView.layer.cornerRadius = radius
        blurEffectView.layer.cornerCurve = curve
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        super.draw(rect)
    }

}
