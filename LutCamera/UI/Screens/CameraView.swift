import SwiftUI
import UIKit

struct CameraView: View {
    @State private var viewModel = CameraViewModel()
    @State private var lastPhoto: UIImage?
    @State private var shutterAnimation = false
    @State private var mode: CameraMode = .photo
    @State private var isRecording = false
    @State private var isFlashOn = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            CameraPreviewLayer(previewLayer: viewModel.previewLayer, showDevBorder: false)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                CameraTopControls(
                    isFlashOn: isFlashOn,
                    onFlashToggle: { isFlashOn.toggle() },
                    onActionMenu: {},
                    onLivePhoto: {}
                )

                Spacer()

                if !isRecording {
                    HStack(spacing: 20) {
                        ZoomBubble(label: ".5", isSelected: viewModel.currentZoomLevel == 0.5) {
                            viewModel.setZoom(0.5)
                        }
                        ZoomBubble(label: "1x", isSelected: viewModel.currentZoomLevel == 1.0) {
                            viewModel.setZoom(1.0)
                        }
                        ZoomBubble(label: "2", isSelected: viewModel.currentZoomLevel == 2.0) {
                            viewModel.setZoom(2.0)
                        }
                        ZoomBubble(label: "5", isSelected: viewModel.currentZoomLevel == 5.0) {
                            viewModel.setZoom(5.0)
                        }
                    }
                    .padding(.bottom, 30)
                }

                ZStack(alignment: .bottom) {
                    Color.black
                        .ignoresSafeArea()
                        .frame(height: 150)

                    VStack(spacing: 15) {
                        CameraModeSelector(mode: $mode, isHidden: isRecording)

                        HStack {
                            GalleryButton(lastPhoto: lastPhoto) {
                                if let url = URL(string: "photos-redirect://") {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .opacity(isRecording ? 0 : 1)

                            Spacer()

                            Button(action: handleShutter) {
                                ShutterButtonView(mode: mode, isRecording: isRecording, animate: shutterAnimation)
                            }

                            Spacer()

                            FlipCameraButton(action: viewModel.switchCamera)
                                .opacity(isRecording ? 0 : 1)
                        }
                        .padding(.horizontal, 30)
                        .padding(.bottom, 30)
                    }
                }
            }

            if shutterAnimation && mode == .photo {
                Color.black.opacity(0.8).ignoresSafeArea()
            }
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
        .onChange(of: mode) { _, newValue in
            if newValue == .photo {
                isRecording = false
            }
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

    private func handleShutter() {
        if mode == .photo {
            viewModel.capturePhoto()
            withAnimation(.linear(duration: 0.1)) { shutterAnimation = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation { shutterAnimation = false }
            }
        } else {
            isRecording.toggle()
        }
    }
}

#Preview {
    CameraView()
}
