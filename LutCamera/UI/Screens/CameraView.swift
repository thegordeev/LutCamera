import SwiftUI
import UIKit

struct CameraView: View {
    @State private var viewModel = CameraViewModel()
    @State private var lastPhoto: UIImage?

    var body: some View {
        GeometryReader { _ in
            VStack(spacing: 0) {
                CameraTopSafeArea()

                ZStack(alignment: .bottom) {
                    CameraPreviewLayer(previewLayer: viewModel.previewLayer)
                        .cornerRadius(AppTheme.Layout.cornerRadius)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    ZoomControls(
                        currentZoomLevel: Binding(
                            get: { viewModel.currentZoomLevel },
                            set: { viewModel.currentZoomLevel = $0 }
                        )
                    )
                    .padding(.bottom, 20)
                }

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
