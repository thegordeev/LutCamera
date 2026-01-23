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

                    // Обновлённые контролы линз (0.5x / 1x / 3x)
                    ZoomControls(
                        selectedLens: Binding(
                            get: { viewModel.selectedLens },
                            set: { _ in }
                        ),
                        availableLenses: viewModel.availableLenses,
                        onLensSelected: { lens in
                            viewModel.switchLens(to: lens)
                        }
                    )
                    .padding(.bottom, 20)
                }

                BottomControlPanel(
                    lastPhoto: lastPhoto,
                    onCapture: viewModel.capturePhoto,
                    onFlipCamera: viewModel.switchCamera,
                    onGallery: {
                        if let url = URL(string: "photos-redirect://") {
                            UIApplication.shared.open(url)
                        }
                    }
                )
            }
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)
        }
        .alert("Ошибка", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .task {
            await viewModel.onAppear()
            lastPhoto = await viewModel.fetchLastPhoto()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
        .onChange(of: viewModel.lastCapturedPhoto?.id) { _, _ in
            if let newImage = viewModel.lastCapturedPhoto?.processedImage {
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
