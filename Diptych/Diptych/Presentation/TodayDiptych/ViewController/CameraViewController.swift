//
//  CameraViewController.swift
//  Diptych
//
//  Created by 윤범태 on 2023/07/13.
//

import UIKit
import AVFoundation
import Photos

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
    
    // MARK: - Vars
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
                print("changeCameraMode")
                changeCameraMode()
            case .retouch:
                changeRetouchMode()
            }
        }
    }
    
    var photoData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkCameraPermissions()
        setupPhotoCamera()
    }
    
    // MARK: - IBActions
    
    @IBAction func btnActShutter(_ sender: UIButton) {
        // lblTopic.text = #function
        switch currentMode {
        case .camera:
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        case .retouch:
            break
        }
    }
    
    @IBAction func btnActChangeCameraPosition(_ sender: UIButton) {
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
    
    @IBAction func btnActDismissView(_ sender: UIButton) {
        switch currentMode {
        case .camera:
            dismiss(animated: true)
        case .retouch:
            currentMode = .camera
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
    
    func saveOriginalPhotoToLibrary(data: Data) {
        // 권한 요청
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                return
            }
            
            // 사진 앨범에 저장
            PHPhotoLibrary.shared().performChanges({
                let creationRequest = PHAssetCreationRequest.forAsset()
                creationRequest.addResource(with: .photo, data: data, options: nil)
            }, completionHandler: nil)
        }
    }
    
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
    
    func setupPhotoGestures() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(imagePinchAction(_:)))
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(imageRotateAction(_:)))

        view.addGestureRecognizer(pinchGesture)
        view.addGestureRecognizer(rotateGesture)
    }
    
    func changeRetouchMode() {
        // TODO: - 프리뷰 가리고, 엑스버튼 백버튼으로 바꾸고, 플래시버튼 감추고, 셔터버튼 바꾸기
        // previewLayer.removeFromSuperlayer()
        previewLayer.isHidden = true
        
        btnFlash.isHidden = true
        btnChangePosition.isHidden = true
        btnPhotoLibrary.isHidden = true
        
        btnCloseBack.setImage(UIImage(named: "imgBackButton"), for: .normal)
        btnShutter.setImage(UIImage(named: "imgCircleCheckButton"), for: .normal)
    }
    
    func changeCameraMode() {
        btnFlash.isHidden = false
        btnChangePosition.isHidden = false
        btnPhotoLibrary.isHidden = false
        
        btnCloseBack.setImage(UIImage(named: "imgCloseButton"), for: .normal)
        btnShutter.setImage(UIImage(named: "imgShutterButton"), for: .normal)
        
        previewLayer.isHidden = false
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
        setupPhotoGestures()
        saveOriginalPhotoToLibrary(data: data)
        // performSegue(withIdentifier: "RetouchCameraSegue", sender: data)
    }
}
