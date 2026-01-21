# 🏗️ Архитектура камеры - Визуальная схема

## MVVM Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         CameraView                              │
│                       (SwiftUI View)                            │
│                                                                 │
│  @State private var viewModel = CameraViewModel()              │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │ CameraPreview│  │ ZoomControls │  │BottomControl │         │
│  │    Layer     │  │              │  │    Panel     │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
│         │                 │                   │                │
│         │                 │                   │                │
└─────────┼─────────────────┼───────────────────┼────────────────┘
          │                 │                   │
          │    Binding      │      Actions      │
          ▼                 ▼                   ▼
┌─────────────────────────────────────────────────────────────────┐
│                     CameraViewModel                             │
│                  (@Observable class)                            │
│                                                                 │
│  State:                        Methods:                         │
│  • currentZoomLevel            • onAppear()                     │
│  • isSessionRunning            • onDisappear()                  │
│  • lastCapturedPhoto           • capturePhoto()                 │
│  • errorMessage                • switchCamera()                 │
│  • isCaptureInProgress         • setZoom()                      │
│                                                                 │
└───────┬─────────────┬─────────────┬─────────────┬──────────────┘
        │             │             │             │
        │             │             │             │
        ▼             ▼             ▼             ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│  Permission  │ │   Camera     │ │ PhotoLibrary │ │    Models    │
│   Manager    │ │   Service    │ │   Service    │ │              │
├──────────────┤ ├──────────────┤ ├──────────────┤ ├──────────────┤
│              │ │              │ │              │ │ Camera       │
│ Request      │ │ Setup        │ │ Save Image   │ │ Configuration│
│ Camera       │ │ Session      │ │              │ │              │
│ Permission   │ │              │ │ Save Dual    │ │ Photo        │
│              │ │ Start/Stop   │ │ Capture      │ │ Capture      │
│ Request      │ │ Session      │ │              │ │              │
│ Photo        │ │              │ │ Fetch Last   │ │              │
│ Permission   │ │ Set Zoom     │ │ Photo        │ │              │
│              │ │              │ │              │ │              │
│              │ │ Switch       │ │              │ │              │
│              │ │ Camera       │ │              │ │              │
│              │ │              │ │              │ │              │
│              │ │ Capture      │ │              │ │              │
│              │ │ Photo        │ │              │ │              │
└──────────────┘ └──────┬───────┘ └──────┬───────┘ └──────────────┘
                        │                │
                        ▼                ▼
                ┌──────────────┐ ┌──────────────┐
                │ AVFoundation │ │    Photos    │
                │              │ │  Framework   │
                │ • AVCapture  │ │              │
                │   Session    │ │ • PHPhoto    │
                │              │ │   Library    │
                │ • AVCapture  │ │              │
                │   Photo      │ │ • PHAsset    │
                │   Output     │ │              │
                └──────────────┘ └──────────────┘
```

---

## Data Flow - Запуск камеры

```
User opens app
    │
    ▼
CameraView appears
    │
    ├─ .task { await viewModel.onAppear() }
    │
    ▼
CameraViewModel.onAppear()
    │
    ├─ Step 1: Request Permissions
    │   │
    │   └─→ PermissionsManager
    │           ├─ requestCameraPermission()
    │           │   └─→ AVCaptureDevice.requestAccess()
    │           │
    │           └─ requestPhotoLibraryPermission()
    │               └─→ PHPhotoLibrary.requestAuthorization()
    │
    ├─ Step 2: Setup Camera
    │   │
    │   └─→ CameraService.setupSession()
    │           ├─ captureSession.beginConfiguration()
    │           ├─ Create AVCaptureDeviceInput (camera)
    │           ├─ Add input to session
    │           ├─ Create AVCapturePhotoOutput
    │           ├─ Add output to session
    │           ├─ Configure ProRAW (if available)
    │           └─ captureSession.commitConfiguration()
    │
    └─ Step 3: Start Preview
        │
        └─→ CameraService.startSession()
                │
                └─→ captureSession.startRunning()
                        │
                        ▼
                    Preview Layer displays camera feed
                        │
                        ▼
                    CameraPreviewLayer shows live video
```

---

## Data Flow - Захват фото

```
User taps ShutterButton
    │
    ▼
BottomControlPanel.onCapture()
    │
    ▼
CameraViewModel.capturePhoto()
    │
    ├─ Set isCaptureInProgress = true
    │
    └─→ CameraService.capturePhoto()
            │
            ├─ Create AVCapturePhotoSettings
            ├─ Configure RAW (if enabled)
            ├─ Set quality prioritization
            │
            └─→ photoOutput.capturePhoto(delegate)
                    │
                    ▼
                PhotoCaptureDelegate.didFinishProcessingPhoto()
                    │
                    ├─ Extract image data
                    ├─ Extract RAW data (if available)
                    │
                    └─→ Create PhotoCapture model
                            │
                            ▼
                        CameraViewModel receives PhotoCapture
                            │
                            ├─ Store in lastCapturedPhoto
                            │
                            └─→ savePhotoToLibrary()
                                    │
                                    └─→ PhotoLibraryService.saveDualCapture()
                                            │
                                            ├─ Save processed image
                                            ├─ Save RAW data (if exists)
                                            │
                                            └─→ PHPhotoLibrary.performChanges()
                                                    │
                                                    ▼
                                                Photo saved ✅
                                                    │
                                                    ▼
                                            User can view in Photos app
```

---

## Data Flow - Изменение зума

```
User taps ZoomButton (e.g., "2x")
    │
    ▼
ZoomButton.action()
    │
    └─→ ZoomControls sets currentZoomLevel = 2.0
            │
            └─→ Binding updates ViewModel
                    │
                    ▼
                CameraViewModel.currentZoomLevel (didSet)
                    │
                    └─→ CameraService.setZoom(2.0)
                            │
                            ├─ device.lockForConfiguration()
                            ├─ device.videoZoomFactor = 2.0
                            └─ device.unlockForConfiguration()
                                    │
                                    ▼
                                Camera zooms in real-time
```

---

## Data Flow - Переключение камеры

```
User taps FlipCameraButton
    │
    ▼
BottomControlPanel.onFlipCamera()
    │
    ▼
CameraViewModel.switchCamera()
    │
    └─→ CameraService.switchCamera()
            │
            ├─ captureSession.beginConfiguration()
            ├─ Remove current camera input
            ├─ Determine new position (front ↔ back)
            ├─ Get new camera device
            ├─ Create new AVCaptureDeviceInput
            ├─ Add new input to session
            └─ captureSession.commitConfiguration()
                    │
                    ▼
                Preview switches to new camera
```

---

## Components Hierarchy (Updated)

```
CameraView
├── CameraTopSafeArea
│   └── Color.black (50px height)
│
├── ZStack (Camera + Controls)
│   ├── CameraPreviewLayer
│   │   └── CameraPreviewRepresentable
│   │       └── UIViewRepresentable
│   │           └── PreviewView (UIView)
│   │               └── AVCaptureVideoPreviewLayer
│   │                   └── Live camera feed
│   │
│   └── ZoomControls (overlay)
│       ├── ZoomButton ("0.5")
│       ├── ZoomButton ("1x") ← selected
│       └── ZoomButton ("2")
│
└── BottomControlPanel
    ├── GalleryButton
    ├── ShutterButton
    └── FlipCameraButton
```

---

## File Dependencies

```
CameraView.swift
    ↓ uses
CameraViewModel.swift
    ↓ uses
┌───────────────┬──────────────────┬──────────────────┐
│               │                  │                  │
PermissionsManager  CameraService  PhotoLibraryService  Models
    ↓               ↓                  ↓              ↓
AVFoundation    AVFoundation       Photos      Foundation
```

---

## State Management

```
┌─────────────────────────────────────────────────────────┐
│                  CameraViewModel                        │
│                  @Observable                            │
│                                                         │
│  Published State (auto-updates UI):                    │
│  • currentZoomLevel: Double                            │
│  • isSessionRunning: Bool                              │
│  • lastCapturedPhoto: PhotoCapture?                    │
│  • errorMessage: String?                               │
│  • isCaptureInProgress: Bool                           │
└─────────────────────────────────────────────────────────┘
                         │
                         │ @Observable macro creates
                         │ automatic observation
                         ▼
┌─────────────────────────────────────────────────────────┐
│                    CameraView                           │
│                                                         │
│  @State private var viewModel = CameraViewModel()      │
│                                                         │
│  Any change in viewModel properties → UI updates       │
└─────────────────────────────────────────────────────────┘
```

---

## Permission Flow

```
App Launch
    ↓
CameraView.task { await viewModel.onAppear() }
    ↓
PermissionsManager.requestCameraPermission()
    ↓
┌─────────────────────────────────────┐
│  Camera Permission Status:          │
│  ┌────────────┐                     │
│  │.notDetermined│ → Request dialog  │
│  │.authorized │ → ✅ Proceed       │
│  │.denied     │ → ❌ Show error    │
│  │.restricted │ → ❌ Show error    │
│  └────────────┘                     │
└─────────────────────────────────────┘
    ↓
PermissionsManager.requestPhotoLibraryPermission()
    ↓
┌─────────────────────────────────────┐
│  Photo Library Status:               │
│  ┌────────────┐                     │
│  │.notDetermined│ → Request dialog  │
│  │.authorized │ → ✅ Proceed       │
│  │.limited    │ → ✅ Proceed       │
│  │.denied     │ → ❌ Show error    │
│  └────────────┘                     │
└─────────────────────────────────────┘
    ↓
Both granted ✅
    ↓
Setup and start camera
```

---

**Используйте эту схему для:**
- Понимания потока данных
- Отладки проблем
- Планирования новых фич
- Объяснения архитектуры

**Дата:** 21 января 2026
