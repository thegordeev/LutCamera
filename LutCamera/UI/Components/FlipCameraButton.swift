import SwiftUI

/// FlipCameraButton - кнопка переключения между фронтальной и задней камерой
/// Из референса: 48x48 круг с полупрозрачным белым фоном
struct FlipCameraButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                // Круглый фон
                Circle()
                    .fill(AppTheme.Colors.flipCameraBackground)
                    .frame(
                        width: AppTheme.Layout.flipButtonSize,
                        height: AppTheme.Layout.flipButtonSize
                    )

                // Иконка
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(AppTheme.Typography.flipCameraFont())
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }
        }
    }
}

#Preview {
    FlipCameraButton {
        print("Flip camera")
    }
    .padding()
    .background(Color.black)
}
