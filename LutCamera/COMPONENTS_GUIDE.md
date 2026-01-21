# 📋 Быстрая справка по компонентам

## Простые компоненты (кнопки)

### 1. ZoomButton
**Файл:** `ComponentsZoomButton.swift`
**Назначение:** Одиночная кнопка выбора зума
**Props:**
- `label: String` - текст кнопки ("0.5", "1x", "2")
- `isSelected: Bool` - активна ли кнопка
- `action: () -> Void` - callback при нажатии

**Использование:**
```swift
ZoomButton(label: "1x", isSelected: true) {
    print("1x selected")
}
```

---

### 2. ShutterButton
**Файл:** `ComponentsShutterButton.swift`
**Назначение:** Кнопка затвора (захват фото)
**Props:**
- `action: () -> Void` - callback при нажатии

**Использование:**
```swift
ShutterButton {
    // Логика захвата фото
}
```

---

### 3. GalleryButton
**Файл:** `ComponentsGalleryButton.swift`
**Назначение:** Кнопка открытия галереи
**Props:** нет

**Использование:**
```swift
GalleryButton()
```

**TODO:** Добавить action для навигации в галерею

---

### 4. FlipCameraButton
**Файл:** `ComponentsFlipCameraButton.swift`
**Назначение:** Переключение между фронтальной и задней камерой
**Props:**
- `action: () -> Void` - callback при нажатии

**Использование:**
```swift
FlipCameraButton {
    // Логика переключения камеры
}
```

---

## Составные компоненты

### 5. ZoomControls
**Файл:** `ComponentsZoomControls.swift`
**Назначение:** Панель из 3 кнопок зума (0.5x, 1x, 2x)
**Props:**
- `@Binding currentZoomLevel: Double` - текущий уровень зума

**Использование:**
```swift
@State private var zoomLevel: Double = 1.0

ZoomControls(currentZoomLevel: $zoomLevel)
```

**Зависимости:**
- ZoomButton

---

### 6. BottomControlPanel
**Файл:** `ComponentsBottomControlPanel.swift`
**Назначение:** Нижняя панель с кнопками управления
**Props:**
- `onCapture: () -> Void` - callback для захвата фото
- `onFlipCamera: () -> Void` - callback для переключения камеры

**Использование:**
```swift
BottomControlPanel(
    onCapture: { 
        // Захват фото
    },
    onFlipCamera: { 
        // Переключить камеру
    }
)
```

**Зависимости:**
- GalleryButton
- ShutterButton
- FlipCameraButton

---

## Секции экрана

### 7. CameraTopSafeArea
**Файл:** `ComponentsCameraTopSafeArea.swift`
**Назначение:** Верхний отступ для Dynamic Island
**Props:** нет

**Использование:**
```swift
CameraTopSafeArea()
```

---

### 8. CameraPreviewLayer
**Файл:** `ComponentsCameraPreviewLayer.swift`
**Назначение:** Область предпросмотра камеры (placeholder)
**Props:** нет

**Использование:**
```swift
CameraPreviewLayer()
```

**TODO:** Интегрировать AVFoundation для реального предпросмотра

---

## Граф зависимостей

```
CameraView (главный экран)
│
├─── CameraTopSafeArea
│
├─── ZoomControls
│    └─── ZoomButton (x3)
│
├─── CameraPreviewLayer
│
└─── BottomControlPanel
     ├─── GalleryButton
     ├─── ShutterButton
     └─── FlipCameraButton
```

## Используемые константы из AppTheme

### Colors:
- `controlBackgroundActive` - фон активной кнопки зума
- `controlBackgroundInactive` - фон неактивной кнопки зума
- `accentYellow` - цвет активного текста зума
- `textPrimary` - основной цвет текста
- `shutterRing` - цвет кольца затвора
- `shutterInner` - цвет внутренней части затвора

### Layout:
- `cornerRadius` - скругление углов (16px)
- `shutterSize` - размер кнопки затвора (74px)
- `shutterInnerSize` - размер внутреннего круга затвора (64px)
- `zoomButtonSize` - размер кнопки зума (34px)

### Typography:
- `controlFont()` - шрифт для кнопок управления

---

## Модификация компонентов

### Добавить новую кнопку зума (например, 5x):

В `ComponentsZoomControls.swift`:
```swift
HStack(spacing: 20) {
    ZoomButton(label: "0.5", isSelected: currentZoomLevel == 0.5) {
        currentZoomLevel = 0.5
    }
    ZoomButton(label: "1x", isSelected: currentZoomLevel == 1.0) {
        currentZoomLevel = 1.0
    }
    ZoomButton(label: "2", isSelected: currentZoomLevel == 2.0) {
        currentZoomLevel = 2.0
    }
    // Добавить новую кнопку:
    ZoomButton(label: "5", isSelected: currentZoomLevel == 5.0) {
        currentZoomLevel = 5.0
    }
}
```

### Добавить haptic feedback:

```swift
import SwiftUI

struct ShutterButton: View {
    let action: () -> Void
    @State private var haptic = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        Button {
            haptic.impactOccurred()
            action()
        } label: {
            // ... существующий код
        }
    }
}
```

---

## Тестирование

Каждый компонент имеет `#Preview` блок для визуального тестирования в Xcode Canvas.

**Как тестировать:**
1. Открыть файл компонента
2. ⌥⌘↵ (показать Canvas)
3. Проверить визуальное отображение
4. Проверить взаимодействие

---

**Версия:** 1.0  
**Дата:** 21 января 2026
