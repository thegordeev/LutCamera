import Photos
import UIKit

/// Сервис для сохранения фотографий в галерею
actor PhotoLibraryService {
    
    // MARK: - Save Single Image
    
    /// Сохранить изображение в галерею
    func saveImage(_ image: UIImage) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }
    }
    
    // MARK: - Save Dual Capture (Processed + RAW)
    
    /// Сохранить дуал-захват (обработанное фото + RAW)
    func saveDualCapture(processedImage: UIImage?, rawData: Data?) async throws {
        guard processedImage != nil || rawData != nil else {
            throw PhotoLibraryError.noDataToSave
        }
        
        try await PHPhotoLibrary.shared().performChanges {
            // Сохранить обработанное изображение
            if let processedImage = processedImage {
                PHAssetChangeRequest.creationRequestForAsset(from: processedImage)
            }
            
            // Сохранить RAW данные (если доступны)
            if let rawData = rawData {
                let creationRequest = PHAssetCreationRequest.forAsset()
                creationRequest.addResource(
                    with: .photo,
                    data: rawData,
                    options: nil
                )
            }
        }
    }
    
    // MARK: - Fetch Last Photo
    
    /// Получить последнее сохранённое фото
    func fetchLastPhoto() async -> UIImage? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1
        
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        guard let asset = assets.firstObject else {
            return nil
        }
        
        return await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isSynchronous = false
            
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: CGSize(width: 200, height: 200),
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
    case fetchFailed
    
    var errorDescription: String? {
        switch self {
        case .noDataToSave:
            return "No image or data to save"
        case .saveFailed:
            return "Failed to save photo to library"
        case .fetchFailed:
            return "Failed to fetch photo from library"
        }
    }
}
