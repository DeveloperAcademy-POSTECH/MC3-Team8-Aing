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
    @IBOutlet weak var btnQuestionMark: UIButton!
    
    @IBOutlet weak var viewOverlay: UIView!
    @IBOutlet weak var tempSegDirection: UISegmentedControl!
    @IBOutlet weak var imgGuidelineDashed: UIImageView!
    @IBOutlet weak var viewLottieLoading: UIView!
    
    // MARK: - Vars
    var viewModel: TodayDiptychViewModel?
    var imageCacheViewModel: ImageCacheViewModel?
    
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
    
    private var lottieViewForUpload: UIView!
    private var isShowHelpPopup: Bool = false {
        didSet {
            if isShowHelpPopup {
                btnQuestionMark.setImage(.init(named: "imgQuestionMarkButton"), for: .normal)
            } else {
                btnQuestionMark.setImage(.init(named: "imgQuestionMarkButtonOff"), for: .normal)
            }
        }
    }
    
    // MARK: - Lazy vars
    private lazy var blurPopupView: BlurPopupUIView = {
        let xMargin: CGFloat = 15
        let yMargin: CGFloat = 9
        
        let frame = CGRect(x: scrollViewImageContainer.frame.minX + xMargin,
                           y: scrollViewImageContainer.frame.minY - yMargin,
                           width: scrollViewImageContainer.frame.width - xMargin * 2,
                           height: scrollViewImageContainer.frame.height + yMargin * 2 + 20)
        return BlurPopupUIView(frame: frame)
    }()
    
    private lazy var popupDescLabel: UILabel = {
        let descLabel = UILabel(frame: .init(x: 10, y: 10, width: blurPopupView.frame.width - 20, height: 50))
        descLabel.text = "얼굴 가이드라인에 맞춰 최대한 정면을 보고 찍어보세요!\n완성된 사진은 두 손가락을 이용해 움직일 수 있어요"
        descLabel.font = .init(name: "Pretendard-Light", size: 15)
        descLabel.numberOfLines = 0
        descLabel.textAlignment = .center
        descLabel.textColor = .offWhite
        return descLabel
    }()
    
    private lazy var squareView: UIView = {
        let squareWidth: CGFloat = 284
        let squareView = UIView(frame: .init(x: popupDescLabel.frame.midX - (squareWidth / 2.0), y: popupDescLabel.frame.height + 25, width: squareWidth, height: squareWidth))
        squareView.backgroundColor = .diptychDarkGray
        
        return squareView
    }()
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImagePicker()
        
        PHPhotoLibrary.requestAuthorization { status in }
        
        // TODO: - Limited 위한 커스텀 뷰를 또 만들어야 하는가?
        // https://zeddios.tistory.com/620
        /*
         let fetchOptions = PHFetchOptions()
         let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
         
         for i in 0...(allPhotos.count - 1) {
             print(allPhotos.object(at: i))
         }
         */
        
        setupOverlay()
        displayGuideAndOverlay(false)
        setupLottieLoading()
        setLastImageFromLibraryToButtonImage()
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
        
        lblTopic.text = !viewModel.question.isEmpty ? viewModel.question : "오늘 본 동그라미는?"
        DispatchQueue.main.async { [unowned self] in
            print("isFirst?", viewModel.isFirst)
            currentAxis = viewModel.isFirst ? .verticalLeft : .verticalRight
        }
        
        btnShutter.isEnabled = false
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
            btnShutter.isEnabled = false
            
            lottieViewForUpload = LottieUIViews.shared.lottieView(frame: view.frame, text: "파일 업로드 중...")
            view.addSubview(lottieViewForUpload)

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
            
            let resizedImage = transformedImage.resize(width: IMAGE_SIZE, height: IMAGE_SIZE)
            
            // 가이드라인에 따라 사진 자르기
            let cropRect: CGRect = currentAxis.rect(squareSideLength: IMAGE_SIZE)
            let croppedImage: CGImage? = resizedImage.cgImage!.cropping(to: cropRect)
            let uiImage = UIImage(cgImage: croppedImage!, scale: 1, orientation: transformedImage.imageOrientation)
            
            // savePhotoToLibrary(data: data!) {_, _ in
            //     DispatchQueue.main.async {
            //         self.dismiss(animated: true)
            //     }
            // }
            
            Task {
                try await taskUpload(image: uiImage)
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
    
    @IBAction func btnActPopoverHelp(_ sender: UIButton) {
        if isShowHelpPopup {
            blurPopupView.removeFromSuperview()
        } else {
            blurPopupView.addSubview(popupDescLabel)
            blurPopupView.addSubview(squareView)
            
            let arrowView = BlurPopupUIView(frame: .init(x: btnQuestionMark.frame.minX, y: btnQuestionMark.frame.maxY, width: btnQuestionMark.frame.width, height: btnQuestionMark.frame.height))
            arrowView.layer.cornerRadius = 0
            arrowView.layer.cornerCurve = .circular
            
            view.addSubview(blurPopupView)
            view.addSubview(arrowView)
        }
        
        isShowHelpPopup.toggle()
    }
    
    // MARK: - UI Assistants
    
    private func setupOverlay() {
        DispatchQueue.main.async { [unowned self] in
            viewOverlay.layoutIfNeeded()
            originalOverlayFrame = viewOverlay.frame
            
            shrinkOverlayByAxis(.verticalLeft)
        }
    }
    
    private func displayGuideAndOverlay(_ isShow: Bool) {
        imgGuidelineDashed.isHidden = !isShow
        viewOverlay.isHidden = !isShow
    }
    
    private func setupLottieLoading() {
        let lottieRect = CGRect(origin: .zero, size: viewLottieLoading.frame.size)
        let lottieView = LottieUIViews.shared.lottieView(frame: lottieRect, backgroundColor: .diptychLightGray)

        #if targetEnvironment(simulator)
            displayGuideAndOverlay(true)
        #else
            viewLottieLoading.addSubview(lottieView)
        #endif
    }
    
    // MARK: - Camera Functions
    
    func setupPhotoCamera() {
        // 카메라 로딩 시작
        
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
                print("Camera Input Error:", error.localizedDescription)
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
            
            DispatchQueue.main.async {
                self.btnShutter.isEnabled = true
                self.displayGuideAndOverlay(true)
                // 로딩 끝
                self.viewLottieLoading.isHidden = true
            }
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
        btnQuestionMark.isHidden = true // ??
        
        btnCloseBack.setImage(UIImage(named: "imgBackButton"), for: .normal)
        btnShutter.setImage(UIImage(named: "imgCircleCheckButton"), for: .normal)

        btnShutter.isEnabled = true
    }
    
    func changeCameraMode() {
        removeRetouchImageGestures()
        
        btnFlash.isHidden = false
        btnChangePosition.isHidden = false
        btnPhotoLibrary.isHidden = false
        btnQuestionMark.isHidden = false
        
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
    
    func setLastImageFromLibraryToButtonImage() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [.init(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1
        
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        // 결과가 0이 아니면 리퀘스트 진행
        if fetchResult.count > 0 {
            let requestOptions = PHImageRequestOptions()
            
            PHImageManager.default().requestImage(for: fetchResult.object(at: 0) as PHAsset,
                                                  targetSize: .init(width: 45, height: 45),
                                                  contentMode: .default,
                                                  options: requestOptions) { image, _ in
                if let image {
                    self.btnPhotoLibrary.setImage(image, for: .normal)
                    self.btnPhotoLibrary.contentMode = .scaleAspectFit
                    self.btnPhotoLibrary.imageView?.contentMode = .scaleAspectFill
                    self.btnPhotoLibrary.clipsToBounds = true
                    self.btnPhotoLibrary.layer.cornerCurve = .continuous
                    self.btnPhotoLibrary.layer.cornerRadius = 16.5
                }
            }
            
        }
    }
    
    // MARK: - Network Task
    
    func taskUpload(image uiImage: UIImage) async throws {
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
        
        // 반으로 된 사진 데이터
        let data = uiImage.jpegData(compressionQuality: JPEG_COMPRESSION_QUALITY)
        // TODO: - 가로 가이드라인일때는?
        let thumbnail = uiImage.resize(width: THUMB_SIZE / 2, height: THUMB_SIZE)
        
        guard let isFirst = viewModel?.currentUser?.isFirst else {
            return
        }
        print("isFirst?", isFirst)
        
        // TODO: - print는 로딩 인디케이터 또는 작업상황 구분점임
        print("파일 업로드 시작....")
        LottieUIViews.shared.label.text = "이미지 파일 업로드 중..."
        let url = try await FirebaseManager.shared.upload(data: data!, withName: "image_\(viewModel?.todayPhoto?.id ?? Date().formatted())")
        print("파일 업로드 끝:", url?.absoluteString ?? "unknown URL")
        
        guard let url else {
            print("url이 존재하지 않습니다.")
            return
        }
        
        
        guard let todayPhoto = viewModel?.todayPhoto else {
            print("todayPhoto is nil.")
            return
        }
        
        print("todayPhoto!:", todayPhoto.photoFirst, todayPhoto.photoSecond, isFirst, todayPhoto.photoSecond.isEmpty,  todayPhoto.photoFirst.isEmpty)
        
        // TODO: - thumbnail은 isComplete가 true될 경우에만
        let isCompleted = isFirst ? !todayPhoto.photoSecond.isEmpty : !todayPhoto.photoFirst.isEmpty
        var dictionary: [String: Any] = [
            "isCompleted": isCompleted,
        ]
        
        if isCompleted {
            if let halfAnotherThumb = imageCacheViewModel?.firstImage ?? imageCacheViewModel?.secondImage,
               let mergedThumb = thumbnail.merge(with: halfAnotherThumb, division: isFirst ? .verticalLeft : .verticalRight),
               let uploadThumb = mergedThumb.jpegData(compressionQuality: THUMB_COMPRESSION_QUALITY) {
                LottieUIViews.shared.label.text = "섬네일 업로드 중..."
                print("섬네일 업로드 시작....", halfAnotherThumb.size)
                let thumbURL = try await FirebaseManager.shared.upload(data: uploadThumb, withName: "thumb_\(viewModel?.todayPhoto?.id ?? Date().formatted())")
                dictionary["thumbnail"] = thumbURL?.absoluteString
                print("섬네일 업로드 끝")
            } else {
                print("섬네일 생성 실패:")
            }
        }
        
        let photoKey = isFirst ? "photoFirst" : "photoSecond"
        dictionary[photoKey] = url.absoluteString
        
        print("정보 업로드 시작....")
        LottieUIViews.shared.label.text = "정보 업로드 중..."
        try await FirebaseManager.shared.updateValue(collectionPath: "photos", documentId: todayPhoto.id, dictionary: dictionary)
        print("정보 업로드 끝")
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
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else {
            btnFlash.setImage(.init(named: "imgFlashButtonOff"), for: .normal)
            return
        }
        
        do {
            try device.lockForConfiguration()
            
            if device.torchMode == AVCaptureDevice.TorchMode.on || forceOff {
                // Off
                device.torchMode = .off
                btnFlash.setImage(.init(named: "imgFlashButtonOff"), for: .normal)
            } else {
                // On
                try device.setTorchModeOn(level: 1.0)
                btnFlash.setImage(.init(named: "imgFlashButton"), for: .normal)
            }
            
            device.unlockForConfiguration()
        } catch {
            btnFlash.setImage(.init(named: "imgFlashButtonOff"), for: .normal)
            print(#function, error.localizedDescription)
        }
    }
    
    func changeCameraPosition() {
        btnChangePosition.isEnabled = false
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
        btnChangePosition.isEnabled = true
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
