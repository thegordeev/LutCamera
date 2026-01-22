import SwiftUI
import UIKit
import AVFoundation

struct CameraView: View {
    @State private var viewModel = CameraViewModel()
    @State private var lastPhoto: UIImage?

    // UI State (для полного соответствия референсу)
    @State private var mode: CameraMode = .photo
    @State private var isRecording = false
    @State private var recordedDuration: TimeInterval = 0
    @State private var flashMode: AVCaptureDevice.FlashMode = .off
    @State private var showShutterFlash = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()

                // Camera Preview
                CameraPreviewLayer(previewLayer: viewModel.previewLayer)
                    .ignoresSafeArea()

                // UI Overlay
                VStack(spacing: 0) {

                    // Top Controls
                    TopControls(
                        isRecording: isRecording,
                        recordedDuration: recordedDuration,
                        flashMode: flashMode,
                        onFlashToggle: toggleFlash,
                        onMenuTap: { /* Menu action */ },
                        onLivePhotoTap: { /* Live photo toggle */ }
                    )

                    Spacer()

                    // Zoom Controls (скрыты при записи видео)
                    if !isRecording {
                        ZoomControls(
                            currentZoomLevel: Binding(
                                get: { viewModel.currentZoomLevel },
                                set: { viewModel.currentZoomLevel = $0 }
                            )
                        )
                        .padding(.bottom, AppTheme.Layout.zoomBottomPadding)
                    }

                    // Bottom Bar
                    BottomControlPanel(
                        mode: mode,
                        isRecording: isRecording,
                        lastPhoto: lastPhoto,
                        onModeChange: { newMode in
                            withAnimation { mode = newMode }
                        },
                        onCapture: handleCapture,
                        onFlipCamera: viewModel.switchCamera,
                        onGallery: openGallery
                    )
                }

                // Shutter flash animation (для фото)
                if showShutterFlash && mode == .photo {
                    Color.black.opacity(0.8).ignoresSafeArea()
                }
            }
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

    // MARK: - Actions

    private func handleCapture() {
        if mode == .photo {
            // Фото режим
            viewModel.capturePhoto()

            // Анимация вспышки
            withAnimation(.linear(duration: 0.1)) {
                showShutterFlash = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    showShutterFlash = false
                }
            }
        } else {
            // Видео режим
            if isRecording {
                stopRecording()
            } else {
                startRecording()
            }
        }
    }

    private func startRecording() {
        isRecording = true
        recordedDuration = 0
        // TODO: Implement actual video recording via CameraService
    }

    private func stopRecording() {
        isRecording = false
        // TODO: Implement actual video recording stop
    }

    private func toggleFlash() {
        flashMode = (flashMode == .off) ? .on : .off
    }

    private func openGallery() {
        if let url = URL(string: "photos-redirect://") {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    CameraView()
}
