import SwiftUI

struct ZoomControls: View {
    @Binding var currentZoomLevel: Double
    
    var body: some View {
        HStack(spacing: 20) { // spacing увеличен для удобства нажатия
            ZoomButton(label: "0.5", isSelected: currentZoomLevel == 0.5) {
                currentZoomLevel = 0.5
            }
            ZoomButton(label: "1x", isSelected: currentZoomLevel == 1.0) {
                currentZoomLevel = 1.0
            }
            ZoomButton(label: "2", isSelected: currentZoomLevel == 2.0) {
                currentZoomLevel = 2.0
            }
        }
    }
}

#Preview {
    @Previewable @State var zoomLevel: Double = 1.0
    
    ZoomControls(currentZoomLevel: $zoomLevel)
        .padding()
        .background(Color.black)
}
