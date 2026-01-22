import SwiftUI
import UIKit

struct BottomControlPanel: View {
    let lastPhoto: UIImage?
    let onCapture: () -> Void
    let onFlipCamera: () -> Void
    let onGallery: () -> Void
    
    var body: some View {
        HStack {
            // Gallery (Left) - показывает последнее фото
            GalleryButton(lastPhoto: lastPhoto, action: onGallery)

            Spacer()

            // Shutter (Center) - Абсолютно по центру
            ShutterButton(action: onCapture)

            Spacer()

            // Flip camera (Right)
            FlipCameraButton(action: onFlipCamera)
        }
        .padding(.horizontal, 32) // CSS: left: 32px для галереи
        .frame(height: 150) // Фиксированная высота нижней панели
        .background(Color.clear) // keep transparent
    }
}

#Preview {
    BottomControlPanel(
        lastPhoto: nil,
        onCapture: { print("Capture") },
        onFlipCamera: { print("Flip camera") },
        onGallery: { print("Open gallery") }
    )
}
