import SwiftUI

struct AppTheme {
    struct Colors {
        static let background = Color.black
        
        // CSS: #ffffff
        static let textPrimary = Color.white
        
        // CSS: #ffd50b
        static let accentYellow = Color(red: 1.0, green: 0.835, blue: 0.043)
        
        // CSS: --colors-labels-secondary: rgba(60, 60, 67, 0.6)
        // Используем для выбранного элемента или фона группы
        static let controlBackgroundActive = Color(red: 0.235, green: 0.235, blue: 0.263).opacity(0.6)
        
        // CSS: --colors-labels-tertiary: rgba(60, 60, 67, 0.3)
        // Используем для неактивных кнопок
        static let controlBackgroundInactive = Color(red: 0.235, green: 0.235, blue: 0.263).opacity(0.3)
        
        static let shutterRing = Color.white
        static let shutterInner = Color.white
    }
    
    struct Layout {
        static let cornerRadius: CGFloat = 16 // CSS: border-radius: 16px
        static let shutterSize: CGFloat = 74  // CSS: width: 74px
        static let shutterInnerSize: CGFloat = 64
        static let zoomButtonSize: CGFloat = 34 // CSS: width: 34px
        static let spacing: CGFloat = 8 // CSS: gap: 8px
    }
    
    struct Typography {
        // SF Pro Display, 13pt
        static func controlFont() -> Font {
            return .system(size: 13, weight: .regular, design: .default)
        }
    }
}
