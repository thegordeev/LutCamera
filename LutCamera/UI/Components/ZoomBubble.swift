import SwiftUI

struct ZoomBubble: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.5))
                    .frame(width: 40, height: 40)

                Text(label)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(isSelected ? AppTheme.Colors.accentYellow : .white)
            }
            .scaleEffect(isSelected ? 1.1 : 1.0)
            .overlay(
                Circle().stroke(Color.gray.opacity(0.5), lineWidth: 0.5)
            )
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        ZoomBubble(label: ".5", isSelected: false, action: {})
        ZoomBubble(label: "1x", isSelected: true, action: {})
        ZoomBubble(label: "2", isSelected: false, action: {})
        ZoomBubble(label: "5", isSelected: false, action: {})
    }
    .padding()
    .background(Color.black)
}
