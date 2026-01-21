import SwiftUI
import UIKit

struct GalleryButton: View {
    let lastPhoto: UIImage?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if let lastPhoto = lastPhoto {
                    // Показать последнее фото
                    Image(uiImage: lastPhoto)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 45, height: 45)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                } else {
                    // Placeholder если нет фото
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 45, height: 45)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        // С фото
        GalleryButton(lastPhoto: UIImage(systemName: "photo"), action: {})
        
        // Без фото
        GalleryButton(lastPhoto: nil, action: {})
    }
    .padding()
    .background(Color.black)
}
