import SwiftUI

struct FlipCameraButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .foregroundColor(.white)
                .font(.system(size: 24))
                .frame(width: 45, height: 45)
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
