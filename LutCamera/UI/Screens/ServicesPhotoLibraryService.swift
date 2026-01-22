import Photos
import UIKit

actor PhotoLibraryService {
    
    // Сохраняем оригинальные данные байт-в-байт
    // Это критично для сохранения 48МП, GPS и инфо о линзе
    func saveOriginalData(_ data: Data) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            let request = PHAssetCreationRequest.forAsset()
            // .photo автоматически определит формат (HEIC/JPEG) внутри Data
            request.addResource(with: .photo, data: data, options: nil)
        }
    }
    
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

enum PhotoLibraryError: Error, LocalizedError {
    case saveFailed
    case fetchFailed
    
    var errorDescription: String? {
        switch self {
        case .saveFailed: return "Не удалось сохранить фото"
        case .fetchFailed: return "Не удалось загрузить фото"
        }
    }
}
