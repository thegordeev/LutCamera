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
        let cameraGranted = await permissionsManager.requestCameraPermission()
        let photoLibraryGranted = await permissionsManager.requestPhotoLibraryPermission()
        
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
        guard !isCaptureInProgress else { return }
        
        isCaptureInProgress = true
        
        cameraService.capturePhoto { [weak self] photo in
            Task { @MainActor in
                guard let self = self else { return }
                
                self.isCaptureInProgress = false
                
                guard let photo = photo else {
                    self.errorMessage = "Failed to capture photo"
                    return
                }
                
                self.lastCapturedPhoto = photo
                
                // Сохранить в галерею
                await self.savePhotoToLibrary(photo)
            }
        }
    }
    
    // MARK: - Save to Library
    
    private func savePhotoToLibrary(_ photo: PhotoCapture) async {
        guard isPhotoLibraryAuthorized else {
            errorMessage = "Photo library permission not granted"
            return
        }
        
        do {
            // Сохранить дуал-захват (обработанное + RAW если есть)
            try await photoLibraryService.saveDualCapture(
                processedImage: photo.processedImage,
                rawData: photo.rawData
            )
            
            print("✅ Photo saved to library")
        } catch {
            errorMessage = "Failed to save photo: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Fetch Last Photo
    
    func fetchLastPhoto() async -> UIImage? {
        await photoLibraryService.fetchLastPhoto()
    }
}
