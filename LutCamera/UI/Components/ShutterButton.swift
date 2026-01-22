import SwiftUI

enum CameraMode {
    case photo
    case video
}

struct ShutterButton: View {
    let mode: CameraMode
    let isRecording: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            // Анимация нажатия для фото
            if mode == .photo {
                withAnimation(.linear(duration: 0.1)) {
                    isPressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        isPressed = false
                    }
                }
            }
            action()
        }) {
            ZStack {
                // Внешнее кольцо
                Circle()
                    .strokeBorder(AppTheme.Colors.shutterRing, lineWidth: AppTheme.Layout.shutterStrokeWidth)
                    .frame(
                        width: AppTheme.Layout.shutterOuterSize,
                        height: AppTheme.Layout.shutterOuterSize
                    )

                // Внутренний элемент
                if mode == .photo {
                    // Фото режим - белый круг
                    Circle()
                        .fill(AppTheme.Colors.shutterInner)
                        .frame(
                            width: AppTheme.Layout.shutterInnerSize,
                            height: AppTheme.Layout.shutterInnerSize
                        )
                        .scaleEffect(isPressed ? AppTheme.Animation.shutterScale : 1.0)
                } else {
                    // Видео режим
                    if isRecording {
                        // Красный квадрат при записи
                        RoundedRectangle(cornerRadius: AppTheme.Layout.shutterRecordingCornerRadius)
                            .fill(AppTheme.Colors.shutterRecording)
                            .frame(
                                width: AppTheme.Layout.shutterRecordingSquareSize,
                                height: AppTheme.Layout.shutterRecordingSquareSize
                            )
                    } else {
                        // Красный круг до начала записи
                        Circle()
                            .fill(AppTheme.Colors.shutterRecording)
                            .frame(
                                width: AppTheme.Layout.shutterInnerSize,
                                height: AppTheme.Layout.shutterInnerSize
                            )
                    }
                }
            }
            .animation(AppTheme.Animation.shutterSpring, value: isRecording)
        }
    }
}

// Простой вариант только для фото (обратная совместимость)
extension ShutterButton {
    init(action: @escaping () -> Void) {
        self.mode = .photo
        self.isRecording = false
        self.action = action
    }
}

#Preview("Photo Mode") {
    ShutterButton(mode: .photo, isRecording: false) {
        print("Capture")
    }
    .padding()
    .background(Color.black)
}

#Preview("Video Mode - Idle") {
    ShutterButton(mode: .video, isRecording: false) {
        print("Start Recording")
    }
    .padding()
    .background(Color.black)
}

#Preview("Video Mode - Recording") {
    ShutterButton(mode: .video, isRecording: true) {
        print("Stop Recording")
    }
    .padding()
    .background(Color.black)
}
