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
    var errorMessage: String?
    var isCaptureInProgress: Bool = false
    
    // MARK: - Computed Properties
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        cameraService.previewLayer
    }
    
    var isCameraAuthorized: Bool {
        permissionsManager.isCameraAuthorized
    }
    
    var isPhotoLibraryAuthorized: Bool {
        permissionsManager.isPhotoLibraryAuthorized
    }
    
    // MARK: - Lifecycle
    
    func onAppear() async {
        // Запросить разрешения
        await requestPermissions()
        
        // Настроить и запустить камеру
        await setupCamera()
    }
    
    func onDisappear() {
        cameraService.stopSession()
    }
    
    // MARK: - Permissions
    
    private func requestPermissions() async {
        print("🔐 Requesting permissions...")
        
        let cameraGranted = await permissionsManager.requestCameraPermission()
        print("   Camera permission: \(cameraGranted ? "✅ Granted" : "❌ Denied")")
        
        let photoLibraryGranted = await permissionsManager.requestPhotoLibraryPermission()
        print("   Photo library permission: \(photoLibraryGranted ? "✅ Granted" : "❌ Denied")")
        
        if !cameraGranted {
            errorMessage = "Camera access is required"
        }
        
        if !photoLibraryGranted {
            errorMessage = "Photo library access is required"
        }
    }
    
    // MARK: - Camera Setup
    
    private func setupCamera() async {
        guard isCameraAuthorized else {
            errorMessage = "Camera permission not granted"
            return
        }
        
        do {
            try await cameraService.setupSession()
            cameraService.startSession()
            isSessionRunning = true
        } catch {
            errorMessage = "Failed to setup camera: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Camera Controls
    
    func setZoom(_ level: Double) {
        currentZoomLevel = level
    }
    
    func switchCamera() {
        Task {
            do {
                try await cameraService.switchCamera()
            } catch {
                errorMessage = "Failed to switch camera: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Photo Capture
    
    func capturePhoto() {
        print("🔘 CameraViewModel: Capture button pressed")
        
        guard !isCaptureInProgress else {
            print("⏸️ Capture already in progress")
            return
        }
        
        isCaptureInProgress = true
        print("✅ Starting capture process...")
        
        cameraService.capturePhoto { [weak self] photo in
            Task { @MainActor in
                guard let self = self else { return }
                
                self.isCaptureInProgress = false
                
                guard let photo = photo else {
                    print("❌ Photo capture failed")
                    self.errorMessage = "Failed to capture photo"
                    return
                }
                
                print("✅ Photo captured successfully in ViewModel")
                self.lastCapturedPhoto = photo
                
                // Сохранить в галерею
                await self.savePhotoToLibrary(photo)
            }
        }
    }
    
    // MARK: - Save to Library
    
    private func savePhotoToLibrary(_ photo: PhotoCapture) async {
        print("💾 Attempting to save photo to library...")
        print("   Photo library authorized: \(isPhotoLibraryAuthorized)")
        print("   Has processed image: \(photo.processedImage != nil)")
        print("   Has RAW data: \(photo.rawData != nil)")
        
        // Проверить разрешение
        if !isPhotoLibraryAuthorized {
            print("❌ Photo library permission not granted")
            errorMessage = "Photo library permission not granted"
            
            // Попробуем запросить разрешение снова
            let granted = await permissionsManager.requestPhotoLibraryPermission()
            if !granted {
                return
            }
            print("✅ Permission granted after request")
        }
        
        do {
            // Сохранить дуал-захват (обработанное + RAW если есть)
            try await photoLibraryService.saveDualCapture(
                processedImage: photo.processedImage,
                rawData: photo.rawData
            )
            
            print("✅ Photo saved to library successfully!")
            
            // Небольшая задержка для обновления галереи
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 секунды
            
        } catch {
            print("❌ Failed to save photo: \(error.localizedDescription)")
            errorMessage = "Failed to save photo: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Fetch Last Photo
    
    func fetchLastPhoto() async -> UIImage? {
        await photoLibraryService.fetchLastPhoto()
    }
}
