import SwiftUI
import UIKit

// MARK: - ZoomControls Metrics

private enum ZoomMetrics {
    // Layout
    static let hStackSpacing: CGFloat = 0
    static let controlWidth: CGFloat = 152
    static let chipMinHeight: CGFloat = 36

    // Chip typography & insets
    static let chipFontSize: CGFloat = 12

    // Pill shape
    static let pillCornerRadius: CGFloat = 88
    static let pillBaseFillOpacity: Double = 0.20
    static let pillStrokeOpacity: Double = 0.18
    static let pillStrokeLineWidth: CGFloat = 0.5

    // Selected chip background
    static let selectedFillOpacity: Double = 0.16
    static let selectedStrokeOpacity: Double = 0.22
    static let selectedStrokeLineWidth: CGFloat = 0.5
    static let selectedTextColor = Color(red: 1.0, green: 0.8352941176, blue: 0.0431372549)

    // Press feedback
    static let pressedScale: CGFloat = 0.96
    static let pressedOpacity: Double = 0.86

    // Animations
    static let selectAnimDuration: Double = 0.25
    static let selectAnimBounce: Double = 0.0
    static let pressAnimDuration: Double = 0.25

    // Double compare precision
    static let epsilon: Double = 0.0001
}

// MARK: - ZoomControls

struct ZoomControls: View {
    @Binding var currentZoomLevel: Double

    /// Поддержи список значений на будущее (0.5/1/2/3/5/…)
    var options: [Double] = [0.5, 1.0, 2.0]

    var body: some View {
        ZStack(alignment: .leading) {
            // Sliding selection highlight (Camera-like)
            Capsule(style: .continuous)
                .fill(.white.opacity(ZoomMetrics.selectedFillOpacity))
                .overlay(
                    Capsule(style: .continuous)
                        .strokeBorder(.white.opacity(ZoomMetrics.selectedStrokeOpacity), lineWidth: ZoomMetrics.selectedStrokeLineWidth)
                )
                .frame(width: segmentWidth, height: ZoomMetrics.chipMinHeight)
                .offset(x: segmentWidth * CGFloat(selectedIndex))
                .animation(.spring(duration: ZoomMetrics.selectAnimDuration, bounce: ZoomMetrics.selectAnimBounce), value: selectedIndex)

            HStack(spacing: ZoomMetrics.hStackSpacing) {
                ForEach(options, id: \.self) { value in
                    ZoomChip(
                        title: formatZoom(value),
                        isSelected: isSelected(value)
                    ) {
                        setZoom(value)
                    }
                }
            }
        }
        .frame(width: ZoomMetrics.controlWidth, height: ZoomMetrics.chipMinHeight)
        .cameraGlassPill()
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Zoom controls")
    }

    private var selectedIndex: Int {
        guard !options.isEmpty else { return 0 }
        return options.firstIndex(where: { abs(currentZoomLevel - $0) < ZoomMetrics.epsilon }) ?? 0
    }

    private var segmentWidth: CGFloat {
        guard !options.isEmpty else { return ZoomMetrics.controlWidth }
        return ZoomMetrics.controlWidth / CGFloat(options.count)
    }

    private func isSelected(_ value: Double) -> Bool {
        abs(currentZoomLevel - value) < ZoomMetrics.epsilon
    }

    private func setZoom(_ value: Double) {
        // Лёгкий haptic, как у системных контролов
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        withAnimation(.spring(duration: ZoomMetrics.selectAnimDuration, bounce: ZoomMetrics.selectAnimBounce)) {
            currentZoomLevel = value
        }
    }

    private func formatZoom(_ value: Double) -> String {
        // 0.5×, 1×, 2× …
        if abs(value.rounded() - value) < ZoomMetrics.epsilon {
            return "\(Int(value))×"
        } else {
            // для 0.5 / 2.5 / etc
            return String(format: "%.1f×", value)
        }
    }
}

// MARK: - ZoomChip

private struct ZoomChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: ZoomMetrics.chipFontSize, weight: .semibold, design: .default))
                .foregroundStyle(isSelected ? ZoomMetrics.selectedTextColor : .white)
                .frame(maxWidth: .infinity, minHeight: ZoomMetrics.chipMinHeight)
                .contentShape(Rectangle())
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(CameraPressButtonStyle())
        .accessibilityLabel("Zoom \(title)")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

// MARK: - Subtle press animation

private struct CameraPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? ZoomMetrics.pressedScale : 1.0)
            .opacity(configuration.isPressed ? ZoomMetrics.pressedOpacity : 1.0)
            .animation(.snappy(duration: ZoomMetrics.pressAnimDuration), value: configuration.isPressed)
    }
}

// MARK: - Liquid Glass pill (iOS 26+) + fallback

private extension View {
    func cameraGlassPill() -> some View {
        self
            .background {
                RoundedRectangle(cornerRadius: ZoomMetrics.pillCornerRadius, style: .continuous)
                    .fill(.black.opacity(ZoomMetrics.pillBaseFillOpacity)) // базовая подложка для контраста на ярком превью
                    .overlay(glassLayer)
                    .clipShape(RoundedRectangle(cornerRadius: ZoomMetrics.pillCornerRadius, style: .continuous))
            }
            .overlay(
                RoundedRectangle(cornerRadius: ZoomMetrics.pillCornerRadius, style: .continuous)
                    .strokeBorder(.white.opacity(ZoomMetrics.pillStrokeOpacity), lineWidth: ZoomMetrics.pillStrokeLineWidth)
            )
    }

    @ViewBuilder
    private var glassLayer: some View {
        if #available(iOS 26.0, *) {
            // iOS 26 Liquid Glass
            // Требует iOS 26 SDK (Xcode с поддержкой iOS 26).
            RoundedRectangle(cornerRadius: ZoomMetrics.pillCornerRadius, style: .continuous)
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: ZoomMetrics.pillCornerRadius, style: .continuous))
        } else {
            // Fallback для iOS 25 и ниже
            RoundedRectangle(cornerRadius: ZoomMetrics.pillCornerRadius, style: .continuous)
                .fill(.regularMaterial)
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var zoomLevel: Double = 1.0

    ZStack {
        Color.black.ignoresSafeArea()
        ZoomControls(currentZoomLevel: $zoomLevel)
            .padding()
    }
}
