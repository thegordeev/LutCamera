import SwiftUI

/// Контролы переключения линз (0.5x / 1x / 3x)
struct ZoomControls: View {
    @Binding var selectedLens: LensPreset
    let availableLenses: [LensPreset]
    let onLensSelected: (LensPreset) -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(availableLenses, id: \.self) { lens in
                ZoomButton(
                    label: lens.displayLabel,
                    isSelected: selectedLens == lens
                ) {
                    onLensSelected(lens)
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedLens: LensPreset = .wide
    
    ZoomControls(
        selectedLens: $selectedLens,
        availableLenses: [.ultraWide, .wide, .telephoto],
        onLensSelected: { lens in
            selectedLens = lens
        }
    )
    .padding()
    .background(Color.black)
}
