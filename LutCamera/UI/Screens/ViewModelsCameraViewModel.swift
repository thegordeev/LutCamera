import SwiftUI
import AVFoundation
import Observation

/// ViewModel для управления камерой
@MainActor
@Observable
class CameraViewModel {
    
    // MARK: - Services
    
    private let cameraService = CameraService()
    private let photoLibraryService = PhotoLibraryService()
    private let permissionsManager = PermissionsManager()
    
    // MARK: - State
    
    var currentZoomLevel: Double = 1.0 {
        didSet {
            cameraService.setZoom(CGFloat(currentZoomLevel))
        }
    }
    
    var isSessionRunning: Bool = false
    var lastCapturedPhoto: PhotoCapture?
    
    // UI State
    var showError: Bool = false
    var errorMessage: String = ""
    var isCaptureInProgress: Bool = false
    
    // MARK: - Computed Properties
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        cameraService.previewLayer
    }
    
    // MARK: - Lifecycle
    
    func onAppear() async {
        await requestPermissions()
        await setupCamera()
    }
    
    func onDisappear() {
        cameraService.stopSession()
    }
    
    // MARK: - Permissions
    
    private func requestPermissions() async {
        let _ = await permissionsManager.requestCameraPermission()
        let _ = await permissionsManager.requestPhotoLibraryPermission()
    }
    
    // MARK: - Camera Setup
    
    private func setupCamera() async {
        if !permissionsManager.isCameraAuthorized {
            showError(message: "Нет доступа к камере. Пожалуйста, разрешите доступ в Настройках.")
            return
        }
        
        do {
            try await cameraService.setupSession()
            cameraService.startSession()
            isSessionRunning = true
        } catch {
            showError(message: "Ошибка настройки камеры: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Controls
    
    func setZoom(_ level: Double) {
        currentZoomLevel = level
    }
    
    func switchCamera() {
        Task {
            do {
                try await cameraService.switchCamera()
            } catch {
                showError(message: "Не удалось переключить камеру")
            }
        }
    }
    
    // MARK: - Photo Capture
    
    func capturePhoto() {
        guard !isCaptureInProgress else { return }
        isCaptureInProgress = true
        
        // Виброотклик
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        cameraService.capturePhoto { [weak self] photo in
            Task { @MainActor in
                guard let self = self else { return }
                self.isCaptureInProgress = false
                
                guard let photo = photo else {
                    self.showError(message: "Ошибка: камера вернула пустой снимок")
                    return
                }
                
                // 1. Показываем превью
                self.lastCapturedPhoto = photo
                
                // 2. Сохраняем
                await self.savePhotoToLibrary(photo)
            }
        }
    }
    
    // MARK: - Save to Library
    
    private func savePhotoToLibrary(_ photo: PhotoCapture) async {
        // ИСПРАВЛЕНИЕ: Используем if вместо guard
        if !permissionsManager.isPhotoLibraryAuthorized {
            let granted = await permissionsManager.requestPhotoLibraryPermission()
            if !granted {
                showError(message: "Нет доступа к галерее. Фото не сохранено!")
                return
            }
        }
        
        // Если дошли сюда — права есть
        do {
            try await photoLibraryService.saveDualCapture(
                processedImage: photo.processedImage,
                processedData: photo.processedData,
                rawData: photo.rawData
            )
            print("✅ Фото успешно сохранено")
        } catch {
            print("❌ Ошибка сохранения: \(error.localizedDescription)")
            showError(message: "Ошибка сохранения: \(error.localizedDescription)")
        }
    }
    
    func fetchLastPhoto() async -> UIImage? {
        await photoLibraryService.fetchLastPhoto()
    }
    
    // MARK: - Helpers
    
    private func showError(message: String) {
        self.errorMessage = message
        self.showError = true
    }
}
