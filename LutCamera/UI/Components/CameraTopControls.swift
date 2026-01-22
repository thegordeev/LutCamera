import SwiftUI

struct CameraTopControls: View {
    let isFlashOn: Bool
    let onFlashToggle: () -> Void
    let onActionMenu: () -> Void
    let onLivePhoto: () -> Void

    var body: some View {
        HStack {
            Button(action: onFlashToggle) {
                Image(systemName: isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                    .font(.system(size: 20))
                    .foregroundColor(isFlashOn ? AppTheme.Colors.accentYellow : .white)
            }

            Spacer()

            Button(action: onActionMenu) {
                Image(systemName: "chevron.up")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.black.opacity(0.3))
                    .clipShape(Circle())
            }

            Spacer()

            Button(action: onLivePhoto) {
                Image(systemName: "livephoto")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 20)
        .background(
            LinearGradient(
                colors: [Color.black.opacity(0.5), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        CameraTopControls(
            isFlashOn: false,
            onFlashToggle: {},
            onActionMenu: {},
            onLivePhoto: {}
        )
    }
}
