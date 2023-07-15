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
    
    @IBOutlet weak var lblTopic: UILabel!
    @IBOutlet weak var imgViewGuideOverlay: UIImageView!
    
    // MARK: - Vars
    var previewLayer: AVCaptureVideoPreviewLayer!
    var captureSession: AVCaptureSession!
    var backCameraInput: AVCaptureDeviceInput!
    var frontCameraInput: AVCaptureDeviceInput!
    
    var photoSettings: AVCapturePhotoSettings!
    var photoOutput: AVCapturePhotoOutput = {
        let output = AVCapturePhotoOutput()
        // 고해상도의 이미지 캡쳐 가능 설정
        if #available(iOS 16.0, *) {
            // output.maxPhotoDimensions = .init()
            output.isHighResolutionCaptureEnabled = true
        } else {
            output.isHighResolutionCaptureEnabled = true
        }
        
        return output
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
        checkCameraPermissions()
        // 1
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
            
            // Setup inputs (분리)
            
            // setupInputs()
            // guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }

            // 후면 카메라
            guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                return
            }

            // 전면 카메라
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
                captureSession.addOutput(photoOutput)
                
                // photoOutput 의 codec의 hevc 가능시 photoSettings의 codec을 hevc 로 설정하는 코드입니다.
                // hevc 불가능한 경우에는 jpeg codec을 사용하도록 합니다.
                if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
                    photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
                } else {
                    photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
                }
            } catch  {
                
            }
            
            // Preview
            DispatchQueue.main.async { [unowned self] in
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                view.layer.insertSublayer(previewLayer, above: imgViewGuideOverlay.layer)
                previewLayer.frame = self.view.frame
            }
            
            // commit configuration: 단일 atomic 업데이트에서 실행 중인 캡처 세션의 구성에 대한 하나 이상의 변경 사항을 커밋합니다.
            self.captureSession.commitConfiguration()
            // 캡처 세션 실행
            captureSession.startRunning()
        }
    }
    
    @IBAction func btnActShutter(_ sender: UIButton) {
        // lblTopic.text = #function
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
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
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler:
                                            { (authorized) in
                if(!authorized){
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
    /// capturePhoto 이후에 capture process 가 완료된 이미지를 저장하는 메쏘드
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            print("Error capturing photo:", error!.localizedDescription)
            return
        }
        
        // 권한 요청
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                return
            }
            
            // 사진 앨범에 저장
            PHPhotoLibrary.shared().performChanges({
                let creationRequest = PHAssetCreationRequest.forAsset()
                creationRequest.addResource(with: .photo, data: photo.fileDataRepresentation()!, options: nil)
            }, completionHandler: nil)
        }
    }
}
