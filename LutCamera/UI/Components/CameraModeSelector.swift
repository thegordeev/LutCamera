import SwiftUI

enum CameraMode: String, CaseIterable {
    case video = "VIDEO"
    case photo = "PHOTO"
}

struct CameraModeSelector: View {
    @Binding var mode: CameraMode
    let isHidden: Bool

    var body: some View {
        HStack(spacing: 30) {
            ForEach(CameraMode.allCases, id: \.self) { item in
                Button(action: { withAnimation { mode = item } }) {
                    Text(item.rawValue)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(mode == item ? AppTheme.Colors.accentYellow : .white)
                }
            }
        }
        .padding(.top, 10)
        .opacity(isHidden ? 0 : 1)
    }
}

#Preview {
    @Previewable @State var mode: CameraMode = .photo
    ZStack {
        Color.black.ignoresSafeArea()
        CameraModeSelector(mode: $mode, isHidden: false)
    }
}
