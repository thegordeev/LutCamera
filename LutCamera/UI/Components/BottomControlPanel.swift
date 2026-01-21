import SwiftUI

struct BottomControlPanel: View {
    let onCapture: () -> Void
    let onFlipCamera: () -> Void
    
    var body: some View {
        ZStack {
            Color.black
            
            HStack {
                // Gallery (Left)
                GalleryButton()
                
                Spacer()
                
                // Shutter (Center) - Абсолютно по центру
                ShutterButton(action: onCapture)
                
                Spacer()
                
                // Flip camera (Right)
                FlipCameraButton(action: onFlipCamera)
            }
            .padding(.horizontal, 32) // CSS: left: 32px для галереи
        }
        .frame(height: 150) // Фиксированная высота нижней панели
    }
}

#Preview {
    BottomControlPanel(
        onCapture: { print("Capture") },
        onFlipCamera: { print("Flip camera") }
    )
}
