import Foundation
import UIKit

/// Модель захваченного фото
struct PhotoCapture: Identifiable {
    let id = UUID()
    
    /// Обработанное изображение (с LUT)
    let processedImage: UIImage?

    /// Данные обработанного изображения (для сохранения без повторного сжатия)
    let processedData: Data?
    
    /// RAW данные (если доступны)
    let rawData: Data?
    
    /// Дата захвата
    let captureDate: Date
    
    /// Метаданные
    let metadata: [String: Any]?
    
    init(
        processedImage: UIImage?,
        processedData: Data? = nil,
        rawData: Data? = nil,
        captureDate: Date = Date(),
        metadata: [String: Any]? = nil
    ) {
        self.processedImage = processedImage
        self.processedData = processedData
        self.rawData = rawData
        self.captureDate = captureDate
        self.metadata = metadata
    }
}
