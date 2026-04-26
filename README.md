# Deep Focus

A minimalist and beautiful productivity app built with Flutter, designed to help users maintain focus through timed work sessions and ambient background sounds.

## 🚀 Features

- **Pomodoro Timer**: Customizable work and break intervals.
- **Ambient Sounds**: High-quality background audio (Rain, Forest, White Noise, etc.).
- **Modern UI**: Sleek, glassmorphic design with smooth animations.
- **Settings**: Fully configurable session lengths and preferences.

## 🏗 Architecture

The project follows a **Feature-based MVVM (Model-View-ViewModel)** architectural pattern using **Provider** for state management. This ensures a clean separation of concerns and scalability.

- **Model**: Data entities and business logic.
- **View**: UI components and screens.
- **ViewModel (Provider)**: Logic for managing state and reacting to user interactions.

## 📂 Project Structure

```text
lib/
├── core/               # Shared logic and styling
│   ├── constant/       # App constants (colors, strings)
│   ├── services/       # External services (audio, storage)
│   ├── theme/          # App theme data
│   └── widgets/        # Common UI components
├── features/           # Feature-based MVVM modules
│   ├── focus/          # Timer and focus logic
│   │   ├── model/      # Focus-related data
│   │   ├── view/       # Focus screen
│   │   ├── viewmodel/  # Timer provider
│   │   └── widget/     # Focus-specific widgets
│   ├── settings/       # User preferences
│   │   ├── view/       # Settings screen
│   │   ├── viewmodel/  # Settings provider
│   │   └── widget/
│   └── sounds/         # Ambient sound library
│       ├── model/      # Sound entities
│       ├── view/       # Sounds screen
│       ├── viewmodel/  # Audio provider
│       └── widget/
├── main.dart           # App entry point
├── navigation.dart     # Routing logic
└── providers.dart      # Global provider registration
```

## 🛠 Tech Stack

- **Flutter**: Cross-platform framework.
- **Dart**: 3.11.4
- **Provider**: State management.
- **Just Audio**: High-performance audio playback.
- **Google Fonts**: Custom typography.

## 🏁 Getting Started

1. Clone the repository.
2. Run `flutter pub get` to install dependencies.
3. Use `flutter run` to launch the app on your preferred device.
