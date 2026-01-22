import SwiftUI
import AVFoundation

/// TopControls - верхняя панель управления камерой
/// Из референса: flash, menu chevron, live photo с градиентным фоном
struct TopControls: View {
    let isRecording: Bool
    let recordedDuration: TimeInterval
    let flashMode: AVCaptureDevice.FlashMode
    let onFlashToggle: () -> Void
    let onMenuTap: () -> Void
    let onLivePhotoTap: () -> Void

    var body: some View {
        HStack {
            if isRecording {
                // Таймер записи
                recordingTimer
            } else {
                // Flash button (левый)
                Button(action: onFlashToggle) {
                    Image(systemName: flashMode == .on ? "bolt.fill" : "bolt.slash.fill")
                        .font(AppTheme.Typography.topControlFont())
                        .foregroundColor(flashMode == .on ? AppTheme.Colors.accentYellow : AppTheme.Colors.textPrimary)
                }

                Spacer()

                // Menu button (центр)
                Button(action: onMenuTap) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .padding(AppTheme.Layout.topMenuButtonSize)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                }

                Spacer()

                // Live Photo button (правый)
                Button(action: onLivePhotoTap) {
                    Image(systemName: "livephoto")
                        .font(AppTheme.Typography.topControlFont())
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }
            }
        }
        .padding(.horizontal, AppTheme.Layout.topHorizontalPadding)
        .padding(.top, AppTheme.Layout.topVerticalPadding)
        .padding(.bottom, AppTheme.Layout.topBottomPadding)
        .background(
            LinearGradient(
                colors: [AppTheme.Colors.topGradientStart, AppTheme.Colors.topGradientEnd],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var recordingTimer: some View {
        Text(formatDuration(recordedDuration))
            .font(AppTheme.Typography.recordingTimerFont())
            .foregroundColor(AppTheme.Colors.textPrimary)
            .padding(8)
            .background(Color.red.opacity(0.8))
            .cornerRadius(4)
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return String(format: "%02d:%02d", m, s)
    }
}

#Preview("Normal Mode") {
    ZStack {
        Color.gray
        VStack {
            TopControls(
                isRecording: false,
                recordedDuration: 0,
                flashMode: .off,
                onFlashToggle: { },
                onMenuTap: { },
                onLivePhotoTap: { }
            )
            Spacer()
        }
    }
}

#Preview("Recording") {
    ZStack {
        Color.gray
        VStack {
            TopControls(
                isRecording: true,
                recordedDuration: 125,
                flashMode: .off,
                onFlashToggle: { },
                onMenuTap: { },
                onLivePhotoTap: { }
            )
            Spacer()
        }
    }
}

#Preview("Flash On") {
    ZStack {
        Color.gray
        VStack {
            TopControls(
                isRecording: false,
                recordedDuration: 0,
                flashMode: .on,
                onFlashToggle: { },
                onMenuTap: { },
                onLivePhotoTap: { }
            )
            Spacer()
        }
    }
}
