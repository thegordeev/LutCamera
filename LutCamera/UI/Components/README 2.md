# CustomCam 📸

Professional camera app with real-time LUT processing and dual-file capture.

---

## Quick Start

### Requirements
- iOS 17.0+
- Xcode 15.0+
- Real iPhone device (camera doesn't work on simulator)

### Setup

1. **Add permissions to Info.plist:**
```xml
<key>NSCameraUsageDescription</key>
<string>Camera access for photo capture</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>Save photos to gallery</string>
```

2. **Build and run:**
```bash
⇧⌘K  # Clean
⌘B   # Build
⌘R   # Run on device
```

---

## Current Features (v1.0)

✅ Live camera preview  
✅ Photo capture with gallery save  
✅ Zoom control (0.5x, 1x, 2x)  
✅ Camera flip (front/back)  
✅ Last photo preview  
✅ Permission handling  

---

## Architecture

```
MVVM Pattern:
View → ViewModel → Service → Framework

CameraView
  └─ CameraViewModel
      ├─ CameraService (AVFoundation)
      ├─ PhotoLibraryService (Photos)
      └─ PermissionsManager
```

**See REQUIREMENTS.md for full architecture details**

---

## Project Structure

```
CustomCam/
├── Views/
│   └── CameraView.swift
├── ViewModels/
│   └── CameraViewModel.swift
├── Services/
│   ├── CameraService.swift
│   └── PhotoLibraryService.swift
├── Models/
│   ├── CameraConfiguration.swift
│   └── PhotoCapture.swift
├── Components/
│   ├── ZoomButton.swift
│   ├── ShutterButton.swift
│   ├── GalleryButton.swift
│   └── ... (8 total)
├── Theme/
│   └── AppTheme.swift
└── Utilities/
    └── PermissionsManager.swift
```

---

## Common Issues

**Build fails - duplicate files:**
```bash
# Check for duplicates like:
# - ComponentsZoomButton.swift (old) ❌
# - ZoomButton.swift (new) ✅
# Delete all files with "Components" prefix
```

**Camera shows black screen:**
- Running on simulator? → Use real device
- Permission denied? → Settings → CustomCam → Camera → Allow

**Photo not saving:**
- Permission denied? → Settings → CustomCam → Photos → Allow

---

## Development

**Before commit:**
1. Clean build (`⇧⌘K`)
2. Check for duplicate files
3. Verify build passes (`⌘B`)
4. Test on real device

**Code standards:**
- See REQUIREMENTS.md section 5-6
- One component per file
- No hardcoded values
- Clean up duplicates immediately

---

## Roadmap

**v1.1 (Next):**
- [ ] Dual capture (JPEG + ProRAW)
- [ ] LUT processing
- [ ] Haptic feedback

**Future:**
- Custom LUT import (.cube)
- Manual exposure controls
- Settings persistence

---

## Documentation

- **README.md** (this file) - Quick start
- **REQUIREMENTS.md** - Full project specification
- **Docs/** - Additional documentation (if needed)

---

**Version:** 1.0 MVP  
**Last Updated:** January 21, 2026  
**Status:** ✅ Production Ready
