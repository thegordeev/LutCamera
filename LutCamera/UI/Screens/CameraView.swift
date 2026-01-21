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
                        print("Open gallery")
                    }
                )
            }
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)
        }
        .task {
            await viewModel.onAppear()
            lastPhoto = await viewModel.fetchLastPhoto()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
        .onChange(of: viewModel.lastCapturedPhoto?.id) { _, _ in
            lastPhoto = viewModel.lastCapturedPhoto?.processedImage
        }
    }
}

#Preview {
    CameraView()
}
