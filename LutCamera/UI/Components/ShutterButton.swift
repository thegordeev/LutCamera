import SwiftUI

struct ShutterButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .stroke(AppTheme.Colors.shutterRing, lineWidth: 4)
                    .frame(width: AppTheme.Layout.shutterSize, height: AppTheme.Layout.shutterSize)
                
                Circle()
                    .fill(AppTheme.Colors.shutterInner)
                    .frame(width: AppTheme.Layout.shutterInnerSize, height: AppTheme.Layout.shutterInnerSize)
            }
        }
    }
}

#Preview {
    ShutterButton {
        print("Capture")
    }
    .padding()
    .background(Color.black)
}
