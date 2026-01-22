import AVFoundation
import SwiftUI

struct CameraPreviewLayer: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer
    var showDevBorder: Bool = true

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer = previewLayer
        view.showDevBorder = showDevBorder
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        uiView.previewLayer = previewLayer
        uiView.showDevBorder = showDevBorder
    }
}

// Вспомогательный класс для правильного управления preview layer
class PreviewView: UIView {
    // DEV OVERLAY (REMOVE ME): Red border to visualize preview bounds during development.
    var showDevBorder: Bool = true {
        didSet { updateDevBorderVisibility() }
    }

    // DEV OVERLAY (REMOVE ME): Border layer
    private let devBorderLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.name = "DEV_PREVIEW_BORDER_REMOVE_ME"
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.systemRed.withAlphaComponent(0.85).cgColor
        layer.lineJoin = .miter
        layer.lineCap = .butt
        layer.isHidden = false
        layer.zPosition = 999
        return layer
    }()

    var previewLayer: AVCaptureVideoPreviewLayer? {
        didSet {
            if let oldLayer = oldValue {
                oldLayer.removeFromSuperlayer()
            }

            if let newLayer = previewLayer {
                newLayer.videoGravity = .resizeAspectFill
                layer.addSublayer(newLayer)
                newLayer.frame = bounds
                newLayer.zPosition = 0
                ensureDevBorder()
            }
        }
    }

    private func ensureDevBorder() {
        // DEV OVERLAY (REMOVE ME): Always keep the border above the preview layer.
        devBorderLayer.removeFromSuperlayer()
        layer.addSublayer(devBorderLayer)

        // 1px line width (avoids UIScreen.main deprecation)
        let scale = (window?.screen.scale ?? traitCollection.displayScale)
        devBorderLayer.lineWidth = 1.0 / max(scale, 1.0)

        devBorderLayer.frame = bounds
        updateDevBorderPath()
        updateDevBorderVisibility()
    }

    private func updateDevBorderVisibility() {
        devBorderLayer.isHidden = !showDevBorder
    }

    private func updateDevBorderPath() {
        guard bounds.width > 0, bounds.height > 0 else {
            devBorderLayer.path = nil
            return
        }

        // Slight inset so the stroke is fully visible inside bounds
        let inset = devBorderLayer.lineWidth / 2.0
        let rect = bounds.insetBy(dx: inset, dy: inset)
        devBorderLayer.path = UIBezierPath(rect: rect).cgPath
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
        devBorderLayer.frame = bounds
        updateDevBorderPath()
        updateDevBorderVisibility()
    }
}

#Preview {
    CameraPreviewLayer(previewLayer: AVCaptureVideoPreviewLayer(session: AVCaptureSession()), showDevBorder: true)
        .frame(height: 240)
        .background(Color.black)
}
