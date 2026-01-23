@preconcurrency import AVFoundation
import UIKit
import Combine
import CoreMedia

/// Сервис для работы с камерой
@MainActor
class CameraService: NSObject, ObservableObject {
    
    // MARK: - Errors
    
    enum CameraError: Error, LocalizedError {
        case noCameraAvailable
        case cannotAddInput
        case cannotAddOutput
        case lensNotAvailable(LensPreset)
        
        nonisolated var errorDescription: String? {
            switch self {
            case .noCameraAvailable: return "Камера недоступна"
            case .cannotAddInput: return "Не удалось добавить вход камеры"
            case .cannotAddOutput: return "Не удалось добавить выход фото"
            case .lensNotAvailable(let lens):
                // Access displayLabel in a non-isolated way
                let label: String
                switch lens {
                case .ultraWide: label = "0.5"
                case .wide: label = "1x"
                case .telephoto: label = "3x"
                }
                return "Линза \(label) недоступна"
            }
        }
    }
    
    // MARK: - Published Properties
    
    @Published var isSessionRunning = false
    @Published var capturedPhoto: PhotoCapture?
    @Published private(set) var currentLens: LensPreset = .wide
    @Published private(set) var availableLenses: [LensPreset] = []
    
    // MARK: - Private Properties
    
    private let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var currentCamera: AVCaptureDevice?
    private var photoCaptureDelegate: PhotoCaptureDelegate?
    
    /// Очередь для операций с сессией (не блокирует main thread)
    private let sessionQueue = DispatchQueue(label: "com.lutcamera.session", qos: .userInitiated)
    
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
        // Определяем доступные линзы на устройстве
        detectAvailableLenses()
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo
        
        // По умолчанию стартуем с wide (1x)
        guard let camera = getDevice(for: .wide) else {
            throw CameraError.noCameraAvailable
        }
        
        try configureCamera(camera)
        currentCamera = camera
        currentLens = .wide
        
        let input = try AVCaptureDeviceInput(device: camera)
        guard captureSession.canAddInput(input) else { throw CameraError.cannotAddInput }
        captureSession.addInput(input)
        videoDeviceInput = input
        
        guard captureSession.canAddOutput(photoOutput) else { throw CameraError.cannotAddOutput }
        captureSession.addOutput(photoOutput)
        
        // Включаем возможность съемки в 48 МП
        configurePhotoOutput(for: camera)
        
        captureSession.commitConfiguration()
    }
    
    /// Определяет какие линзы доступны на устройстве
    private func detectAvailableLenses() {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInUltraWideCamera, .builtInWideAngleCamera, .builtInTelephotoCamera],
            mediaType: .video,
            position: .back
        )
        
        var lenses: [LensPreset] = []
        for device in discoverySession.devices {
            switch device.deviceType {
            case .builtInUltraWideCamera:
                lenses.append(.ultraWide)
            case .builtInWideAngleCamera:
                lenses.append(.wide)
            case .builtInTelephotoCamera:
                lenses.append(.telephoto)
            default:
                break
            }
        }
        
        // Сортируем в порядке 0.5x, 1x, 3x
        availableLenses = LensPreset.allCases.filter { lenses.contains($0) }
        print("📷 Доступные линзы: \(availableLenses.map { $0.displayLabel })")
    }

    /// Получает устройство для конкретной линзы
    private func getDevice(for lens: LensPreset, position: AVCaptureDevice.Position = .back) -> AVCaptureDevice? {
        AVCaptureDevice.default(lens.deviceType, for: .video, position: position)
    }
    
    /// Настраивает камеру (автофокус и т.д.)
    private func configureCamera(_ camera: AVCaptureDevice) throws {
        try camera.lockForConfiguration()
        if camera.isFocusModeSupported(.continuousAutoFocus) {
            camera.focusMode = .continuousAutoFocus
        }
        if camera.isExposureModeSupported(.continuousAutoExposure) {
            camera.exposureMode = .continuousAutoExposure
        }
        camera.unlockForConfiguration()
    }
    
    /// Настраивает photoOutput для максимального разрешения
    private func configurePhotoOutput(for camera: AVCaptureDevice) {
        photoOutput.maxPhotoQualityPrioritization = .quality
        
        if #available(iOS 16.0, *) {
            if let maxDimension = camera.activeFormat.supportedMaxPhotoDimensions.max(by: {
                $0.width * $0.height < $1.width * $1.height
            }) {
                photoOutput.maxPhotoDimensions = maxDimension
            }
        } else {
            photoOutput.isHighResolutionCaptureEnabled = true
        }
    }
    
    // MARK: - Session Controls
    
    func startSession() {
        Task {
            await startSessionInternal()
        }
    }
    
    func stopSession() {
        Task {
            await stopSessionInternal()
        }
    }
    
    private func startSessionInternal() async {
        guard !captureSession.isRunning else { return }
        
        // Capture the session reference on MainActor before going to background
        let session = captureSession
        
        await withCheckedContinuation { continuation in
            sessionQueue.async {
                session.startRunning()
                
                Task { @MainActor in
                    self.isSessionRunning = session.isRunning
                    continuation.resume()
                }
            }
        }
    }
    
    private func stopSessionInternal() async {
        guard captureSession.isRunning else { return }
        
        // Capture the session reference on MainActor before going to background
        let session = captureSession
        
        await withCheckedContinuation { continuation in
            sessionQueue.async {
                session.stopRunning()
                
                Task { @MainActor in
                    self.isSessionRunning = false
                    continuation.resume()
                }
            }
        }
    }

    // MARK: - Lens Switching (ГЛАВНАЯ ФУНКЦИЯ)
    
    /// Переключает физическую линзу камеры
    /// - Parameter lens: Целевой пресет линзы
    func switchLens(to lens: LensPreset) async throws {
        // Проверяем доступность линзы
        guard availableLenses.contains(lens) else {
            throw CameraError.lensNotAvailable(lens)
        }
        
        // Если уже на этой линзе — ничего не делаем
        guard lens != currentLens else { return }
        
        // Получаем устройство для новой линзы
        guard let newCamera = getDevice(for: lens) else {
            throw CameraError.lensNotAvailable(lens)
        }
        
        // Создаём новый input
        let newInput = try AVCaptureDeviceInput(device: newCamera)
        
        // Swap input в сессии
        captureSession.beginConfiguration()
        
        // Удаляем старый input
        if let oldInput = videoDeviceInput {
            captureSession.removeInput(oldInput)
        }
        
        // Добавляем новый input
        guard captureSession.canAddInput(newInput) else {
            // Rollback — возвращаем старый input
            if let oldInput = videoDeviceInput {
                captureSession.addInput(oldInput)
            }
            captureSession.commitConfiguration()
            throw CameraError.cannotAddInput
        }
        
        captureSession.addInput(newInput)
        videoDeviceInput = newInput
        currentCamera = newCamera
        
        // Настраиваем камеру
        try? configureCamera(newCamera)
        
        // Перенастраиваем output для нового устройства (важно для 48MP)
        configurePhotoOutput(for: newCamera)
        
        captureSession.commitConfiguration()
        
        // Обновляем состояние
        currentLens = lens
        print("📷 Переключено на линзу: \(lens.displayLabel)")
    }
    
    /// Переключает между фронтальной и задней камерой
    func switchCamera() async throws {
        let newPosition: AVCaptureDevice.Position = currentCamera?.position == .back ? .front : .back
        
        // Для фронтальной камеры используем только wide
        let targetLens: LensPreset = newPosition == .front ? .wide : currentLens
        
        guard let newCamera = getDevice(for: targetLens, position: newPosition) else {
            throw CameraError.noCameraAvailable
        }
        
        let newInput = try AVCaptureDeviceInput(device: newCamera)
        
        captureSession.beginConfiguration()
        
        if let oldInput = videoDeviceInput {
            captureSession.removeInput(oldInput)
        }
        
        guard captureSession.canAddInput(newInput) else {
            captureSession.commitConfiguration()
            throw CameraError.noCameraAvailable
        }
        
        captureSession.addInput(newInput)
        videoDeviceInput = newInput
        currentCamera = newCamera
        
        configurePhotoOutput(for: newCamera)
        captureSession.commitConfiguration()
        
        // Обновляем доступные линзы для новой позиции
        if newPosition == .front {
            availableLenses = [.wide]
        } else {
            detectAvailableLenses()
        }
        currentLens = targetLens
    }

    // MARK: - Photo Capture
    
    func capturePhoto(completion: @escaping (PhotoCapture?) -> Void) {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        settings.photoQualityPrioritization = .quality
        
        // Максимальное разрешение (48MP на поддерживаемых устройствах)
        if #available(iOS 16.0, *) {
            if let camera = currentCamera,
               let maxDimension = camera.activeFormat.supportedMaxPhotoDimensions.max(by: {
                   $0.width * $0.height < $1.width * $1.height
               }) {
                settings.maxPhotoDimensions = maxDimension
            }
        } else {
            settings.isHighResolutionPhotoEnabled = true
        }
        
        let delegate = PhotoCaptureDelegate(completion: completion)
        self.photoCaptureDelegate = delegate
        
        photoOutput.capturePhoto(with: settings, delegate: delegate)
    }
}

// MARK: - Photo Capture Delegate

private class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (PhotoCapture?) -> Void
    
    init(completion: @escaping (PhotoCapture?) -> Void) {
        self.completion = completion
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("❌ Capture error: \(error)")
            completion(nil)
            return
        }
        
        guard let data = photo.fileDataRepresentation() else {
            print("❌ No data representation")
            completion(nil)
            return
        }
        
        let image = UIImage(data: data)
        print("✅ Фото захвачено: \(image?.size.width ?? 0) x \(image?.size.height ?? 0)")
        completion(PhotoCapture(processedImage: image, processedData: data, rawData: nil))
    }
}
