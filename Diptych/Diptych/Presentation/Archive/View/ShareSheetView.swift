//
//  ShareSheetView.swift
//  Diptych
//
//  Created by Nayun Kim on 2023/07/25.
//


import Photos
import SwiftUI

struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context _: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_: UIActivityViewController, context _: UIViewControllerRepresentableContext<ActivityViewController>) {}
}

struct ShareSheetView: View {
    @State private var isSharePresented: Bool = false

    var body: some View {
        // 버튼 크기가 이미지와 딱 맞지 않고 양옆으로 살짝 큼
        // 이것 때문에 패딩으로 조정해둔 간격이랑 맞지 않아서 가운데 정렬이 안 됨
        Button() {
            Task {
                guard await isPhotoLibraryReadWriteAccessGranted else { return }
                self.isSharePresented = true
            }
        } label: {
            Image("upload")
                .foregroundColor(.offBlack)
                .frame(width: 30, height: 30)
        }
        .sheet(isPresented: $isSharePresented) {
            ActivityViewController(activityItems: [UIImage(named: "heart")!])
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
