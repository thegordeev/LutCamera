import SwiftUI

struct BottomControlPanel: View {
    let lastPhoto: UIImage?
    let onCapture: () -> Void
    let onFlipCamera: () -> Void
    let onGallery: () -> Void
    
    var body: some View {
        ZStack {
            Color.black
            
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
            .padding(.horizontal, 32)
        }
        .frame(height: 150)
    }
}

#Preview {
    BottomControlPanel(
        lastPhoto: nil,
        onCapture: { print("Capture") },
        onFlipCamera: { print("Flip") },
        onGallery: { print("Gallery") }
    )
    .previewLayout(.sizeThatFits)
}
