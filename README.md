# Merch AI Mobile

[![Flutter](https://img.shields.io/badge/Flutter-stable-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
![Dart](https://img.shields.io/badge/Dart-%5E3.10.7-0175C2?logo=dart&logoColor=white)
![Version](https://img.shields.io/badge/App-1.0.0-6A5ACD)

Mobile app for generating merch concepts quickly using a guided questionnaire flow.

## Features

- Guided multi-step questionnaire to define merch requirements
- Optional logo upload from gallery/camera
- Product and placement choices (category, product type, design placement, style)
- Base color picker with live T-shirt preview
- AI-generated merch outputs shown as a swipeable result carousel
- Save generated mockups to device storage

## Tech Stack

- Flutter + Dart
- State management: `provider`
- Networking: `http`
- Media and rendering: `image_picker`, `flutter_svg`
- Config: `flutter_dotenv`

## Project Structure

```text
lib/
  pages/
    home_page.dart
    questionnaire_page.dart
    results_page.dart
  providers/
    merch_provider.dart
  widgets/
    ...
```

## Getting Started

### Prerequisites

- Flutter SDK (stable channel)
- Dart SDK compatible with `^3.10.7`
- Android Studio / Xcode (depending on your target platform)

### 1) Install dependencies

```bash
flutter pub get
```

### 2) Configure environment values

Create/update environment config files under `assets/env/` (for API keys/endpoints used by generation requests).

### 3) Run the app

```bash
flutter run
```

To run on a specific device:

```bash
flutter devices
flutter run -d <device_id>
```

## Build

### Android APK

```bash
flutter build apk --release
```

### Android App Bundle

```bash
flutter build appbundle --release
```

### iOS (macOS only)

```bash
flutter build ios --release
```

## How It Works

1. **Home screen** starts the merch creation flow.
2. **Questionnaire** collects user inputs: category, product, logo, tagline, placement, color, and style.
3. **Provider state** (`MerchProvider`) tracks progress, selections, and generation lifecycle.
4. **Generation step** sends the assembled request payload to the backend/AI service.
5. **Results page** displays generated images in a carousel (front/back/lifestyle style views).
6. **Save/order action** lets users persist the currently selected design image locally.

## Useful Commands

```bash
flutter analyze
flutter test
```
