import AVFoundation
import UIKit
import Combine
import CoreMedia

/// Сервис для работы с камерой
@MainActor
class CameraService: NSObject, ObservableObject {
    
    // Ошибки камеры
    enum CameraError: Error, LocalizedError {
        case noCameraAvailable
        case cannotAddInput
        case cannotAddOutput
        
        var errorDescription: String? {
            switch self {
            case .noCameraAvailable: return "Камера недоступна"
            case .cannotAddInput: return "Не удалось добавить вход камеры"
            case .cannotAddOutput: return "Не удалось добавить выход фото"
            }
        }
    }
    
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
        
        // Автофокус
        try? camera.lockForConfiguration()
        if camera.isFocusModeSupported(.continuousAutoFocus) {
            camera.focusMode = .continuousAutoFocus
        }
        camera.unlockForConfiguration()
        
        let input = try AVCaptureDeviceInput(device: camera)
        guard captureSession.canAddInput(input) else { throw CameraError.cannotAddInput }
        captureSession.addInput(input)
        videoDeviceInput = input
        
        guard captureSession.canAddOutput(photoOutput) else { throw CameraError.cannotAddOutput }
        captureSession.addOutput(photoOutput)
        
        // ВАЖНО: Включаем возможность съемки в 48 МП на уровне Output
        photoOutput.maxPhotoQualityPrioritization = .quality
        
        if #available(iOS 16.0, *) {
            // Ищем самое большое поддерживаемое разрешение в формате камеры
            if let maxDimension = camera.activeFormat.supportedMaxPhotoDimensions.max(by: { $0.width * $0.height < $1.width * $1.height }) {
                // Говорим Output'у, что мы готовы принимать такие большие фото
                photoOutput.maxPhotoDimensions = maxDimension
            }
        } else {
            // Старый способ для iOS 15 и ниже
            photoOutput.isHighResolutionCaptureEnabled = true
        }
        
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
        
        // При смене камеры нужно заново настроить Output для 48 МП
        if #available(iOS 16.0, *) {
            if let maxDimension = newCamera.activeFormat.supportedMaxPhotoDimensions.max(by: { $0.width * $0.height < $1.width * $1.height }) {
                photoOutput.maxPhotoDimensions = maxDimension
            }
        }
        
        captureSession.commitConfiguration()
    }
    
    // MARK: - Capture
    
    func capturePhoto(completion: @escaping (PhotoCapture?) -> Void) {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        settings.photoQualityPrioritization = .quality
        
        // ЛОГИКА ДЛЯ 48MP (iOS 16+)
        // Указываем в настройках конкретного кадра, что хотим макс разрешение
        if #available(iOS 16.0, *) {
            if let camera = currentCamera,
               let maxDimension = camera.activeFormat.supportedMaxPhotoDimensions.max(by: { $0.width * $0.height < $1.width * $1.height }) {
                settings.maxPhotoDimensions = maxDimension
            }
        } else {
            settings.isHighResolutionPhotoEnabled = true
        }
        
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
        
        // Получаем "сырой" файл с данными (где есть 48MP и метаданные)
        guard let data = photo.fileDataRepresentation() else {
            completion(nil)
            return
        }
        
        let image = UIImage(data: data)
        completion(PhotoCapture(processedImage: image, processedData: data, rawData: nil))
    }
}
