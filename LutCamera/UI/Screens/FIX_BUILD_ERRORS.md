# ⚠️ СРОЧНО - Исправление ошибок билда

## ✅ Что я исправил в коде:

1. **UtilitiesPermissionsManager.swift** - добавлен `import Combine`
2. **ServicesCameraService.swift** - добавлен `import AVFoundation`
3. **CameraView.swift** - обновлен для использования ViewModel

## 🔧 Что ТЕБЕ нужно сделать в Xcode:

### Шаг 1: Удалить старые дубликаты (если есть)
Если в Xcode видишь файлы с префиксом "Components" (например ComponentsZoomButton.swift), удали их:
```
ComponentsZoomButton.swift → УДАЛИТЬ
ComponentsShutterButton.swift → УДАЛИТЬ
ComponentsGalleryButton.swift → УДАЛИТЬ
ComponentsFlipCameraButton.swift → УДАЛИТЬ
ComponentsZoomControls.swift → УДАЛИТЬ
ComponentsBottomControlPanel.swift → УДАЛИТЬ
ComponentsCameraPreviewLayer.swift → УДАЛИТЬ
ComponentsCameraTopSafeArea.swift → УДАЛИТЬ
```

**Оставить только файлы БЕЗ префикса:**
```
✅ ZoomButton.swift
✅ ShutterButton.swift
✅ GalleryButton.swift
✅ FlipCameraButton.swift
✅ ZoomControls.swift
✅ BottomControlPanel.swift
✅ CameraPreviewLayer.swift
✅ CameraTopSafeArea.swift
```

### Шаг 2: Организовать файлы в папки

Создай группы (folders) в Xcode и перемести файлы:

#### ViewModels/
- `ViewModelsCameraViewModel.swift`

#### Services/
- `ServicesCameraService.swift`
- `ServicesPhotoLibraryService.swift`

#### Models/
- `ModelsCameraConfiguration.swift`
- `ModelsPhotoCapture.swift`

#### Utilities/
- `UtilitiesPermissionsManager.swift`

#### Components/ (уже должна быть)
- `ZoomButton.swift`
- `ShutterButton.swift`
- `GalleryButton.swift`
- `FlipCameraButton.swift`
- `ZoomControls.swift`
- `BottomControlPanel.swift`
- `CameraPreviewLayer.swift`
- `CameraTopSafeArea.swift`

#### В корне:
- `CameraView.swift`
- `AppTheme.swift`
- `LutCameraApp.swift`

### Шаг 3: Проверить Target Membership

Для КАЖДОГО файла проверь:
1. Выбери файл
2. File Inspector (⌥⌘1)
3. Target Membership → поставь галочку на твой target (CustomCam или как у тебя называется)

**Особенно важно для:**
- ViewModelsCameraViewModel.swift
- ServicesCameraService.swift
- ServicesPhotoLibraryService.swift
- UtilitiesPermissionsManager.swift
- ModelsCameraConfiguration.swift
- ModelsPhotoCapture.swift

### Шаг 4: Добавить разрешения в Info.plist

Открой Info.plist и добавь (если еще нет):

```xml
<key>NSCameraUsageDescription</key>
<string>Нужен доступ к камере для съёмки</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>Нужен доступ к галерее для сохранения фото</string>
```

### Шаг 5: Clean и Build

```
⇧⌘K - Clean Build Folder
⌘B - Build
```

## 🐛 Если всё равно ошибки:

### "Cannot find 'CameraViewModel' in scope"
→ Проверь Target Membership для `ViewModelsCameraViewModel.swift`

### "Cannot find type 'Observation'"
→ Это для iOS 17+. Если у тебя iOS 16, напиши мне, я переделаю на ObservableObject

### "Cannot find 'ZoomButton'" или другие компоненты
→ Проверь что все файлы компонентов в Target Membership

### "Ambiguous use of..."
→ Удали старые дубликаты файлов (Components*)

## ✅ После успешного билда:

Запусти на РЕАЛЬНОМ устройстве (не симулятор):
```
⌘R - Run
```

При первом запуске разреши доступ к камере и галерее.

---

**Напиши мне если:**
- Билд всё равно не проходит (скопируй ошибку)
- Нужна помощь с iOS 16 совместимостью
- Какие-то файлы не находятся

**Я исправил код, теперь твоя очередь организовать файлы в Xcode! 💪**
