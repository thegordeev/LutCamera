import Photos
import UIKit

/// Сервис для сохранения фотографий в галерею
actor PhotoLibraryService {
    
    // MARK: - Save Dual Capture
    
    func saveDualCapture(processedImage: UIImage?, processedData: Data?, rawData: Data?) async throws {
        // Проверяем, есть ли что сохранять
        guard processedImage != nil || processedData != nil else {
            throw PhotoLibraryError.noDataToSave
        }
        
        try await PHPhotoLibrary.shared().performChanges {
            let creationRequest = PHAssetCreationRequest.forAsset()
            
            // ИСПРАВЛЕНИЕ ОШИБКИ 3300:
            // Мы принудительно конвертируем UIImage в JPEG.
            // Это гарантирует валидный формат файла, который Photos точно примет.
            if let image = processedImage, let jpegData = image.jpegData(compressionQuality: 1.0) {
                creationRequest.addResource(with: .photo, data: jpegData, options: nil)
            }
            else if let data = processedData {
                // Если картинки нет, пробуем сохранить данные как есть (fallback)
                creationRequest.addResource(with: .photo, data: data, options: nil)
            }
            
            // Сохранение RAW (если нужно)
            if let rawData = rawData {
                let options = PHAssetResourceCreationOptions()
                options.shouldMoveFile = true
                creationRequest.addResource(with: .alternatePhoto, data: rawData, options: options)
            }
        }
    }
    
    // MARK: - Fetch Last Photo
    
    func fetchLastPhoto() async -> UIImage? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1
        
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        guard let asset = assets.firstObject else { return nil }
        
        return await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .fast
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false
            
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: CGSize(width: 300, height: 300),
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }
}

// MARK: - Errors

enum PhotoLibraryError: Error, LocalizedError {
    case noDataToSave
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .noDataToSave:
            return "Нет изображения для сохранения"
        case .saveFailed:
            return "Не удалось сохранить фото в библиотеку"
        }
    }
}
