# REQUIREMENTS.md

## 1. Project Overview
**Name:** CustomCam (Working Title)
**Platform:** iOS (SwiftUI, UIKit via representables if needed)
**Core Value:** Real-time LUT application with dual-file saving (Processed + Raw).
**Target Audience:** Prosumers, creative directors, photographers requiring custom color grading on the fly.

## 2. Technical Stack
- **Language:** Swift 5+
- **Framework:** SwiftUI (lifecycle), AVFoundation (Camera logic), CoreImage (LUT processing).
- **Architecture:** MVVM (Model-View-ViewModel).
- **Style:** Component-based UI. No hardcoded frames for layout. Adaptive design.

## 3. Key Features (Roadmap)
### v1.0 (MVP)
- **Viewfinder:** 16:9 Aspect Ratio.
- **Dual Capture:**
  1. Processed JPEG/HEIC (with LUT applied).
  2. Clean ProRAW (48MP) from sensor.
- **Lens Selection:** 0.5x (Ultra Wide), 1x (Wide), 2x (Telephoto).
- **Gallery Access:** Quick preview of the last photo.
- **UI:** Minimalist, transparent overlays, distinct shutter button.

### Future Features
- Custom LUT import (.cube).
- Manual Exposure controls (+/- 2EV, lateral slider).
- Settings persistence (UserDefaults/AppStorage).
- Lock screen widget.

## 4. UI/UX Guidelines
- **Fonts:** SF Pro Display.
- **Layout:** Adaptive (GeometryReader/Spacers), avoid absolute positioning.
- **Theme:** Dark/Black mode default.
- **Feedback:** Haptic feedback on shutter and dial changes.

## 5. Coding Standards
- **DRY:** Don't Repeat Yourself. Extract repeated UI into `Components`.
- **Constants:** All colors, hardcoded sizes, and config strings must live in `AppConfig` or `Theme` struct.
- **Documentation:** Brief comments for complex logic. Updates to this file upon architecture changes.