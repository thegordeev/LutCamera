import AVFoundation
import SwiftUI

struct CameraPreviewLayer: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if previewLayer.superlayer == nil {
            uiView.layer.addSublayer(previewLayer)
        }
        previewLayer.frame = uiView.bounds
    }
}

#Preview {
    CameraPreviewLayer(previewLayer: AVCaptureVideoPreviewLayer(session: AVCaptureSession()))
        .frame(height: 240)
        .background(Color.black)
}
