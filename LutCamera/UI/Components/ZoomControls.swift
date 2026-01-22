import SwiftUI
import UIKit

/// ZoomControls - горизонтальный ряд круглых кнопок зума
/// Из референса: .5, 1x, 2, 5 в виде круглых bubble
struct ZoomControls: View {
    @Binding var currentZoomLevel: Double

    /// Доступные уровни зума
    var options: [Double] = [0.5, 1.0, 2.0, 5.0]

    var body: some View {
        HStack(spacing: AppTheme.Layout.zoomBubbleSpacing) {
            ForEach(options, id: \.self) { value in
                ZoomBubble(
                    label: formatZoom(value),
                    isSelected: isSelected(value)
                ) {
                    setZoom(value)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Zoom controls")
    }

    // MARK: - Private

    private func isSelected(_ value: Double) -> Bool {
        abs(currentZoomLevel - value) < 0.0001
    }

    private func setZoom(_ value: Double) {
        // Haptic feedback
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        withAnimation(.spring(duration: 0.25)) {
            currentZoomLevel = value
        }
    }

    private func formatZoom(_ value: Double) -> String {
        switch value {
        case 0.5:
            return ".5"
        case 1.0:
            return "1x"
        case 2.0:
            return "2"
        case 5.0:
            return "5"
        default:
            if abs(value.rounded() - value) < 0.0001 {
                return "\(Int(value))"
            } else {
                return String(format: "%.1f", value)
            }
        }
    }
}

#Preview {
    @Previewable @State var zoomLevel: Double = 1.0

    ZStack {
        Color.black.ignoresSafeArea()
        ZoomControls(currentZoomLevel: $zoomLevel)
            .padding()
    }
}
