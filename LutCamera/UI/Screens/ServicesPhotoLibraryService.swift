import Photos
import UIKit

actor PhotoLibraryService {
    
    // MARK: - Save High Quality Data
    
    func saveOriginalData(_ data: Data) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            let request = PHAssetCreationRequest.forAsset()
            // Сохраняем оригинальный файл байт-в-байт.
            // .photo говорит системе, что это стандартное фото (HEIC/JPEG)
            request.addResource(with: .photo, data: data, options: nil)
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
