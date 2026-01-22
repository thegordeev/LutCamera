import SwiftUI

struct AppTheme {
    struct Colors {
        static let background = Color.black

        // CSS: #ffffff
        static let textPrimary = Color.white

        // CSS: #ffd50b - желтый акцент для выбранных элементов
        static let accentYellow = Color(red: 1.0, green: 0.835, blue: 0.043)

        // Фон для контролов (zoom bubbles, кнопки)
        static let controlBackground = Color.black.opacity(0.5)

        // Фон для кнопки переключения камеры
        static let flipCameraBackground = Color.white.opacity(0.15)

        // Градиент для верхней панели
        static let topGradientStart = Color.black.opacity(0.5)
        static let topGradientEnd = Color.clear

        // Shutter button colors
        static let shutterRing = Color.white
        static let shutterInner = Color.white
        static let shutterRecording = Color.red

        // Галерея - граница
        static let galleryBorder = Color.white
    }

    struct Layout {
        // Общие
        static let cornerRadius: CGFloat = 16
        static let previewCornerRadius: CGFloat = 16

        // Shutter Button - из референса: 80x80 outer, 70x70 inner
        static let shutterOuterSize: CGFloat = 80
        static let shutterInnerSize: CGFloat = 70
        static let shutterStrokeWidth: CGFloat = 4
        static let shutterRecordingSquareSize: CGFloat = 35
        static let shutterRecordingCornerRadius: CGFloat = 8

        // Zoom Bubbles - из референса: 40x40
        static let zoomBubbleSize: CGFloat = 40
        static let zoomBubbleSpacing: CGFloat = 20

        // Gallery Button - из референса: 48x48
        static let galleryButtonSize: CGFloat = 48
        static let galleryCornerRadius: CGFloat = 6
        static let galleryBorderWidth: CGFloat = 2

        // Flip Camera Button - из референса: 48x48
        static let flipButtonSize: CGFloat = 48

        // Bottom Panel
        static let bottomPanelHeight: CGFloat = 150
        static let bottomHorizontalPadding: CGFloat = 30
        static let bottomVerticalPadding: CGFloat = 30
        static let modeSpacing: CGFloat = 30
        static let modeTopPadding: CGFloat = 10
        static let controlsSpacing: CGFloat = 15

        // Top Controls
        static let topHorizontalPadding: CGFloat = 20
        static let topVerticalPadding: CGFloat = 10
        static let topBottomPadding: CGFloat = 20
        static let topMenuButtonSize: CGFloat = 8

        // Zoom controls position
        static let zoomBottomPadding: CGFloat = 30
    }

    struct Typography {
        // Шрифт для mode selector (VIDEO/PHOTO)
        static func modeFont() -> Font {
            return .system(size: 13, weight: .bold)
        }

        // Шрифт для zoom bubbles
        static func zoomFont() -> Font {
            return .system(size: 11, weight: .bold)
        }

        // Шрифт для верхних контролов
        static func topControlFont() -> Font {
            return .system(size: 20)
        }

        // Шрифт для flip camera icon
        static func flipCameraFont() -> Font {
            return .system(size: 22, weight: .light)
        }

        // Шрифт для таймера записи
        static func recordingTimerFont() -> Font {
            return .system(size: 20, weight: .medium, design: .rounded)
        }
    }

    struct Animation {
        static let shutterSpring = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.6)
        static let shutterScale: CGFloat = 0.85
        static let zoomBubbleScale: CGFloat = 1.1
    }
}
