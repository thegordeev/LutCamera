import SwiftUI
import UIKit

struct CameraView: View {
    @State private var viewModel = CameraViewModel()
    @State private var lastPhoto: UIImage?

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                CameraTopSafeArea()

                // Preview container: 9:16 (portrait) frame, full-width, centered, with top offset
                let previewWidth = geo.size.width
                let previewHeight = previewWidth * (16.0 / 9.0)

                ZStack {
                    // Camera preview (background)
                    CameraPreviewLayer(previewLayer: viewModel.previewLayer)
                        .cornerRadius(AppTheme.Layout.cornerRadius)
                        .frame(width: previewWidth, height: previewHeight)

                    // Overlays
                    VStack(spacing: 0) {
                        Spacer()

                        ZoomControls(
                            currentZoomLevel: Binding(
                                get: { viewModel.currentZoomLevel },
                                set: { viewModel.currentZoomLevel = $0 }
                            )
                        )
                        .padding(.bottom, 12)

                        BottomControlPanel(
                            lastPhoto: lastPhoto,
                            onCapture: viewModel.capturePhoto,
                            onFlipCamera: viewModel.switchCamera,
                            onGallery: {
                                // Логика открытия галереи (пока заглушка)
                                if let url = URL(string: "photos-redirect://") {
                                    UIApplication.shared.open(url)
                                }
                            }
                        )
                    }
                    .frame(width: previewWidth, height: previewHeight)
                }
                .frame(width: previewWidth, height: previewHeight)
                .padding(.top, 64)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)
        }
        // 👇 ДОБАВЛЕНО: Отображение ошибок
        .alert("Ошибка", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
        // 👆 КОНЕЦ ДОБАВЛЕНИЯ
        .task {
            await viewModel.onAppear()
            lastPhoto = await viewModel.fetchLastPhoto()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
        .onChange(of: viewModel.lastCapturedPhoto?.id) { _, _ in
            if let newImage = viewModel.lastCapturedPhoto?.processedImage {
                // Анимация обновления миниатюры
                withAnimation(.easeInOut(duration: 0.2)) {
                    lastPhoto = newImage
                }
            }
        }
    }
}

#Preview {
    CameraView()
}
