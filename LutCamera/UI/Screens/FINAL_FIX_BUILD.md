# ✅ ФИНАЛЬНОЕ ИСПРАВЛЕНИЕ - Info.plist для новых версий Xcode

## 🔧 Я исправил ошибки кода:

1. ✅ **ServicesCameraService.swift** - исправлена работа с RAW форматом
2. ✅ **ViewModelsCameraViewModel.swift** - добавлен `import SwiftUI`

## 📱 Как добавить разрешения в Info.plist (2 способа):

### Способ 1: Через Interface (РЕКОМЕНДУЕТСЯ)

1. **Открой Info.plist в Xcode**
   - В навигаторе проекта кликни на `Info.plist`

2. **Добавь строки** (кликни на `+` или правый клик → Add Row):
   
   **Для камеры:**
   - Key: `Privacy - Camera Usage Description`
   - Value: `CustomCam нужен доступ к камере для съёмки фото`
   
   **Для галереи:**
   - Key: `Privacy - Photo Library Additions Usage Description`
   - Value: `CustomCam нужен доступ к галерее для сохранения фото`

### Способ 2: Через Target Settings (если Info.plist не редактируется)

Если Info.plist заблокирован или не появляется:

1. **Выбери Target:**
   - В Xcode: Project Navigator → кликни на имя проекта (верхний уровень)
   - Выбери свой Target (в списке слева)

2. **Перейди на вкладку Info**

3. **Добавь Custom iOS Target Properties:**
   - Кликни `+` чтобы добавить новую строку
   - Найди в выпадающем списке:
     - `Privacy - Camera Usage Description`
     - `Privacy - Photo Library Additions Usage Description`
   - Или введи вручную ключи:
     - `NSCameraUsageDescription`
     - `NSPhotoLibraryAddUsageDescription`

4. **Укажи значения:**
   - Camera: `CustomCam нужен доступ к камере`
   - Photos: `CustomCam нужен доступ к галерее`

### Способ 3: Через Build Settings (альтернатива)

Если ни один из способов выше не работает:

1. Target → Build Settings
2. Найди "Preprocessor Macros" или "Info.plist Values"
3. Добавь значения там

---

## 🎯 После добавления разрешений:

### Clean и Build:
```
⇧⌘K - Clean Build Folder
⌘B - Build
```

### Если Build успешен:
```
⌘R - Run на РЕАЛЬНОМ устройстве (не симуляторе!)
```

---

## ⚠️ Важные моменты:

### Камера НЕ работает на симуляторе!
Обязательно нужно реальное iPhone/iPad устройство.

### Проверь Target Membership:
Убедись что все файлы в проекте:
- ViewModelsCameraViewModel.swift
- ServicesCameraService.swift
- ServicesPhotoLibraryService.swift
- UtilitiesPermissionsManager.swift
- ModelsCameraConfiguration.swift
- ModelsPhotoCapture.swift

Для каждого: File Inspector (⌥⌘1) → Target Membership → галочка

---

## 🐛 Если всё равно ошибки:

### "Missing Privacy - Camera Usage Description"
→ Info.plist не содержит NSCameraUsageDescription
→ Добавь через Способ 2 (Target Settings → Info)

### "Cannot find 'Observation' in scope"
→ Требуется iOS 17+
→ Если у тебя iOS 16, напиши - я переделаю на ObservableObject

### "Undefined symbol: _$s10Observation..."
→ Добавь Observation framework:
   Target → Build Phases → Link Binary With Libraries → + → Observation.framework

---

## 📝 Что было исправлено в коде:

### ServicesCameraService.swift (строка ~160):
**Было:**
```swift
let settings = AVCapturePhotoSettings()
if ... {
    settings.rawPhotoPixelFormatType = ... // ❌ Read-only!
}
```

**Стало:**
```swift
let settings: AVCapturePhotoSettings
if let rawFormat = photoOutput.availableRawPhotoPixelFormatTypes.first {
    settings = AVCapturePhotoSettings(rawPixelFormatType: rawFormat) // ✅
} else {
    settings = AVCapturePhotoSettings()
}
```

### ViewModelsCameraViewModel.swift (строка 1):
**Было:**
```swift
import AVFoundation
import Observation
```

**Стало:**
```swift
import SwiftUI       // ✅ Добавлено
import AVFoundation
import Observation
```

---

## ✅ Финальный чеклист:

- [ ] Код исправлен (ServicesCameraService.swift)
- [ ] Код исправлен (ViewModelsCameraViewModel.swift)
- [ ] Разрешения добавлены в Info.plist (Camera + Photos)
- [ ] Все файлы в Target Membership
- [ ] Clean Build выполнен (⇧⌘K)
- [ ] Build успешен (⌘B)
- [ ] Запуск на РЕАЛЬНОМ устройстве (⌘R)
- [ ] Разрешения камеры/галереи предоставлены при первом запуске

---

**Дата:** 21 января 2026  
**Статус:** ✅ Все ошибки кода исправлены, готово к билду!
