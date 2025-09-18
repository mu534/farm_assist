# Copilot Instructions for farmer_asist

## Project Overview

- This is a cross-platform Flutter app for plant disease detection and recommendations, using AI image analysis.
- Main code is in `lib/`, with UI screens in `lib/ui/screens/`, core logic in `lib/core/`, and AI integration in `lib/ui/services/ai_service.dart`.

## Architecture & Data Flow

- The app uses a service-oriented pattern: UI screens call services (e.g., `AIService`) for business logic and external integrations.
- Image capture and cropping is handled in `camera_screen.dart`, which passes images to `AIService` for analysis.
- Results are displayed in `result_screen.dart`, which expects a result object with fields like `imagePath`, `diseaseName`, `recommendation`, and `confidence`.
- Models (e.g., `PlantDiseaseModel`) are in `lib/ui/models/`.

## Developer Workflows

- **Build/Run:** Use `flutter run` for local development. Android/iOS/web targets are supported.
- **Testing:** Widget tests are in `test/widget_test.dart`. Run with `flutter test`.
- **Debugging:** Use Flutter DevTools or IDE debugging. For device logs, use `flutter logs`.
- **Assets:** Images, fonts, and icons are in `assets/`. Update `pubspec.yaml` to register new assets.

## Project-Specific Patterns

- All image analysis is routed through `AIService.analyzeImage(File)`.
- Navigation between screens uses `Navigator.push` with explicit parameter passing (e.g., `ResultScreen(result: ...)`).
- UI follows a theme system defined in `lib/core/themes.dart` and uses custom text styles from `AppTextStyles`.
- Crop logic for images is in `camera_screen.dart` using the `image` package.

## Integration Points

- External AI logic is abstracted in `AIService`. Update this service for changes in backend or model APIs.
- Camera functionality uses the `camera` package. Image manipulation uses the `image` package.
- Platform-specific code is in `android/`, `ios/`, `web/`, `linux/`, `macos/`, and `windows/` folders.

## Conventions

- Use `StatelessWidget` for screens that only display data, and `StatefulWidget` for screens that perform async operations (e.g., image analysis).
- Pass all required data via constructors; avoid global state.
- Keep business logic out of UI widgets—use services and models.

## Key Files & Directories

- `lib/ui/screens/camera_screen.dart`: Camera and image cropping logic
- `lib/ui/screens/result_screen.dart`: Displays analysis results
- `lib/ui/services/ai_service.dart`: AI integration
- `lib/core/themes.dart`: App theming
- `lib/ui/models/plant_disease_model.dart`: Data model for results
- `assets/`: Static assets

---

If any section is unclear or missing, please provide feedback to improve these instructions.
