import AVFoundation
import SwiftUI

struct CameraPreviewLayer: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer = previewLayer
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        uiView.previewLayer = previewLayer
    }
}

// Вспомогательный класс для правильного управления preview layer
class PreviewView: UIView {
    var previewLayer: AVCaptureVideoPreviewLayer? {
        didSet {
            if let oldLayer = oldValue {
                oldLayer.removeFromSuperlayer()
            }
            
            if let newLayer = previewLayer {
                newLayer.videoGravity = .resizeAspectFill
                layer.addSublayer(newLayer)
                newLayer.frame = bounds
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }
}

#Preview {
    CameraPreviewLayer(previewLayer: AVCaptureVideoPreviewLayer(session: AVCaptureSession()))
        .frame(height: 240)
        .background(Color.black)
}
