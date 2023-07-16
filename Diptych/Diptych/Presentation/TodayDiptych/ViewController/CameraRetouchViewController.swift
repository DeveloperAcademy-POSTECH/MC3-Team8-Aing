//
//  CameraRetouchViewController.swift
//  Diptych
//
//  Created by 윤범태 on 2023/07/16.
//

import UIKit

class CameraRetouchViewController: UIViewController {
    
    @IBOutlet weak var imgViewGuide: UIImageView!
    
    var photoData: Data?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let photoData {
            imgViewGuide.image = UIImage(data: photoData)
        }
        
        setupPhotoGestures()
    }
    
    @objc func imagePinchAction(_ sender: UIPinchGestureRecognizer) {
        imgViewGuide.transform = CGAffineTransformScale(imgViewGuide.transform, sender.scale, sender.scale)
        sender.scale = 1
    }
    
    @objc func imageRotateAction(_ sender: UIRotationGestureRecognizer) {
        switch sender.state {
        case .changed:
            imgViewGuide.transform = imgViewGuide.transform.rotated(by: sender.rotation)
            sender.rotation = 0
        default:
            break
        }
    }
    
    func setupPhotoGestures() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(imagePinchAction(_:)))
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(imageRotateAction(_:)))

        view.addGestureRecognizer(pinchGesture)
        view.addGestureRecognizer(rotateGesture)
    }
}
