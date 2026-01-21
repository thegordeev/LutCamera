import AVFoundation
import UIKit
import Combine

/// Сервис для работы с камерой
@MainActor
class CameraService: NSObject, ObservableObject {
    
    @Published var isSessionRunning = false
    @Published var capturedPhoto: PhotoCapture?
    
    private let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var currentCamera: AVCaptureDevice?
    
    private lazy var previewLayerInstance: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.videoGravity = .resizeAspectFill
        return layer
    }()
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        previewLayerInstance
    }
    
    // MARK: - Setup
    
    func setupSession() async throws {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            throw CameraError.noCameraAvailable
        }
        currentCamera = camera
        
        let input = try AVCaptureDeviceInput(device: camera)
        guard captureSession.canAddInput(input) else { throw CameraError.cannotAddInput }
        captureSession.addInput(input)
        videoDeviceInput = input
        
        guard captureSession.canAddOutput(photoOutput) else { throw CameraError.cannotAddOutput }
        captureSession.addOutput(photoOutput)
        photoOutput.maxPhotoQualityPrioritization = .balanced
        
        captureSession.commitConfiguration()
    }
    
    // MARK: - Controls
    
    func startSession() {
        Task(priority: .userInitiated) {
            guard !captureSession.isRunning else { return }
            captureSession.startRunning()
            isSessionRunning = captureSession.isRunning
        }
    }
    
    func stopSession() {
        Task {
            guard captureSession.isRunning else { return }
            captureSession.stopRunning()
            isSessionRunning = false
        }
    }
    
    func setZoom(_ factor: CGFloat) {
        guard let device = currentCamera else { return }
        try? device.lockForConfiguration()
        device.videoZoomFactor = max(1.0, min(factor, device.activeFormat.videoMaxZoomFactor))
        device.unlockForConfiguration()
    }
    
    func switchCamera() async throws {
        captureSession.beginConfiguration()
        if let input = videoDeviceInput { captureSession.removeInput(input) }
        
        let newPosition: AVCaptureDevice.Position = currentCamera?.position == .back ? .front : .back
        guard let newCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition),
              let newInput = try? AVCaptureDeviceInput(device: newCamera),
              captureSession.canAddInput(newInput) else {
            captureSession.commitConfiguration()
            throw CameraError.noCameraAvailable
        }
        
        captureSession.addInput(newInput)
        videoDeviceInput = newInput
        currentCamera = newCamera
        captureSession.commitConfiguration()
    }
    
    // MARK: - Capture
    
    func capturePhoto(completion: @escaping (PhotoCapture?) -> Void) {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        
        let delegate = PhotoCaptureDelegate(completion: completion)
        self.photoCaptureDelegate = delegate
        
        photoOutput.capturePhoto(with: settings, delegate: delegate)
    }
    
    private var photoCaptureDelegate: PhotoCaptureDelegate?
}

// MARK: - Delegate

private class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (PhotoCapture?) -> Void
    
    init(completion: @escaping (PhotoCapture?) -> Void) {
        self.completion = completion
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Capture error: \(error)")
            completion(nil)
            return
        }
        
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            completion(nil)
            return
        }
        
        let fixedImage = fixOrientation(img: image)
        completion(PhotoCapture(processedImage: fixedImage, processedData: nil, rawData: nil))
    }
    
    func fixOrientation(img: UIImage) -> UIImage {
        if img.imageOrientation == .up { return img }
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
        img.draw(in: CGRect(origin: .zero, size: img.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage ?? img
    }
}

// MARK: - Errors (ВОТ ЧТО БЫЛО ПРОПУЩЕНО)

enum CameraError: Error {
    case noCameraAvailable
    case cannotAddInput
    case cannotAddOutput
}
