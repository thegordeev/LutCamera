import Photos
import UIKit

/// Сервис для сохранения фотографий в галерею
actor PhotoLibraryService {
    
    // MARK: - Save Image
    
    /// Максимально надежное сохранение изображения
    func saveImage(_ image: UIImage) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            // Используем системный метод создания ассета из картинки.
            // iOS сама разберется с форматами и кодировкой.
            // Это лечит ошибку 3300.
            PHAssetChangeRequest.creationRequestForAsset(from: image)
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
    case saveFailed
    case fetchFailed
    
    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Не удалось сохранить фото"
        case .fetchFailed:
            return "Не удалось загрузить фото"
        }
    }
}
