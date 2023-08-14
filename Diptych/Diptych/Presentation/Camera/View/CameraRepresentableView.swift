//
//  CameraRepresentableView.swift
//  Diptych
//
//  Created by 윤범태 on 2023/07/13.
//

import SwiftUI

class ImageCacheViewModel: ObservableObject {
    @Published var firstImage: UIImage?
    @Published var secondImage: UIImage?
    
    init(firstImage: UIImage?, secondImage: UIImage?) {
        self.firstImage = firstImage
        self.secondImage = secondImage
    }
}

struct CameraRepresentableView: UIViewControllerRepresentable {
    @StateObject var viewModel: TodayDiptychViewModel
    @StateObject var imageCacheViewModel: ImageCacheViewModel
    
    func makeUIViewController(context: Context) -> CameraViewController {
        // print("makeUIViewController:", imageCacheViewModel.firstImage, imageCacheViewModel.secondImage)
        let cameraStoryboard = UIStoryboard(name: "CameraStoryboard", bundle: nil)
        guard let viewController = cameraStoryboard.instantiateViewController(withIdentifier: "CameraViewController") as? CameraViewController else {
            return CameraViewController()
        }
        viewController.viewModel = viewModel
        viewController.imageCacheViewModel = imageCacheViewModel
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
    
    typealias UIViewControllerType = CameraViewController
}

// struct CameraRepresentableView_Previews: PreviewProvider {
//     static var viewModel = TodayDiptychViewModel()
//     static var previews: some View {
//         CameraRepresentableView(viewModel: viewModel)
//             .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
//             .previewDisplayName("iPhone 14")
//         CameraRepresentableView(viewModel: viewModel)
//             .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro Max"))
//             .previewDisplayName("iPhone 14 Pro Max")
//     }
// }
