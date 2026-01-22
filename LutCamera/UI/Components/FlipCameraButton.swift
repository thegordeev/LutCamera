import SwiftUI

struct FlipCameraButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 22, weight: .light))
                    .foregroundColor(.white)
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
