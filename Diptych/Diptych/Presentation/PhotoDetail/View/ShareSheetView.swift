//
//  ShareSheetView.swift
//  Diptych
//
//  Created by Nayun Kim on 2023/07/25.
//

import Photos
import SwiftUI

struct ActivityRepresentedViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context _: UIViewControllerRepresentableContext<ActivityRepresentedViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_: UIActivityViewController, context _: UIViewControllerRepresentableContext<ActivityRepresentedViewController>) {}
}

struct ShareSheetView: View {
    @State private var isSharePresented: Bool = false
    @State var image1: UIImage?
    @State var image2: UIImage?
    @State var division: ImageDivisionAxis = .verticalLeft

    var body: some View {
        Button() {
            Task {
                guard await isPhotoLibraryReadWriteAccessGranted else { return }
                self.isSharePresented = true
            }
        } label: {
            Image("icnShareBox")
        }
        .sheet(isPresented: $isSharePresented) {
//            let halfImageSize: CGSize = .init(width: IMAGE_SIZE / 2, height: IMAGE_SIZE)
//            let fullImageSize: CGSize = .init(width: IMAGE_SIZE, height: IMAGE_SIZE)
            
//            if let image1,
//               let image2,
//               let mergedImage = image1.merge(
//                with: image2,
//                division: division,
//                contextSize: fullImageSize,
//                customBaseImageSize: halfImageSize,
//                customAnotherImageSize: halfImageSize) {
//                ActivityRepresentedViewController(activityItems: [mergedImage])
//            }
            // TODO: - 사진과 연결, 추후엔 이미지 1개로 받아올 예정
            ActivityRepresentedViewController(activityItems: [UIImage(named: "diptych_sample1")!])
        }
    }

    var isPhotoLibraryReadWriteAccessGranted: Bool {
        get async {
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)

            // Determine if the user previously authorized read/write access.
            var isAuthorized = status == .authorized

            // If the system hasn't determined the user's authorization status,
            // explicitly prompt them for approval.
            if status == .notDetermined {
                isAuthorized = await PHPhotoLibrary.requestAuthorization(for: .readWrite) == .authorized
            }

            return isAuthorized
        }
    }
}

struct ShareSheetView_Previews: PreviewProvider {
    static var previews: some View {
        ShareSheetView()
    }
}
