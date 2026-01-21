import SwiftUI

// MARK: - Components

struct ZoomButton: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // CSS: background-color зависит от состояния
                Circle()
                    .fill(isSelected ? AppTheme.Colors.controlBackgroundActive : AppTheme.Colors.controlBackgroundInactive)
                    .frame(width: AppTheme.Layout.zoomButtonSize, height: AppTheme.Layout.zoomButtonSize)
                
                Text(label)
                    .font(AppTheme.Typography.controlFont())
                    // CSS: letter-spacing: 0.52px
                    .tracking(0.52)
                    .foregroundColor(isSelected ? AppTheme.Colors.accentYellow : AppTheme.Colors.textPrimary)
            }
        }
    }
}

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

struct GalleryButton: View {
    var body: some View {
        Circle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 45, height: 45)
            .overlay(
                Image(systemName: "photo")
                    .foregroundColor(.white)
                    .font(.system(size: 20))
            )
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
}

// MARK: - Main Screen

struct CameraView: View {
    @State private var currentZoomLevel: Double = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                
                // 1. Верхний отступ (Dynamic Island area)
                Color.black
                    .frame(height: 50) // Безопасная зона сверху
                
                // 2. Основная зона с Превью и Зум-контролами
                ZStack(alignment: .bottom) {
                    
                    // --- CAMERA PREVIEW LAYER ---
                    Rectangle()
                        .fill(Color(red: 0.25, green: 0.25, blue: 0.25)) // Плейсхолдер камеры (серый)
                        // CSS: border-radius: 16px
                        .cornerRadius(AppTheme.Layout.cornerRadius)
                        // Имитация aspect-ratio: 0.56 (9:16) или заполнение доступного места
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // --- OVERLAY CONTROLS LAYER ---
                    // Зум-переключатель плавает поверх камеры снизу
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
                    .padding(.bottom, 20) // Отступ от нижнего края картинки (внутри картинки)
                }
                .padding(.horizontal, 0) // Если нужно вплотную к краям, ставим 0
                // Можно добавить небольшой padding с боков, если как на скрине "как надо" есть черные поля?
                // На скрине "как надо" картинка на всю ширину. Оставим 0.
                
                // 3. Нижняя панель управления (Черная зона)
                ZStack {
                    Color.black
                    
                    HStack {
                        // Gallery (Left)
                        GalleryButton()
                        
                        Spacer()
                        
                        // Shutter (Center) - Абсолютно по центру
                        ShutterButton {
                            print("Capture")
                        }
                        
                        Spacer()
                        
                        // Right Placeholder (Flip camera)
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .foregroundColor(.white)
                            .font(.system(size: 24))
                            .frame(width: 45, height: 45)
                    }
                    .padding(.horizontal, 32) // CSS: left: 32px для галереи
                }
                .frame(height: 150) // Фиксированная высота нижней панели
            }
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
