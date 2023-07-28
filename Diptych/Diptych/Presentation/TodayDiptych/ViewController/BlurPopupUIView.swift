//
//  BlurPopupUIView.swift
//  Diptych
//
//  Created by 윤범태 on 2023/07/29.
//

import UIKit

class BlurPopupUIView: UIView {
    
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
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.layer.cornerCurve = .continuous
        blurEffectView.layer.cornerRadius = 20
        blurEffectView.clipsToBounds = true
        
        self.addSubview(blurEffectView)
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        super.draw(rect)
        
        // let lineWidth = self.frame.width
        // let x: CGFloat = 0
        // let triangleWidth: CGFloat = 10
        // let triangleHeight: CGFloat = 10
        //
        // let roundRectPath = UIBezierPath(roundedRect: CGRect(x: 0,
        //                                                      y: 0,
        //                                                      width: self.bounds.width - lineWidth * 2,
        //                                                      height: self.bounds.height - lineWidth * 2 - triangleHeight),
        //                                  cornerRadius: 10)
        //
        // let trianglePath = UIBezierPath()
        // trianglePath.move(to: CGPoint(x: 0, y: rect.minY))
        // trianglePath.addLine(to: CGPoint(x: x + triangleWidth / 2, y: rect.minY + triangleHeight))
        // trianglePath.addLine(to: CGPoint(x: x + triangleWidth, y: rect.maxY))
        // trianglePath.close()
        // roundRectPath.append(trianglePath)
        // UIColor.red.setFill()
        // roundRectPath.fill()
        
    }

}
