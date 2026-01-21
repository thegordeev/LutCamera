import AVFoundation
import UIKit
import Combine

/// Сервис для работы с камерой через AVFoundation
@MainActor
class CameraService: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isSessionRunning = false
    @Published var error: CameraError?
    @Published var capturedPhoto: PhotoCapture?
    
    // MARK: - Private Properties
    
    private let captureSession = AVCaptureSession()
    private var videoDeviceInput: AVCaptureDeviceInput?
    private let photoOutput = AVCapturePhotoOutput()
    private var currentCamera: AVCaptureDevice?
    private lazy var previewLayerInstance: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.videoGravity = .resizeAspectFill
        return layer
    }()
    
    // Делегат для обработки захвата фото
    private var photoCaptureDelegate: PhotoCaptureDelegate?
    
    // MARK: - Public Properties
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        previewLayerInstance
    }
    
    // MARK: - Setup
    
    func setupSession() async throws {
        // Настройка качества сессии
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo
        
        // Настройка камеры
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            throw CameraError.noCameraAvailable
        }
        
        currentCamera = camera
        
        // Добавление input
        let videoInput = try AVCaptureDeviceInput(device: camera)
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
            videoDeviceInput = videoInput
        } else {
            throw CameraError.cannotAddInput
        }
        
        // Добавление output
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
            
            // Настройка photo output
            photoOutput.maxPhotoQualityPrioritization = .quality

            if #available(iOS 16.0, *) {
                if let maxDimensions = photoOutput.supportedPhotoDimensions.max(by: { lhs, rhs in
                    lhs.width * lhs.height < rhs.width * rhs.height
                }) {
                    photoOutput.maxPhotoDimensions = maxDimensions
                }
            }
            
            // Включить ProRAW если доступно
            if photoOutput.availableRawPhotoPixelFormatTypes.count > 0 {
                photoOutput.isAppleProRAWEnabled = photoOutput.isAppleProRAWSupported
            }
        } else {
            throw CameraError.cannotAddOutput
        }
        
        captureSession.commitConfiguration()
    }
    
    // MARK: - Session Control
    
    func startSession() {
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            guard !self.captureSession.isRunning else { return }

            self.captureSession.startRunning()
            self.isSessionRunning = self.captureSession.isRunning
        }
    }
    
    func stopSession() {
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            guard self.captureSession.isRunning else { return }

            self.captureSession.stopRunning()
            self.isSessionRunning = false
        }
    }
    
    // MARK: - Zoom Control
    
    func setZoom(_ factor: CGFloat) {
        guard let device = currentCamera else { return }
        
        do {
            try device.lockForConfiguration()
            
            // Ограничить зум в пределах возможностей устройства
            let maxZoom = device.activeFormat.videoMaxZoomFactor
            let zoom = min(max(factor, 1.0), maxZoom)
            
            device.videoZoomFactor = zoom
            device.unlockForConfiguration()
        } catch {
            print("Error setting zoom: \(error)")
        }
    }
    
    // MARK: - Camera Switch
    
    func switchCamera() async throws {
        captureSession.beginConfiguration()
        
        // Удалить текущий input
        if let currentInput = videoDeviceInput {
            captureSession.removeInput(currentInput)
        }
        
        // Определить новую позицию камеры
        let currentPosition = currentCamera?.position ?? .back
        let newPosition: AVCaptureDevice.Position = currentPosition == .back ? .front : .back
        
        // Получить новую камеру
        guard let newCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition) else {
            captureSession.commitConfiguration()
            throw CameraError.noCameraAvailable
        }
        
        // Добавить новый input
        let newInput = try AVCaptureDeviceInput(device: newCamera)
        
        if captureSession.canAddInput(newInput) {
            captureSession.addInput(newInput)
            videoDeviceInput = newInput
            currentCamera = newCamera
        } else {
            captureSession.commitConfiguration()
            throw CameraError.cannotAddInput
        }
        
        captureSession.commitConfiguration()
    }
    
    // MARK: - Photo Capture
    
    func capturePhoto(completion: @escaping (PhotoCapture?) -> Void) {
        // Настройка параметров захвата
        let settings: AVCapturePhotoSettings
        
        // Включить ProRAW если доступно
        if photoOutput.availableRawPhotoPixelFormatTypes.count > 0,
           photoOutput.isAppleProRAWEnabled,
           let rawFormat = photoOutput.availableRawPhotoPixelFormatTypes.first {
            // Создать настройки с RAW форматом
            settings = AVCapturePhotoSettings(
                rawPixelFormatType: rawFormat,
                processedFormat: [AVVideoCodecKey: AVVideoCodecType.hevc]
            )
        } else {
            // Создать обычные настройки
            settings = AVCapturePhotoSettings()
        }
        
        // Установить качество
        settings.photoQualityPrioritization = .quality
        
        // Создать делегата для обработки
        let delegate = PhotoCaptureDelegate { [weak self] photo in
            self?.capturedPhoto = photo
            completion(photo)
        }
        
        photoCaptureDelegate = delegate
        
        // Захватить фото
        photoOutput.capturePhoto(with: settings, delegate: delegate)
    }
}

// MARK: - Photo Capture Delegate

private class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    
    private let completion: (PhotoCapture?) -> Void
    private var processedImage: UIImage?
    private var processedData: Data?
    private var rawData: Data?
    private var metadata: [String: Any]?
    private var didComplete = false
    
    init(completion: @escaping (PhotoCapture?) -> Void) {
        self.completion = completion
    }
    
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error = error {
            print("❌ Error capturing photo: \(error)")
            completion(nil)
            return
        }
        
        if photo.isRawPhoto {
            rawData = photo.fileDataRepresentation()
        } else {
            processedData = photo.fileDataRepresentation()
            if let processedData {
                processedImage = UIImage(data: processedData)
            }
            metadata = photo.metadata
        }
    }
    
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings,
        error: Error?
    ) {
        if let error = error {
            print("Error capturing photo: \(error)")
            completion(nil)
            return
        }
        
        guard !didComplete else { return }
        didComplete = true
        
        let photoCapture = PhotoCapture(
            processedImage: processedImage,
            processedData: processedData,
            rawData: rawData,
            metadata: metadata
        )
        
        completion(photoCapture)
    }
}

// MARK: - Errors

enum CameraError: Error, LocalizedError {
    case noCameraAvailable
    case cannotAddInput
    case cannotAddOutput
    case captureSessionNotRunning
    case photoCaptureFailed
    
    var errorDescription: String? {
        switch self {
        case .noCameraAvailable:
            return "No camera available on this device"
        case .cannotAddInput:
            return "Cannot add camera input"
        case .cannotAddOutput:
            return "Cannot add photo output"
        case .captureSessionNotRunning:
            return "Capture session is not running"
        case .photoCaptureFailed:
            return "Failed to capture photo"
        }
    }
}
