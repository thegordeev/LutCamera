import SwiftUI

/// GalleryButton - кнопка для открытия галереи с миниатюрой последнего фото
/// Из референса: 48x48 скругленный прямоугольник с белой рамкой
struct GalleryButton: View {
    let lastPhoto: UIImage?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            if let image = lastPhoto {
                // Показываем последнее фото
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(
                        width: AppTheme.Layout.galleryButtonSize,
                        height: AppTheme.Layout.galleryButtonSize
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: AppTheme.Layout.galleryCornerRadius)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Layout.galleryCornerRadius)
                            .stroke(
                                AppTheme.Colors.galleryBorder,
                                lineWidth: AppTheme.Layout.galleryBorderWidth
                            )
                    )
            } else {
                // Пустой placeholder
                RoundedRectangle(cornerRadius: AppTheme.Layout.galleryCornerRadius)
                    .fill(Color.gray.opacity(0.3))
                    .frame(
                        width: AppTheme.Layout.galleryButtonSize,
                        height: AppTheme.Layout.galleryButtonSize
                    )
            }
        }
    }
}

#Preview("With Photo") {
    GalleryButton(
        lastPhoto: UIImage(systemName: "photo.fill"),
        action: { print("Open gallery") }
    )
    .padding()
    .background(Color.black)
}

#Preview("Empty") {
    GalleryButton(
        lastPhoto: nil,
        action: { print("Open gallery") }
    )
    .padding()
    .background(Color.black)
}
