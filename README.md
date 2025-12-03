# Time Tracking Kanban

A Flutter mobile application that combines **Kanban task management** with **Time Tracking** capabilities. This app integrates with the Todoist API to manage tasks across different lifecycle stages and tracks the exact time spent on each task.

## Features

- 📋 **Kanban Board**: Visualize and manage tasks in three columns (To Do, In Progress, Done)
- ⏱️ **Time Tracking**: Start a timer on any task to record time spent
- 💾 **Offline Support**: Works offline with local data synchronization
- 📊 **Task History**: View completed tasks with total time spent
- 💬 **Task Comments**: Add comments to tasks via Todoist API
- 🔄 **Auto Sync**: Automatically syncs data when connectivity is restored

## Screenshots

<div align="center">
  <img src="screenshots/Simulator Screenshot - iPhone 16 Plus - 2025-12-04 at 01.35.31.png" width="250" alt="Kanban Board View"/>
  <img src="screenshots/Simulator Screenshot - iPhone 16 Plus - 2025-12-04 at 01.35.38.png" width="250" alt="Task Details"/>
  <img src="screenshots/Simulator Screenshot - iPhone 16 Plus - 2025-12-04 at 01.35.41.png" width="250" alt="Timer Tracking"/>
</div>

<div align="center">
  <img src="screenshots/Simulator Screenshot - iPhone 16 Plus - 2025-12-04 at 01.35.45.png" width="250" alt="Task History"/>
  <img src="screenshots/Simulator Screenshot - iPhone 16 Plus - 2025-12-04 at 01.35.48.png" width="250" alt="Comments View"/>
  <img src="screenshots/Simulator Screenshot - iPhone 16 Plus - 2025-12-04 at 01.35.55.png" width="250" alt="Settings"/>
</div>

### Demo Videos

- [iPhone Demo](screenshots/iphone_recording.mp4)
- [macOS Demo](screenshots/macos_recording.mov)

## Architecture

This project follows **Clean Architecture** principles with a feature-first structure:

- **Data Layer**: Repositories, API Clients (Retrofit), Local Database (Drift), and DTOs
- **Domain Layer**: Entities, Abstract Repositories, and Use Cases
- **Presentation Layer**: UI Widgets and State Management (BLoC)

### State Management

The app uses the **BLoC (Business Logic Component)** pattern, implemented with `flutter_bloc`, and applies a deliberate split between **BLoCs** and **Cubits**:

- **BLoCs** are used for **complex, event‑driven flows** with multiple types of inputs and state transitions:
  - `KanbanBloc`: Handles loading tasks and sections, grouping them into Kanban columns (To Do, In Progress, Done), and processing create/update/move/close/delete task events.
  - `TimerBloc`: Manages the lifecycle of timers (start, pause, resume, stop, tick, and loading of active timers) and coordinates with the Drift database.
- **Cubits** are used for **simpler view‑state and configuration** where a single intent method can emit new states directly:
  - `ThemeCubit`: Manages light/dark theme selection.
  - `L10nCubit`: Manages the current locale and language switching.
  - `CommentsCubit`: Manages loading, adding, and updating comments for a given task, exposing straightforward states to the UI.
  - `TaskHistoryCubit`: Manages the list of completed tasks and their aggregated time history.

This split keeps **complex features** (Kanban, timer) fully traceable and easy to test via events and states, while **simple UI or configuration concerns** remain lightweight and easy to reason about with Cubits.

## Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK**: Version 3.10.1 or higher
- **Dart SDK**: Compatible with Flutter SDK
- **Todoist Account**: You'll need a Todoist account and API token
- **IDE**: VS Code, Android Studio, or IntelliJ IDEA with Flutter plugins

### Getting Your Todoist API Token

1. Go to [Todoist Settings > Integrations](https://todoist.com/app/settings/integrations)
2. Scroll down to the "Developer" section
3. Copy your API token

## Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd time_tracking_kanaban
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Environment Configuration

The app requires environment variables to be configured. A `.env.example` file is provided as a template.

#### Understanding `.env.example`

The `.env.example` file contains all the environment variables needed to run the application. Here's what each variable does:

- **`TODOIST_API_TOKEN`** (Required): Your Todoist API token for authenticating API requests. Get it from [Todoist Settings > Integrations](https://todoist.com/app/settings/integrations).

- **`PROJECT_ID`** (Optional): A specific Todoist project ID for running integration tests. Only needed if you want to test against a specific project.

- **`USE_REAL_API`** (Optional): Set to `true` to enable integration tests with real API calls. Default is `false` to use mock data.

#### Setting Up Your `.env` File

1. Copy the example file:
   ```bash
   cp .env.example .env
   ```

2. Open `.env` in your text editor and replace the placeholder values:
   ```env
   TODOIST_API_TOKEN=your_actual_api_token_here
   ```

3. (Optional) If you want to run integration tests, you can set:
   ```env
   USE_REAL_API=true
   PROJECT_ID=your_project_id_here
   ```

**Important**: 
- The `.env` file is already in `.gitignore` and will not be committed to version control
- Never commit your actual API token to the repository
- The `.env.example` file serves as a template for other developers

### 4. Generate Code

This project uses code generation for dependency injection, JSON serialization, and API clients. Run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates:
- Dependency injection code (`di.config.dart`)
- JSON serialization code (`.g.dart` files)
- Retrofit API client code (`todoist_api.g.dart`)
- Freezed models (`.freezed.dart` files)
- Drift database code

## Running the Application

### Development Mode

```bash
flutter run
```

### Platform-Specific

#### Android
```bash
flutter run -d android
```

#### iOS
```bash
flutter run -d ios
```

#### Web
```bash
flutter run -d chrome
```

#### Desktop (macOS/Linux/Windows)
```bash
flutter run -d macos  # or linux, windows
```

### Hot Reload

The Flutter development environment supports hot reload:
- Press `r` in the terminal to hot reload
- Press `R` to hot restart

## Testing

This project was built with a **testing-first mindset** and a clear separation between different types of tests. The goals are to keep business logic testable, UI behavior verifiable, and full user flows covered end‑to‑end.

### Testing Philosophy

- **Unit Tests**: Verify pure Dart logic (entities, use cases, repositories, BLoCs/Cubits, and widget logic such as calculations and data transformations) without rendering widgets.
- **Widget Tests (`testWidgets`)**: Verify UI rendering, layout, and widget‑level interactions for reusable components.
- **Integration Tests**: Verify complete user flows, navigation, and cross‑layer behavior on real or emulated devices.

The separation is:
- **`test/`**: Unit tests and widget tests for core utilities, data/domain layers, and presentation logic.
- **`integration_test/`**: Integration tests that boot the full app and drive flows through the UI.

### Test Directory Structure

```text
test/
├── core/
│   ├── database/                # Drift database tests
│   ├── network/                 # Networking and interceptors
│   └── widgets/                 # Unit/widget tests for shared widgets
├── features/
│   ├── tasks/
│   │   ├── data/                # Data layer tests (datasources, models, repositories)
│   │   ├── domain/              # Entities and use cases tests
│   │   └── presentation/        # Kanban BLoC/Cubit tests
│   └── timer/
│       ├── data/                # Timer datasources and repositories tests
│       ├── domain/              # Timer entities and use cases tests
│       └── presentation/        # Timer BLoC/Cubit/widget tests
└── mocks/                       # Reusable mocks and test helpers

integration_test/
├── app_test.dart                # End‑to‑end app initialization test
├── fixtures/                    # Shared integration test data
├── flows/                       # High‑level user flows (tasks, timer, comments)
├── helpers/                     # Test harness and app bootstrap helpers
├── mocks/                       # Integration‑specific mocks
└── robots/                      # Page/feature robots for readable flows
```

### Unit Tests

Unit tests focus on:
- **Business rules** (e.g., how tasks are grouped into Kanban columns).
- **Use case orchestration** (e.g., starting, pausing, and stopping timers).
- **Data transformations** (e.g., mapping Todoist DTOs to domain entities).
- **State calculations** in BLoCs and Cubits.

Run all unit tests in the `test/` directory:

```bash
flutter test test/
```

Run a specific unit test file:

```bash
flutter test test/path/to/test_file.dart
```

### Widget Tests (`testWidgets`)

Widget tests are used when you need to render a widget tree and verify:
- UI rendering and layout.
- Widget‑level interactions (taps, gestures) in isolation.
- Composition of shared widgets (e.g., task cards, columns, dialogs).

Widget tests live alongside other tests in `test/core/widgets/` and in the corresponding `features/**/presentation/widgets/` test folders.

### Integration Tests

Integration tests run against a **real device or emulator** and boot the full application. They are responsible for:
- Testing end‑to‑end flows (e.g., create task → move between columns → complete task → view history).
- Verifying navigation, routing, and screen composition.
- Exercising timer flows from the UI point of view.
- Validating error handling and user feedback in real scenarios.

Run all integration tests:

```bash
flutter test integration_test/
```

Run a specific integration test:

```bash
flutter test integration_test/flows/task_management_test.dart
```

Run on a specific device:

```bash
flutter test integration_test/ -d <device_id>
```

#### API‑Level Integration Tests

Some tests exercise the real Todoist API through the configured HTTP client. These tests are backed by environment variables and are **opt‑in**:

1. Set `USE_REAL_API=true` in your `.env` file.
2. Ensure `TODOIST_API_TOKEN` is set with a valid token.
3. Run the API integration tests:

```bash
flutter test test/features/tasks/data/datasources/todoist_api_integration_test.dart
```

Tests that hit the real API may create temporary data in your Todoist account. They attempt to clean up, but you should still treat them as **test‑only**.

### Running All Tests

Run the entire test suite (unit, widget, and any integration tests under `test/` and `integration_test/`):

```bash
flutter test
```

### Test Coverage

Generate a coverage report:

```bash
flutter test --coverage
```

You can use `lcov`/`genhtml` locally to visualize coverage if desired. The target is:
- **80%+ coverage** for core business logic (use cases, repositories, entities, BLoCs/Cubits).
- Coverage of all critical user flows via integration tests.

## Project Structure

```
lib/
├── core/                           # Cross-cutting concerns and shared building blocks
│   ├── database/                   # Drift database and DAOs
│   ├── errors/                     # Failure and exception abstractions
│   ├── l10n/                       # Localization cubit and helpers
│   ├── navigation/                 # App router configuration (go_router)
│   ├── network/                    # Dio/Retrofit client, interceptors, modules
│   ├── preferences/                # Shared preferences helpers
│   ├── screens/                    # Shell/root screens shared across features
│   ├── services/                   # Cross-cutting services
│   ├── theme/                      # Theme cubit, colors, typography
│   ├── usecases/                   # Base use case abstractions
│   ├── utils/                      # Utility classes and helpers
│   └── widgets/                    # Shared UI widgets
├── features/
│   ├── tasks/                      # Task / Kanban board feature
│   │   ├── data/                   # Data layer
│   │   │   ├── datasources/        # Local (Drift) and remote (Todoist API) datasources
│   │   │   ├── models/             # DTOs and persistence models
│   │   │   └── repositories/       # Repository implementations
│   │   ├── domain/                 # Domain layer
│   │   │   ├── entities/           # Pure business entities
│   │   │   ├── repositories/       # Abstract repository contracts
│   │   │   └── usecases/           # Task-related business logic
│   │   └── presentation/           # Presentation layer
│   │       ├── bloc/               # Kanban BLoCs
│   │       ├── cubit/              # Comments and other UI state Cubits
│   │       └── widgets/            # Feature-specific widgets and screens
│   └── timer/                      # Time tracking feature
│       ├── data/                   # Timer data layer
│       ├── domain/                 # Timer entities and use cases
│       └── presentation/           # Timer BLoC, cubits, and widgets
├── di.dart                         # Dependency injection entrypoint
├── di.config.dart                  # Generated DI configuration (injectable)
└── main.dart                       # Application entry point

test/
├── core/                           # Tests for core utilities, widgets, and services
├── features/                       # Tests for tasks and timer features
└── mocks/                          # Shared mocks and test setup

integration_test/
├── app_test.dart                   # Full app smoke test
├── fixtures/                       # Reusable test data
├── flows/                          # High‑level user flow tests
├── helpers/                        # Test harness and app bootstrap
├── mocks/                          # Integration‑specific mocks
└── robots/                         # Screen/feature robots encapsulating UI interactions

.github/
└── workflows/
    └── flutter-ci.yml              # CI pipeline for tests and builds

coverage/                           # Generated coverage reports (e.g., lcov.info)
build/                              # Flutter build output (ignored by VCS)
```

## Technologies & Dependencies

### Core Dependencies

- **flutter_bloc**: State management using BLoC/Cubit with clear separation between complex flows (BLoCs) and simple view‑state (Cubits).
- **injectable** / **get_it**: Dependency injection container and code generation for wiring repositories, use cases, and state management.
- **dio**: HTTP client for Todoist API requests with interceptors and robust error handling.
- **retrofit**: Type-safe REST client generator on top of `dio`, used for the Todoist API interface.
- **drift** / **drift_flutter**: Reactive SQLite database for offline‑first task, time log, and comment persistence.
- **flutter_dotenv**: Environment variable management (e.g., Todoist API token, test toggles).
- **freezed** / **freezed_annotation**: Immutable data classes and sealed unions for entities, models, and states.
- **json_annotation**: JSON serialization for API models.
- **equatable**: Value equality for non‑Freezed types and simple value objects.

### Development Dependencies

- **build_runner**: Code generation driver for `injectable`, `freezed`, `json_serializable`, `retrofit`, and `drift`.
- **injectable_generator** / **retrofit_generator** / **drift_dev** / **json_serializable** / **freezed**: Generators for DI, API clients, database, JSON, and immutable models.
- **mockito** / **http_mock_adapter**: Mocking frameworks for repositories, APIs, and HTTP interactions.
- **bloc_test**: High‑level testing utilities for BLoCs and Cubits.
- **flutter_test** / **integration_test**: Flutter’s testing libraries for unit, widget, and integration tests.
- **flutter_lints**: Opinionated lint rules to enforce consistent code style and best practices.

## Code Generation

Whenever you modify:
- Injectable dependencies
- Freezed models
- JSON serializable models
- Retrofit API clients
- Drift database schemas

Run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

For continuous generation during development:

```bash
flutter pub run build_runner watch
```

## Architecture Decisions

### Clean Architecture

The project follows Clean Architecture to ensure:
- **Testability**: Business logic is independent of frameworks
- **Maintainability**: Clear separation of concerns
- **Scalability**: Easy to add new features

### BLoC Pattern

BLoC is used for state management because it:
- Separates business logic from UI
- Makes the app testable
- Provides reactive state updates
- Works well with dependency injection

### Dependency Injection

Using `injectable` and `get_it` provides:
- Centralized dependency management
- Easy mocking for tests
- Lazy initialization
- Singleton management

## Development Process & TDD

The implementation of this app followed a **Test‑Driven Development (TDD)** mindset:

- For new features, the typical flow was:
  1. Define or refine the use cases and entities for the feature.
  2. Write **unit tests** for the use cases, repositories, and BLoCs/Cubits describing the desired behavior.
  3. Implement the production code until the tests passed.
  4. Add **widget tests** for reusable UI components where rendering and interactions mattered.
  5. Add or extend **integration tests** to cover the end‑to‑end user flows.
- The test suite was reorganized to:
  - Keep **widget logic tests** as fast unit tests that do not depend on full widget rendering.
  - Move **screen‑level tests** into `integration_test/` so they exercise the real app structure and navigation.

This process ensures that business rules are always protected by tests, and that refactors can be performed with confidence.

## CI/CD with GitHub Actions

Continuous Integration is handled by a GitHub Actions workflow located at `.github/workflows/flutter-ci.yml`. It runs automatically on every push to the `master` branch and performs the following steps:

1. **Checkout & Environment Setup**
   - Checks out the repository.
   - Sets up Java 17.
   - Installs Flutter (stable channel) with caching enabled.
2. **Dependencies & Tests**
   - Runs `flutter pub get` to install dependencies.
   - Runs `flutter test` to execute all unit and widget tests (and any integration tests included under `test/`).
3. **Build Artifacts**
   - Builds an **Android profile APK** with `flutter build apk --profile`.
   - Builds an **iOS profile app** with `flutter build ios --profile --no-codesign`.
   - Archives and uploads the Android APK and iOS app as build artifacts.

This pipeline enforces the testing strategy (tests must pass before builds succeed) and provides ready‑to‑download artifacts for manual QA. Contributors are encouraged to run `flutter test` locally before pushing to keep the CI green.

### Environment Variables & GitHub Secrets

The CI workflow does **not** create a `.env` file automatically. If your CI pipeline needs values that you normally keep in `.env` (for example `TODOIST_API_TOKEN` when running real API integration tests), you must:

- Add the required values as **GitHub Secrets** in the repository settings (e.g., `TODOIST_API_TOKEN`, `USE_REAL_API`, or any other sensitive configuration).
- Expose those secrets in the workflow as environment variables for the relevant steps, or write them into a temporary `.env` file in a dedicated step before running `flutter test` or build commands.

This keeps secrets out of the codebase and ensures that local development can still rely on a `.env` file while CI uses GitHub Secrets.

## Troubleshooting

### Build Errors

If you encounter build errors after pulling changes:

1. Clean the build:
   ```bash
   flutter clean
   ```

2. Reinstall dependencies:
   ```bash
   flutter pub get
   ```

3. Regenerate code:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

### Environment Variable Not Found

If you see an error about `TODOIST_API_TOKEN`:

1. Ensure `.env` file exists in the project root
2. Verify the token is set correctly (no quotes, no extra spaces)
3. Restart the app after creating/modifying `.env`

### Integration Test Failures

If integration tests fail:

1. Check that `USE_REAL_API=true` is set (if using real API)
2. Verify your API token is valid
3. Check your internet connection
4. Ensure you have permissions to create/delete tasks in your Todoist account

## Contributing

1. Create a feature branch
2. Make your changes
3. Write or update tests
4. Run tests and ensure they pass
5. Run code generation if needed
6. Submit a pull request

## License

[Specify your license here]

## Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Todoist API Documentation](https://developer.todoist.com/)
- [BLoC Documentation](https://bloclibrary.dev/)
- [Clean Architecture Guide](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
