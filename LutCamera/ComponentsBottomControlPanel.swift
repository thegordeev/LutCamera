import SwiftUI

struct BottomControlPanel: View {
    let onCapture: () -> Void
    
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
                
                // Right Placeholder (Flip camera)
                Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundColor(.white)
                    .font(.system(size: 24))
                    .frame(width: 45, height: 45)
            }
            .padding(.horizontal, 32) // CSS: left: 32px для галереи
        }
        .frame(height: 150) // Фиксированная высота нижней панели
    }
}

#Preview {
    BottomControlPanel {
        print("Capture")
    }
}
