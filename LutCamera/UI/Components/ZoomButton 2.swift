import SwiftUI

struct ZoomButton: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isSelected ? AppTheme.Colors.controlBackgroundActive : AppTheme.Colors.controlBackgroundInactive)
                    .frame(width: AppTheme.Layout.zoomButtonSize, height: AppTheme.Layout.zoomButtonSize)
                
                Text(label)
                    .font(AppTheme.Typography.controlFont())
                    .tracking(0.52)
                    .foregroundColor(isSelected ? AppTheme.Colors.accentYellow : AppTheme.Colors.textPrimary)
            }
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        ZoomButton(label: "0.5", isSelected: false) { }
        ZoomButton(label: "1x", isSelected: true) { }
        ZoomButton(label: "2", isSelected: false) { }
    }
    .padding()
    .background(Color.black)
}
