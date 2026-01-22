import SwiftUI
import UIKit

struct GalleryButton: View {
    let lastPhoto: UIImage?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            if let lastPhoto = lastPhoto {
                Image(uiImage: lastPhoto)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.white, lineWidth: 2)
                    )
            } else {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 48, height: 48)
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
