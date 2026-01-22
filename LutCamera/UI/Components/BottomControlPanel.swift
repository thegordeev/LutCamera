import SwiftUI
import UIKit

/// BottomControlPanel - нижняя панель управления камерой
/// Из референса: черный фон, mode selector (VIDEO/PHOTO), затем gallery/shutter/flip
struct BottomControlPanel: View {
    let mode: CameraMode
    let isRecording: Bool
    let lastPhoto: UIImage?
    let onModeChange: (CameraMode) -> Void
    let onCapture: () -> Void
    let onFlipCamera: () -> Void
    let onGallery: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            // Черный фон
            Color.black
                .ignoresSafeArea()
                .frame(height: AppTheme.Layout.bottomPanelHeight)

            VStack(spacing: AppTheme.Layout.controlsSpacing) {

                // Mode Selector (VIDEO/PHOTO)
                modeSelector
                    .padding(.top, AppTheme.Layout.modeTopPadding)
                    .opacity(isRecording ? 0 : 1)

                // Controls Row
                controlsRow
                    .padding(.horizontal, AppTheme.Layout.bottomHorizontalPadding)
                    .padding(.bottom, AppTheme.Layout.bottomVerticalPadding)
            }
        }
    }

    // MARK: - Mode Selector

    private var modeSelector: some View {
        HStack(spacing: AppTheme.Layout.modeSpacing) {
            Button(action: {
                withAnimation { onModeChange(.video) }
            }) {
                Text("VIDEO")
                    .font(AppTheme.Typography.modeFont())
                    .foregroundColor(mode == .video ? AppTheme.Colors.accentYellow : AppTheme.Colors.textPrimary)
            }

            Button(action: {
                withAnimation { onModeChange(.photo) }
            }) {
                Text("PHOTO")
                    .font(AppTheme.Typography.modeFont())
                    .foregroundColor(mode == .photo ? AppTheme.Colors.accentYellow : AppTheme.Colors.textPrimary)
            }
        }
    }

    // MARK: - Controls Row

    private var controlsRow: some View {
        HStack {
            // Gallery (Left)
            GalleryButton(lastPhoto: lastPhoto, action: onGallery)
                .opacity(isRecording ? 0 : 1)

            Spacer()

            // Shutter (Center)
            ShutterButton(mode: mode, isRecording: isRecording, action: onCapture)

            Spacer()

            // Flip Camera (Right)
            FlipCameraButton(action: onFlipCamera)
                .opacity(isRecording ? 0 : 1)
        }
    }
}

// Обратная совместимость - только для фото режима
extension BottomControlPanel {
    init(
        lastPhoto: UIImage?,
        onCapture: @escaping () -> Void,
        onFlipCamera: @escaping () -> Void,
        onGallery: @escaping () -> Void
    ) {
        self.mode = .photo
        self.isRecording = false
        self.lastPhoto = lastPhoto
        self.onModeChange = { _ in }
        self.onCapture = onCapture
        self.onFlipCamera = onFlipCamera
        self.onGallery = onGallery
    }
}

#Preview("Photo Mode") {
    ZStack {
        Color.gray.ignoresSafeArea()
        VStack {
            Spacer()
            BottomControlPanel(
                mode: .photo,
                isRecording: false,
                lastPhoto: nil,
                onModeChange: { _ in },
                onCapture: { print("Capture") },
                onFlipCamera: { print("Flip camera") },
                onGallery: { print("Open gallery") }
            )
        }
    }
}

#Preview("Video Mode") {
    ZStack {
        Color.gray.ignoresSafeArea()
        VStack {
            Spacer()
            BottomControlPanel(
                mode: .video,
                isRecording: false,
                lastPhoto: nil,
                onModeChange: { _ in },
                onCapture: { print("Start recording") },
                onFlipCamera: { print("Flip camera") },
                onGallery: { print("Open gallery") }
            )
        }
    }
}

#Preview("Recording") {
    ZStack {
        Color.gray.ignoresSafeArea()
        VStack {
            Spacer()
            BottomControlPanel(
                mode: .video,
                isRecording: true,
                lastPhoto: nil,
                onModeChange: { _ in },
                onCapture: { print("Stop recording") },
                onFlipCamera: { print("Flip camera") },
                onGallery: { print("Open gallery") }
            )
        }
    }
}
