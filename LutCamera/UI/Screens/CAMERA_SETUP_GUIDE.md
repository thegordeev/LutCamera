# 📸 Инструкции по запуску камеры

## ✅ Что было реализовано

### 1. Архитектура MVVM
- **CameraViewModel** - управление состоянием камеры
- **CameraService** - обёртка над AVFoundation
- **PhotoLibraryService** - сохранение в галерею
- **PermissionsManager** - запрос разрешений

### 2. Модели данных
- **CameraConfiguration** - настройки камеры
- **PhotoCapture** - захваченное фото (processed + RAW)

### 3. Компоненты UI
- **CameraPreviewLayer** - реальный preview камеры (UIViewRepresentable)
- **CameraView** - главный экран с интеграцией ViewModel

### 4. Функционал
✅ Запрос разрешений камеры и галереи  
✅ Отображение live preview с камеры  
✅ Переключение зума (0.5x, 1x, 2x)  
✅ Переключение камеры (фронт/тыл)  
✅ Захват фото при нажатии на кнопку  
✅ Автоматическое сохранение в галерею  
✅ Поддержка ProRAW (если доступно)  

---

## 🔧 Настройка в Xcode

### Шаг 1: Добавить разрешения в Info.plist

В Xcode откройте файл `Info.plist` и добавьте следующие ключи:

```xml
<key>NSCameraUsageDescription</key>
<string>CustomCam needs camera access to capture photos with custom LUT processing</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>CustomCam needs photo library access to save captured photos</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>CustomCam needs photo library access to view your photos</string>
```

**Или через интерфейс Xcode:**
1. Выберите проект → Target → Info
2. Добавьте новые строки:
   - `Privacy - Camera Usage Description`
   - `Privacy - Photo Library Additions Usage Description`
   - `Privacy - Photo Library Usage Description`

---

### Шаг 2: Организовать файлы в проекте

Создайте следующую структуру папок в Xcode:

```
CustomCam/
├── Views/
│   └── CameraView.swift
├── ViewModels/
│   └── ViewModelsCameraViewModel.swift
├── Services/
│   ├── ServicesCameraService.swift
│   └── ServicesPhotoLibraryService.swift
├── Models/
│   ├── ModelsCameraConfiguration.swift
│   └── ModelsPhotoCapture.swift
├── Utilities/
│   └── UtilitiesPermissionsManager.swift
├── Components/
│   ├── CameraPreviewLayer.swift (обновлённый)
│   ├── ZoomButton.swift
│   ├── ShutterButton.swift
│   ├── GalleryButton.swift
│   ├── FlipCameraButton.swift
│   ├── ZoomControls.swift
│   ├── BottomControlPanel.swift
│   └── CameraTopSafeArea.swift
└── Theme/
    └── AppTheme.swift
```

---

### Шаг 3: Проверить Target Membership

Убедитесь что все новые файлы добавлены в target:
1. Выберите файл
2. File Inspector (⌥⌘1)
3. Target Membership → поставить галочку

---

### Шаг 4: Билд и запуск

```bash
# Очистить и собрать
⇧⌘K (Clean Build Folder)
⌘B (Build)

# Запустить на симуляторе/устройстве
⌘R (Run)
```

⚠️ **Важно:** Камера работает только на реальном устройстве! На симуляторе будет чёрный экран.

---

## 🎯 Как это работает

### Поток данных при запуске:

```
CameraView
    │
    ├─ .task { await viewModel.onAppear() }
    │       │
    │       ├─ requestPermissions()
    │       │   ├─ Camera permission
    │       │   └─ Photo Library permission
    │       │
    │       └─ setupCamera()
    │           ├─ CameraService.setupSession()
    │           │   ├─ AVCaptureSession.configure
    │           │   ├─ Add camera input
    │           │   └─ Add photo output
    │           │
    │           └─ CameraService.startSession()
    │               └─ Preview появляется на экране
    │
    └─ CameraPreviewLayer(previewLayer: viewModel.previewLayer)
            └─ UIViewRepresentable → AVCaptureVideoPreviewLayer
```

### Поток данных при захвате фото:

```
1. User нажимает ShutterButton
    ↓
2. BottomControlPanel.onCapture()
    ↓
3. CameraViewModel.capturePhoto()
    ↓
4. CameraService.capturePhoto()
    ↓
5. AVCapturePhotoOutput.capturePhoto()
    ↓
6. PhotoCaptureDelegate получает фото
    ↓
7. Создаётся PhotoCapture (processed + RAW)
    ↓
8. CameraViewModel.savePhotoToLibrary()
    ↓
9. PhotoLibraryService.saveDualCapture()
    ↓
10. Фото сохранено в галерею ✅
```

---

## 🔍 Переменные для работы (через ViewModel)

### В CameraViewModel доступны:

```swift
// Состояние
@Observable class CameraViewModel {
    
    // MARK: - Публичные переменные
    
    var currentZoomLevel: Double          // Текущий зум (0.5, 1.0, 2.0)
    var isSessionRunning: Bool            // Запущена ли камера
    var lastCapturedPhoto: PhotoCapture?  // Последнее фото
    var errorMessage: String?             // Ошибки
    var isCaptureInProgress: Bool         // Идёт захват фото
    
    var previewLayer: AVCaptureVideoPreviewLayer // Layer для preview
    var isCameraAuthorized: Bool          // Разрешение камеры
    var isPhotoLibraryAuthorized: Bool    // Разрешение галереи
    
    // MARK: - Методы
    
    func onAppear() async                 // Вызывать при появлении view
    func onDisappear()                    // Вызывать при исчезновении
    func setZoom(_ level: Double)         // Установить зум
    func switchCamera()                   // Переключить камеру
    func capturePhoto()                   // Сделать снимок
    func fetchLastPhoto() async -> UIImage? // Получить последнее фото
}
```

### Использование в CameraView:

```swift
struct CameraView: View {
    @State private var viewModel = CameraViewModel()
    
    var body: some View {
        VStack {
            // Передать previewLayer
            CameraPreviewLayer(previewLayer: viewModel.previewLayer)
            
            // Передать зум через Binding
            ZoomControls(currentZoomLevel: $viewModel.currentZoomLevel)
            
            // Захват фото
            BottomControlPanel(
                onCapture: { viewModel.capturePhoto() },
                onFlipCamera: { viewModel.switchCamera() }
            )
        }
        .task { await viewModel.onAppear() }
        .onDisappear { viewModel.onDisappear() }
    }
}
```

---

## 🐛 Troubleshooting

### Камера не запускается

**Причина:** Нет разрешений в Info.plist  
**Решение:** Добавить NSCameraUsageDescription (см. Шаг 1)

### Чёрный экран вместо камеры

**Причина 1:** Запуск на симуляторе  
**Решение:** Запустить на реальном устройстве

**Причина 2:** Разрешение не предоставлено  
**Решение:** Settings → CustomCam → Camera → Allow

### Фото не сохраняется в галерею

**Причина:** Нет разрешения Photo Library  
**Решение:** Settings → CustomCam → Photos → Add Photos Only

### Build ошибки

**Ошибка:** "Cannot find 'CameraViewModel' in scope"  
**Решение:** Проверить Target Membership всех файлов

**Ошибка:** "Cannot find type 'Observation'"  
**Решение:** Убедиться что используется iOS 17+ (или убрать @Observable, использовать ObservableObject)

---

## 📝 Следующие шаги

После успешного запуска:

1. ✅ Проверить работу зума (0.5x, 1x, 2x)
2. ✅ Проверить переключение камеры
3. ✅ Сделать тестовый снимок
4. ✅ Проверить что фото сохранилось в галерее
5. ⬜ Добавить haptic feedback при захвате
6. ⬜ Реализовать LUT processing
7. ⬜ Добавить Preview последнего фото в GalleryButton

---

## 🎨 Настройка переменных

### Изменить доступные зумы:

В `Models/CameraConfiguration.swift`:
```swift
static let availableZoomFactors: [CGFloat] = [0.5, 1.0, 2.0, 5.0] // Добавить 5x
```

В `Components/ZoomControls.swift`:
```swift
ZoomButton(label: "5", isSelected: currentZoomLevel == 5.0) {
    currentZoomLevel = 5.0
}
```

### Включить/выключить ProRAW:

В `Services/CameraService.swift`, метод `setupSession()`:
```swift
// Включить ProRAW
if photoOutput.availableRawPhotoPixelFormatTypes.count > 0 {
    photoOutput.isAppleProRAWEnabled = true // или false
}
```

### Изменить качество фото:

В `Services/CameraService.swift`:
```swift
photoOutput.maxPhotoQualityPrioritization = .quality // или .speed, .balanced
```

---

**Статус:** ✅ Готово к тестированию на реальном устройстве  
**Дата:** 21 января 2026
