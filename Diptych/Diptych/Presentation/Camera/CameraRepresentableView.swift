//
//  CameraRepresentableView.swift
//  Diptych
//
//  Created by 윤범태 on 2023/07/13.
//

import SwiftUI

struct CameraRepresentableView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CameraViewController {
        let cameraStoryboard = UIStoryboard(name: "CameraStoryboard", bundle: nil)
        return cameraStoryboard.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = CameraViewController
    
}

struct CameraRepresentableView_Previews: PreviewProvider {
    static var previews: some View {
        CameraRepresentableView()
    }
}
