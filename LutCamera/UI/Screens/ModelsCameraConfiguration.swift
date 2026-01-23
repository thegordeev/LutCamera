import AVFoundation

// MARK: - Lens Preset (единый источник правды)

/// Пресеты физических линз камеры
/// Для iPhone 14 Pro Max: 0.5x (ultra-wide), 1x (wide), 3x (telephoto)
enum LensPreset: CaseIterable, Equatable {
    case ultraWide  // 0.5x — builtInUltraWideCamera
    case wide       // 1x — builtInWideAngleCamera
    case telephoto  // 3x — builtInTelephotoCamera
    
    /// Отображаемый текст для UI
    var displayLabel: String {
        switch self {
        case .ultraWide: return "0.5"
        case .wide: return "1x"
        case .telephoto: return "3x"
        }
    }
    
    /// Тип устройства AVFoundation
    var deviceType: AVCaptureDevice.DeviceType {
        switch self {
        case .ultraWide: return .builtInUltraWideCamera
        case .wide: return .builtInWideAngleCamera
        case .telephoto: return .builtInTelephotoCamera
        }
    }
    
    /// Базовый zoom factor для данной линзы (используется после переключения)
    var baseZoomFactor: CGFloat {
        return 1.0 // После swap input всегда начинаем с 1.0
    }
}

// MARK: - Camera Configuration

/// Модель конфигурации камеры
struct CameraConfiguration {
    /// Текущая позиция камеры
    var position: AVCaptureDevice.Position = .back
    
    /// Текущий выбранный пресет линзы
    var selectedLens: LensPreset = .wide
    
    /// Режим вспышки
    var flashMode: AVCaptureDevice.FlashMode = .off
    
    /// Качество захвата фото
    var photoQualityPrioritization: AVCapturePhotoOutput.QualityPrioritization = .quality
    
    /// Поддержка ProRAW
    var isProRAWEnabled: Bool = false
}
