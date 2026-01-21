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
            
            // Настройка максимального качества
            photoOutput.maxPhotoQualityPrioritization = .quality
            
            // Включить высокое разрешение (48MP на поддерживаемых устройствах)
            photoOutput.isHighResolutionCaptureEnabled = true
            
            // Включить захват в максимальном разрешении (для 48MP сенсора)
            if #available(iOS 16.0, *) {
                photoOutput.maxPhotoDimensions = camera.activeFormat.supportedMaxPhotoDimensions.last ?? camera.activeFormat.supportedMaxPhotoDimensions.first!
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
    
    nonisolated func startSession() {
        Task.detached { [weak self] in
            guard let self = self else { return }
            guard !self.captureSession.isRunning else { return }
            
            self.captureSession.startRunning()
            
            await MainActor.run {
                self.isSessionRunning = self.captureSession.isRunning
            }
        }
    }
    
    nonisolated func stopSession() {
        Task.detached { [weak self] in
            guard let self = self else { return }
            guard self.captureSession.isRunning else { return }
            
            self.captureSession.stopRunning()
            
            await MainActor.run {
                self.isSessionRunning = false
            }
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
        print("📷 Starting photo capture...")
        print("   Session running: \(captureSession.isRunning)")
        print("   Photo output connected: \(photoOutput.connections.count > 0)")
        
        guard captureSession.isRunning else {
            print("❌ Capture session is not running!")
            completion(nil)
            return
        }
        
        // Настройка параметров захвата
        let settings: AVCapturePhotoSettings
        
        // Включить ProRAW если доступно
        if photoOutput.availableRawPhotoPixelFormatTypes.count > 0,
           photoOutput.isAppleProRAWEnabled,
           let rawFormat = photoOutput.availableRawPhotoPixelFormatTypes.first {
            // Создать настройки с RAW форматом (ProRAW)
            settings = AVCapturePhotoSettings(rawPixelFormatType: rawFormat)
            print("   Using ProRAW format")
        } else {
            // Создать обычные настройки с максимальным качеством
            settings = AVCapturePhotoSettings()
            print("   Using standard format")
        }
        
        // Установить максимальное качество
        settings.photoQualityPrioritization = .quality
        
        // Включить высокое разрешение (48MP на поддерживаемых устройствах)
        settings.isHighResolutionPhotoEnabled = true
        print("   High resolution enabled: \(settings.isHighResolutionPhotoEnabled)")
        
        // Включить максимальное разрешение для iOS 16+
        if #available(iOS 16.0, *) {
            if let maxDimensions = currentCamera?.activeFormat.supportedMaxPhotoDimensions.last {
                settings.maxPhotoDimensions = maxDimensions
                print("   Max dimensions: \(maxDimensions.width)x\(maxDimensions.height)")
            }
        }
        
        // Отключить обработку для максимального качества (если не нужны быстрые превью)
        if #available(iOS 17.0, *) {
            settings.isAutoContentAwareDistortionCorrectionEnabled = false
        }
        
        // Создать делегата для обработки
        let delegate = PhotoCaptureDelegate { [weak self] photo in
            self?.capturedPhoto = photo
            completion(photo)
        }
        
        photoCaptureDelegate = delegate
        
        // Захватить фото
        print("   Capturing photo with settings...")
        photoOutput.capturePhoto(with: settings, delegate: delegate)
    }
}

// MARK: - Photo Capture Delegate

private class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    
    private let completion: (PhotoCapture?) -> Void
    
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
        
        print("📸 Photo captured successfully")
        print("   Resolution: \(photo.resolvedSettings.photoDimensions.width)x\(photo.resolvedSettings.photoDimensions.height)")
        print("   Is RAW: \(photo.isRawPhoto)")
        print("   Pixel Format: \(photo.pixelBuffer != nil ? "Available" : "Not available")")
        
        // Получить обработанное изображение
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("❌ Failed to get image data")
            completion(nil)
            return
        }
        
        print("✅ Image created: \(image.size.width)x\(image.size.height)")
        
        // Получить RAW данные если доступны
        let rawData = photo.isRawPhoto ? photo.fileDataRepresentation() : nil
        
        // Создать модель захвата
        let photoCapture = PhotoCapture(
            processedImage: image,
            rawData: rawData,
            metadata: photo.metadata
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
