import SwiftUI
import AVFoundation
import Observation

@MainActor
@Observable
class CameraViewModel {
    
    private let cameraService = CameraService()
    private let photoLibraryService = PhotoLibraryService()
    private let permissionsManager = PermissionsManager()
    
    // MARK: - Lens State
    
    var selectedLens: LensPreset = .wide
    var availableLenses: [LensPreset] { cameraService.availableLenses }
    
    // MARK: - Session State
    
    var isSessionRunning = false
    var lastCapturedPhoto: PhotoCapture?
    
    var showError = false
    var errorMessage = ""
    var isCaptureInProgress = false
    
    var previewLayer: AVCaptureVideoPreviewLayer { cameraService.previewLayer }
    
    // MARK: - Lifecycle
    
    func onAppear() async {
        await requestPermissions()
        
        if permissionsManager.isCameraAuthorized {
            do {
                try await cameraService.setupSession()
                cameraService.startSession()
                isSessionRunning = true
                selectedLens = cameraService.currentLens
            } catch {
                showError(message: "Ошибка камеры: \(error.localizedDescription)")
            }
        } else {
            showError(message: "Нет доступа к камере")
        }
    }
    
    func onDisappear() {
        cameraService.stopSession()
    }
    
    private func requestPermissions() async {
        let _ = await permissionsManager.requestCameraPermission()
        let _ = await permissionsManager.requestPhotoLibraryPermission()
    }

    // MARK: - Lens Switching
    
    /// Переключает линзу камеры
    func switchLens(to lens: LensPreset) {
        Task {
            do {
                try await cameraService.switchLens(to: lens)
                selectedLens = lens
            } catch {
                showError(message: "Не удалось переключить линзу: \(error.localizedDescription)")
            }
        }
    }
    
    /// Переключает между фронтальной и задней камерой
    func switchCamera() {
        Task {
            do {
                try await cameraService.switchCamera()
                selectedLens = cameraService.currentLens
            } catch {
                showError(message: "Не удалось переключить камеру")
            }
        }
    }
    
    // MARK: - Photo Capture
    
    func capturePhoto() {
        guard !isCaptureInProgress else { return }
        isCaptureInProgress = true
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        cameraService.capturePhoto { [weak self] photo in
            Task { @MainActor in
                guard let self = self else { return }
                self.isCaptureInProgress = false
                
                guard let photo = photo, let data = photo.processedData else {
                    self.showError(message: "Ошибка: пустые данные")
                    return
                }
                
                self.lastCapturedPhoto = photo
                await self.saveToLibrary(data)
            }
        }
    }
    
    private func saveToLibrary(_ data: Data) async {
        if !permissionsManager.isPhotoLibraryAuthorized {
            let granted = await permissionsManager.requestPhotoLibraryPermission()
            if !granted {
                showError(message: "Нет прав на галерею")
                return
            }
        }
        
        do {
            try await photoLibraryService.saveOriginalData(data)
            print("✅ Сохранено в высоком качестве!")
        } catch {
            showError(message: "Ошибка сохранения: \(error.localizedDescription)")
        }
    }
    
    func fetchLastPhoto() async -> UIImage? {
        await photoLibraryService.fetchLastPhoto()
    }
    
    private func showError(message: String) {
        self.errorMessage = message
        self.showError = true
    }
}
