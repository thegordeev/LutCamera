import SwiftUI

struct ShutterButtonView: View {
    let mode: CameraMode
    let isRecording: Bool
    let animate: Bool

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(Color.white, lineWidth: 4)
                .frame(width: 80, height: 80)

            if mode == .photo {
                Circle()
                    .fill(Color.white)
                    .frame(width: 70, height: 70)
                    .scaleEffect(animate ? 0.85 : 1.0)
            } else {
                if isRecording {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.red)
                        .frame(width: 35, height: 35)
                } else {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 70, height: 70)
                }
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isRecording)
    }
}

#Preview {
    VStack(spacing: 24) {
        ShutterButtonView(mode: .photo, isRecording: false, animate: false)
        ShutterButtonView(mode: .video, isRecording: false, animate: false)
        ShutterButtonView(mode: .video, isRecording: true, animate: false)
    }
    .padding()
    .background(Color.black)
}
