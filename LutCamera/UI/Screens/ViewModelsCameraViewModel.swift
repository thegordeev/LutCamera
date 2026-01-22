import SwiftUI
import AVFoundation
import Observation

@MainActor
@Observable
class CameraViewModel {
    
    private let cameraService = CameraService()
    private let photoLibraryService = PhotoLibraryService()
    private let permissionsManager = PermissionsManager()
    
    var currentZoomLevel: Double = 1.0 {
        didSet { cameraService.setZoom(CGFloat(currentZoomLevel)) }
    }
    
    var isSessionRunning = false
    var lastCapturedPhoto: PhotoCapture?
    
    var showError = false
    var errorMessage = ""
    var isCaptureInProgress = false
    
    var previewLayer: AVCaptureVideoPreviewLayer { cameraService.previewLayer }
    
    func onAppear() async {
        await requestPermissions()
        
        if permissionsManager.isCameraAuthorized {
            do {
                try await cameraService.setupSession()
                cameraService.startSession()
                isSessionRunning = true
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
    
    func setZoom(_ level: Double) { currentZoomLevel = level }
    
    func switchCamera() {
        Task {
            do {
                try await cameraService.switchCamera()
            } catch {
                showError(message: "Не удалось переключить камеру")
            }
        }
    }
    
    func capturePhoto() {
        guard !isCaptureInProgress else { return }
        isCaptureInProgress = true
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        cameraService.capturePhoto { [weak self] photo in
            Task { @MainActor in
                guard let self = self else { return }
                self.isCaptureInProgress = false
                
                // Проверяем наличие данных
                guard let photo = photo, let data = photo.processedData else {
                    self.showError(message: "Ошибка: пустые данные")
                    return // <--- ВОТ ЗДЕСЬ БЫЛ ПРОПУЩЕН RETURN
                }
                
                self.lastCapturedPhoto = photo
                // Сохраняем оригинал (Data), чтобы сохранить 48MP и метаданные
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
            print("✅ Сохранено в высоком качестве (48MP)!")
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
