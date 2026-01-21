import AVFoundation
import Photos
import SwiftUI
import Combine

/// Менеджер разрешений для камеры и галереи
@MainActor
class PermissionsManager: ObservableObject {
    
    @Published var cameraAuthorizationStatus: AVAuthorizationStatus = .notDetermined
    @Published var photoLibraryAuthorizationStatus: PHAuthorizationStatus = .notDetermined
    
    init() {
        checkPermissions()
    }
    
    // MARK: - Check Current Status
    
    func checkPermissions() {
        cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        photoLibraryAuthorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
    
    // MARK: - Request Camera Permission
    
    func requestCameraPermission() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            return true
            
        case .notDetermined:
            // Request permission
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            await MainActor.run {
                self.cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
            }
            return granted
            
        case .denied, .restricted:
            await MainActor.run {
                self.cameraAuthorizationStatus = status
            }
            return false
            
        @unknown default:
            return false
        }
    }
    
    // MARK: - Request Photo Library Permission
    
    func requestPhotoLibraryPermission() async -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized, .limited:
            return true
            
        case .notDetermined:
            // Request permission
            let newStatus = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            await MainActor.run {
                self.photoLibraryAuthorizationStatus = newStatus
            }
            return newStatus == .authorized || newStatus == .limited
            
        case .denied, .restricted:
            await MainActor.run {
                self.photoLibraryAuthorizationStatus = status
            }
            return false
            
        @unknown default:
            return false
        }
    }
    
    // MARK: - Convenience
    
    var isCameraAuthorized: Bool {
        cameraAuthorizationStatus == .authorized
    }
    
    var isPhotoLibraryAuthorized: Bool {
        photoLibraryAuthorizationStatus == .authorized || photoLibraryAuthorizationStatus == .limited
    }
}
