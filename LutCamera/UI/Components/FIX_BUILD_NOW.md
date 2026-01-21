# 🚨 СРОЧНО - ИСПРАВЛЕНИЕ BUILD

## Проблема:
```
Multiple commands produce .../GalleryButton.stringsdata
Multiple commands produce .../BottomControlPanel.stringsdata
```

## Причина:
У тебя есть ДВА файла GalleryButton и ДВА файла BottomControlPanel!

---

## Решение (1 минута):

### В Xcode удали эти файлы (Move to Trash):

1. **ComponentsGalleryButton.swift** ❌
2. **ComponentsBottomControlPanel.swift** ❌  
3. **BottomControlPanel 2.swift** ❌
4. **ComponentsZoomButton.swift** ❌
5. **ComponentsShutterButton.swift** ❌
6. **ComponentsFlipCameraButton.swift** ❌
7. **ComponentsCameraTopSafeArea.swift** ❌
8. **ComponentsCameraPreviewLayer.swift** ❌
9. **ComponentsZoomControls.swift** ❌

### Оставь только:

1. **GalleryButton.swift** ✅
2. **BottomControlPanel.swift** ✅ (БЕЗ "2"!)
3. **ZoomButton.swift** ✅
4. И т.д. (без префикса "Components")

---

## После удаления:

```
⇧⌘K - Clean
⌘B - Build ДОЛЖЕН пройти!
```

---

## Если всё равно ошибка:

1. Закрой Xcode
2. Удали папку DerivedData:
```
~/Library/Developer/Xcode/DerivedData/
```
3. Открой Xcode снова
4. ⇧⌘K → ⌘B

---

**Удаляй дубликаты СЕЙЧАС! Build не пройдёт пока они есть!**
