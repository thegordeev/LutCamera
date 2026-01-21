import AVFoundation

/// Модель конфигурации камеры
struct CameraConfiguration {
    /// Текущая позиция камеры
    var position: AVCaptureDevice.Position = .back
    
    /// Текущий зум-фактор
    var zoomFactor: CGFloat = 1.0
    
    /// Режим вспышки
    var flashMode: AVCaptureDevice.FlashMode = .off
    
    /// Качество захвата фото
    var photoQualityPrioritization: AVCapturePhotoOutput.QualityPrioritization = .quality
    
    /// Поддержка ProRAW
    var isProRAWEnabled: Bool = false
    
    /// Доступные зум-факторы (0.5x, 1x, 2x)
    static let availableZoomFactors: [CGFloat] = [0.5, 1.0, 2.0]
}
