import SwiftUI

struct CameraTopSafeArea: View {
    var body: some View {
        Color.black
            .frame(height: 50) // Безопасная зона сверху для Dynamic Island
    }
}

#Preview {
    CameraTopSafeArea()
}
