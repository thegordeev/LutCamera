import SwiftUI

/// ZoomBubble - круглая кнопка зума в стиле iOS Camera
/// Из референса: 40x40 круг с черным фоном (opacity 0.5)
struct ZoomBubble: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                // Фон - черный круг
                Circle()
                    .fill(AppTheme.Colors.controlBackground)
                    .frame(
                        width: AppTheme.Layout.zoomBubbleSize,
                        height: AppTheme.Layout.zoomBubbleSize
                    )

                // Текст
                Text(label)
                    .font(AppTheme.Typography.zoomFont())
                    .foregroundColor(isSelected ? AppTheme.Colors.accentYellow : AppTheme.Colors.textPrimary)
            }
            .scaleEffect(isSelected ? AppTheme.Animation.zoomBubbleScale : 1.0)
            .overlay(
                Circle()
                    .stroke(Color.gray.opacity(0.5), lineWidth: 0.5)
            )
        }
    }
}

// Алиас для обратной совместимости
typealias ZoomButton = ZoomBubble

#Preview {
    HStack(spacing: AppTheme.Layout.zoomBubbleSpacing) {
        ZoomBubble(label: ".5", isSelected: false) { }
        ZoomBubble(label: "1x", isSelected: true) { }
        ZoomBubble(label: "2", isSelected: false) { }
        ZoomBubble(label: "5", isSelected: false) { }
    }
    .padding()
    .background(Color.black)
}
