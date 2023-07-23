//
//  CameraViewController.swift
//  Diptych
//
//  Created by 윤범태 on 2023/07/13.
//

import UIKit
import AVFoundation
import Photos
import PhotosUI

enum ImageDivisionAxis {
    /// 세로선 왼쪽에 검은칠
    case verticalLeft
    /// 세로선 오른쪽에 검은칠
    case verticalRight
    /// 가로선 위에 검은칠
    case horizontalUp
    /// 가로선 아래에 검은칠
    case horizontalDown
    
    func rect(squareSideLength length: CGFloat) -> CGRect {
        var startPoint: CGPoint {
            switch self {
            case .verticalLeft, .horizontalUp:
                return .zero
            case .verticalRight:
                return .init(x: length / 2, y: 0)
            case .horizontalDown:
                return .init(x: 0, y: length / 2)
            }
        }
        
        var size: CGSize {
            switch self{
            case .verticalLeft, .verticalRight:
                return .init(width: length / 2, height: length)
            case .horizontalUp, .horizontalDown:
                return .init(width: length, height: length / 2)
            }
        }
        
        return .init(origin: startPoint, size: size)
    }
}

class CameraViewController: UIViewController {
    
    enum CurrentMode {
        case camera, retouch
    }
    
    // MARK: - 스토리보드로부터 @IBOutlet으로 연결된 컴포넌트 변수
    @IBOutlet weak var lblTopic: UILabel!
    @IBOutlet weak var scrollViewImageContainer: UIScrollView!
    @IBOutlet weak var imgViewGuideOverlay: UIImageView!
    @IBOutlet weak var btnCloseBack: UIButton!
    @IBOutlet weak var btnFlash: UIButton!
    @IBOutlet weak var btnChangePosition: UIButton!
    @IBOutlet weak var btnPhotoLibrary: UIButton!
    @IBOutlet weak var btnShutter: UIButton!
    
    @IBOutlet weak var viewOverlay: UIView!
    @IBOutlet weak var tempSegDirection: UISegmentedControl!
    
    // MARK: - Constants
    let RESIZE_WIDTH: CGFloat = 2048
    let JPEG_COMPRESSION_QUALITY: CGFloat = 1.0
    
    // MARK: - Vars
    var viewModel: TodayDiptychViewModel?
    
    var previewLayer: AVCaptureVideoPreviewLayer!
    var captureSession: AVCaptureSession!
    var backCameraInput: AVCaptureDeviceInput!
    var frontCameraInput: AVCaptureDeviceInput!
    
    var photoSettings: AVCapturePhotoSettings {
        // NSInvalidArgumentException', reason: '*** -[AVCapturePhotoOutput capturePhotoWithSettings:delegate:]
        // Settings may not be re-used'
        
        var settings = AVCapturePhotoSettings()
        // photoOutput 의 codec의 hevc 가능시 photoSettings의 codec을 hevc로 설정하는 코드입니다.
        // hevc 불가능한 경우에는 jpeg codec을 사용하도록 합니다.
        if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        } else {
            settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        }
        
        return settings
    }
    
    var photoOutput: AVCapturePhotoOutput = AVCapturePhotoOutput()
    var currentMode: CurrentMode = .camera {
        didSet {
            switch currentMode {
            case .camera:
                changeCameraMode()
            case .retouch:
                changeRetouchMode()
            }
        }
    }
    
    var originalOverlayFrame: CGRect!
    
    var photoData: Data?
    var pickerViewController: PHPickerViewController!
    
    private var pinchGesture: UIPinchGestureRecognizer!
    private var rotationGesture: UIRotationGestureRecognizer!
    private var panGesture: UIPanGestureRecognizer!
    
    private var currentAxis: ImageDivisionAxis = .verticalLeft {
        didSet {
            shrinkOverlayByAxis(currentAxis)
        }
    }
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImagePicker()
        
        PHPhotoLibrary.requestAuthorization { status in }
        
        // TODO: - Limited 위한 커스텀 뷰를 또 만들어야 하는가?
        // https://zeddios.tistory.com/620
        // let fetchOptions = PHFetchOptions()
        // let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        //
        // for i in 0...(allPhotos.count - 1) {
        //     print(allPhotos.object(at: i))
        // }
        
        DispatchQueue.main.async { [unowned self] in
            viewOverlay.layoutIfNeeded()
            originalOverlayFrame = viewOverlay.frame
            
            shrinkOverlayByAxis(.verticalLeft)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkCameraPermissions()
        setupPhotoCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 뷰모델 정보 가져오기 - 별도 함수로 분리
        guard let viewModel else {
            return
        }
        
        lblTopic.text = viewModel.question
        DispatchQueue.main.async { [unowned self] in
            print("isFirst?", viewModel.isFirst)
            currentAxis = viewModel.isFirst ? .verticalLeft : .verticalRight
            
            print(viewModel.currentUser?.id,
                  viewModel.todayPhoto)
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func btnActShutter(_ sender: UIButton) {
        switch currentMode {
        case .camera:
            guard !UIDevice.current.isSimulator else {
                print("시뮬레이터에서는 작동하지 않습니다.")
                return
            }
            
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        case .retouch:
            // guard let data = imgViewGuideOverlay.image?.jpegData(compressionQuality: 1) else {
            //     debugPrint("\(#function): Image data is nil")
            //     return
            // }
            //
            // savePhotoToLibrary(data: data)
            
            guard let transformedImage = transformImageBasedOnContainerView(
                imageView: imgViewGuideOverlay,
                containerView: scrollViewImageContainer) else {
                return
            }
            
            let resizedImage = transformedImage.resize(width: RESIZE_WIDTH, height: RESIZE_WIDTH)
            
            // 가이드라인에 따라 사진 자르기
            let cropRect: CGRect = currentAxis.rect(squareSideLength: RESIZE_WIDTH)
            let croppedImage: CGImage? = resizedImage.cgImage!.cropping(to: cropRect)
            let data = UIImage(cgImage: croppedImage!, scale: 1, orientation: transformedImage.imageOrientation).jpegData(compressionQuality: JPEG_COMPRESSION_QUALITY)
            
            // savePhotoToLibrary(data: data!) {_, _ in
            //     DispatchQueue.main.async {
            //         self.dismiss(animated: true)
            //     }
            // }
            /*
             1. 앨범 아이디로 photos를 찾음
             .collection("photos")
             .where("albumId", "==", "3ZtcHka4I3loqa7Xopc4")
             
             2. 오늘 날짜 or Content ID를 찾음
             .collection("photos")
             .where("contentId", "==", "bDKIjB5XdlVc8anNbp7Q")
             
                2-1. contentId 비어있으면 하나 생성??
                2-2. contentId 있다면 3번으로
             
             3. 앨범 아이디와 Content ID가 일치하는 곳 또는 새 컨텐츠에 정보 업데이트
              -
             */
            
            Task {
                guard let isFirst = viewModel?.currentUser?.isFirst else {
                    return
                }
                
                print("파일 업로드 시작....")
                let url = try await FirebaseManager.shared.upload(data: data!, withName: "test_\(Date())")
                print("파일 업로드 끝:", url?.absoluteString ?? "unknown URL")
                
                guard let url else {
                    print("url이 존재하지 않습니다.")
                    return
                }
                
                var dictionary: [String: Any]!
                if let todayPhoto = viewModel?.todayPhoto {
                    print("todayPhoto!:", todayPhoto.photoFirst, todayPhoto.photoSecond, isFirst, todayPhoto.photoSecond.isEmpty,  todayPhoto.photoFirst.isEmpty)
                    dictionary = [
                        "date": Date(),
                        "thumbnail": "\(Date())",
                        "\(UUID().uuidString)": url.absoluteString,
                        "isCompleted": isFirst ? !todayPhoto.photoSecond.isEmpty : !todayPhoto.photoFirst.isEmpty
                    ]
                } else {
                    print("TodayPhoto is nil")
                    // TODO: - todayPhoto가 nil인 경우 어떻게 해야 되는지?
                    
                    self.dismiss(animated: true)
                    return
                }
                
                print("정보 업로드 시작....")
                try await FirebaseManager.shared.updateValue(collectionPath: "photos", documentId: "aaa", dictionary: dictionary)
                print("정보 업로드 끝")
                self.dismiss(animated: true)
            }
        }
    }
    
    @IBAction func btnActChangeCameraPosition(_ sender: UIButton) {
        guard !UIDevice.current.isSimulator else {
            print("시뮬레이터에서는 작동하지 않습니다.")
            return
        }
        
        changeCameraPosition()
    }
    
    @IBAction func btnActDismissView(_ sender: UIButton) {
        switch currentMode {
        case .camera:
            dismiss(animated: true)
        case .retouch:
            resetImageViewTransform()
            currentMode = .camera
        }
    }
    
    @IBAction func btnToggleTorch(_ sender: UIButton) {
        guard !UIDevice.current.isSimulator else {
            print("시뮬레이터에서는 작동하지 않습니다.")
            return
        }
        
        toggleTorch()
    }
    
    @IBAction func btnActLoadPhotoFromLibrary(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.present(self.pickerViewController, animated: true)
        }
        
        // PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self) { identifiers in
        //     for newlySelectedAssetIdentifier in identifiers {
        //         // Stage asset for app interaction.
        //         print(newlySelectedAssetIdentifier)
        //     }
        // }
    }
    
    @IBAction func tempSegActChangeGuideAxis(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            currentAxis = .verticalLeft
        case 1:
            currentAxis = .verticalRight
        case 2:
            currentAxis = .horizontalUp
        case 3:
            currentAxis = .horizontalDown
        default:
            break
        }
    }
    
    // MARK: - Navigations
    
    // override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //     switch segue.identifier {
    //     case "RetouchCameraSegue":
    //         let data = sender as! Data
    //         let destination = segue.destination as! CameraRetouchViewController
    //         destination.modalPresentationStyle = .fullScreen
    //         destination.photoData = data
    //     default:
    //         break
    //     }
    // }
    
    // MARK: - Camera Functions
    
    func setupPhotoCamera() {
        // 메인 스레드에서 실행 방지 - startRunning()이 차단 호출(block call)이기 때문
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            // 세션 초기화
            captureSession = AVCaptureSession()
            // 구성(configuration) 시작
            captureSession.beginConfiguration()
            
            // session specific configuration
            // 세션 프리셋을 설정하기 전에 지원 여부를 확인해야 합니다.
            if captureSession.canSetSessionPreset(.photo) {
                captureSession.sessionPreset = .photo
            }
            
            // 사용 가능한 경우 세션이 자동으로 광역 색상을 사용해야 하는지 여부를 지정합니다.
            captureSession.automaticallyConfiguresCaptureDeviceForWideColor = true

            // 후면 카메라 디바이스
            guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                return
            }

            // 전면 카메라 디바이스
            guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
                return
            }
            
            // 생성된 captureSession에 device input을 생성 및 연결하고,
            // device output을 연결하는 코드입니다.
            do {
                backCameraInput = try AVCaptureDeviceInput(device: backCamera)
                frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                    
                // captureSession에 cameraInput을 받도록 설정
                captureSession.addInput(backCameraInput)
            } catch  {
                debugPrint("Camera Input Error:", error.localizedDescription)
            }
            
            // 고해상도의 이미지 캡처 가능 설정
            // 16.0에서 deprecated됨
            if #unavailable(iOS 16.0) {
                photoOutput.isHighResolutionCaptureEnabled = true
            }
            
            // CaptureSession에 photoOutput을 추가
            captureSession.addOutput(photoOutput)
            
            // Preview 화면 추가
            DispatchQueue.main.async { [unowned self] in
                setCameraPreview()
            }
            
            // commit configuration: 단일 atomic 업데이트에서 실행 중인 캡처 세션의 구성에 대한 하나 이상의 변경 사항을 커밋합니다.
            captureSession.commitConfiguration()
            // 캡처 세션 실행
            captureSession.startRunning()
            
            // TODO: - startRunning이 시작되면 UI/UX 동작되게 하기
        }
    }
    
    func setCameraPreview() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        view.layer.insertSublayer(previewLayer, above: scrollViewImageContainer.layer)
        previewLayer.frame = scrollViewImageContainer.frame
        previewLayer.videoGravity = .resizeAspectFill   // 프레임 크기에 맞춰 리사이즈(비율 깨지지 않음)
    }
    
    func savePhotoToLibrary(data: Data, completionHandler: ((Bool, Error?) -> Void)? = nil) {
        // 권한 요청
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                return
            }
            
            // 사진 앨범에 저장
            PHPhotoLibrary.shared().performChanges({
                let creationRequest = PHAssetCreationRequest.forAsset()
                creationRequest.addResource(with: .photo, data: data, options: nil)
            }, completionHandler: completionHandler)
        }
    }
    
    func setupPhotoGestures() {
        if pinchGesture == nil && rotationGesture == nil && panGesture == nil {
            pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(imagePinchAction(_:)))
            rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(imageRotateAction(_:)))
            panGesture = UIPanGestureRecognizer(target: self, action: #selector(imagePanAction(_:)))
            panGesture.minimumNumberOfTouches = 2
        }
        
        addRetouchImageGestures()
    }
    
    private func addRetouchImageGestures() {
        guard let pinchGesture, let rotationGesture, let panGesture else {
            return
        }
        
        view.addGestureRecognizer(pinchGesture)
        view.addGestureRecognizer(rotationGesture)
        view.addGestureRecognizer(panGesture)
    }
    
    private func removeRetouchImageGestures() {
        guard let pinchGesture, let rotationGesture, let panGesture else {
            return
        }
        
        view.removeGestureRecognizer(pinchGesture)
        view.removeGestureRecognizer(rotationGesture)
        view.removeGestureRecognizer(panGesture)
    }
    
    func changeRetouchMode() {
        setupPhotoGestures()
        
        toggleTorch(forceOff: true)
        previewLayer?.isHidden = true
        
        btnFlash.isHidden = true
        btnChangePosition.isHidden = true
        btnPhotoLibrary.isHidden = true
        
        btnCloseBack.setImage(UIImage(named: "imgBackButton"), for: .normal)
        btnShutter.setImage(UIImage(named: "imgCircleCheckButton"), for: .normal)
    }
    
    func changeCameraMode() {
        removeRetouchImageGestures()
        
        btnFlash.isHidden = false
        btnChangePosition.isHidden = false
        btnPhotoLibrary.isHidden = false
        
        btnCloseBack.setImage(UIImage(named: "imgCloseButton"), for: .normal)
        btnShutter.setImage(UIImage(named: "imgShutterButton"), for: .normal)
        
        previewLayer?.isHidden = false
    }
    
    func resetImageViewTransform() {
        imgViewGuideOverlay.transform = .identity
    }
    
    func setupImagePicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        pickerViewController = PHPickerViewController(configuration: configuration)
        pickerViewController.delegate = self
    }
    
    /// 검은색 오버레이 뷰를 방향에 맞춰 분할
    func shrinkOverlayByAxis(_ direction: ImageDivisionAxis) {
        switch direction {
        case .verticalLeft:
            viewOverlay.frame = CGRect(x: originalOverlayFrame.maxX - (originalOverlayFrame.width / 2),
                                       y: originalOverlayFrame.minY,
                                       width: originalOverlayFrame.size.width / 2,
                                       height: originalOverlayFrame.size.height)
        case .verticalRight:
            viewOverlay.frame = CGRect(x: originalOverlayFrame.minX,
                                       y: originalOverlayFrame.minY,
                                       width: originalOverlayFrame.width / 2,
                                       height: originalOverlayFrame.height)
        case .horizontalUp:
            viewOverlay.frame = CGRect(x: originalOverlayFrame.minX,
                                       y: originalOverlayFrame.minY + (originalOverlayFrame.height / 2),
                                       width: originalOverlayFrame.size.width,
                                       height: originalOverlayFrame.size.height / 2)
        case .horizontalDown:
            viewOverlay.frame = CGRect(x: originalOverlayFrame.minX,
                                       y: originalOverlayFrame.minY,
                                       width: originalOverlayFrame.size.width,
                                       height: originalOverlayFrame.size.height / 2)
        }
    }
    
    // MARK: - OBJC Methods
    
    @objc func imagePinchAction(_ sender: UIPinchGestureRecognizer) {
        imgViewGuideOverlay.transform = CGAffineTransformScale(imgViewGuideOverlay.transform, sender.scale, sender.scale)
        sender.scale = 1
    }
    
    @objc func imageRotateAction(_ sender: UIRotationGestureRecognizer) {
        switch sender.state {
        case .changed:
            imgViewGuideOverlay.transform = imgViewGuideOverlay.transform.rotated(by: sender.rotation)
            sender.rotation = 0
        default:
            break
        }
    }
    
    @objc func imagePanAction(_ sender: UIPanGestureRecognizer) {
        // Store current transfrom of UIImageView
        let transform = imgViewGuideOverlay.transform
        
        // Initialize imageView.transform
        imgViewGuideOverlay.transform = CGAffineTransform.identity
        
        // Move UIImageView
        let point: CGPoint = sender.translation(in: imgViewGuideOverlay)
        let movedPoint = CGPoint(x: imgViewGuideOverlay.center.x + point.x,
                                 y: imgViewGuideOverlay.center.y + point.y)
        imgViewGuideOverlay.center = movedPoint
        
        // Revert imageView.transform
        imgViewGuideOverlay.transform = transform
        
        // Reset translation
        sender.setTranslation(CGPoint.zero, in: imgViewGuideOverlay)
    }
    
    // MARK: - Permissions
    
    func checkCameraPermissions() {
        let cameraAuthStatus =  AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        switch cameraAuthStatus {
        case .authorized:
            return
        case .denied:
            // TODO: - 카메라 권한 허용 유도하는 기능
            abort()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { authorized in
                if !authorized {
                    // TODO: - 카메라 권한 허용 유도하는 기능
                    abort()
                }
            })
        case .restricted:
            // 시스템 에러
            abort()
        @unknown default:
            fatalError()
        }
    }
    
    func toggleTorch(forceOff: Bool = false) {
        guard let device = AVCaptureDevice.default(for: .video) else {
            return
        }
        guard device.hasTorch else {
            return
        }
        
        do {
            try device.lockForConfiguration()
            
            if device.torchMode == AVCaptureDevice.TorchMode.on || forceOff {
                device.torchMode = .off
            } else {
                try device.setTorchModeOn(level: 1.0)
            }
            
            device.unlockForConfiguration()
        } catch {
            print(#function, error.localizedDescription)
        }
    }
    
    func changeCameraPosition() {
        captureSession.beginConfiguration()
        
        switch captureSession.inputs[0] {
        case backCameraInput:
            // 후면에서 전면으로 전환
            captureSession.removeInput(backCameraInput)
            captureSession.addInput(frontCameraInput)
        case frontCameraInput:
            // 전면에서 후면으로 전환
            captureSession.removeInput(frontCameraInput)
            captureSession.addInput(backCameraInput)
        default:
            break
        }
        
        // commitConfiguration : captureSession 의 설정 변경이 완료되었음을 알리는 함수.
        captureSession.commitConfiguration()
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    /// capturePhoto 이후에 capture process 가 완료된 이미지를 저장하는 메서드
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            print("Error capturing photo:", error!.localizedDescription)
            return
        }
        
        guard let data = photo.fileDataRepresentation() else {
            print("Error: photo.fileDataRepresentation() is nil.")
            return
        }
        
        // previewLayer.removeFromSuperlayer()
        // let originalImage = UIImage(data: data)
        // imgViewGuideOverlay.image = originalImage
        //
        // setupPhotoGestures()
        
        currentMode = .retouch
        imgViewGuideOverlay.image = UIImage(data: data)
        
        savePhotoToLibrary(data: data)
        // performSegue(withIdentifier: "RetouchCameraSegue", sender: data)
    }
}

extension CameraViewController: PHPickerViewControllerDelegate, PHPhotoLibraryChangeObserver {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                guard let image = image as? UIImage else {
                    return
                }
                
                DispatchQueue.main.async {
                    self.imgViewGuideOverlay.image = image
                    self.currentMode = .retouch
                }
            }
        }
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {}
}
