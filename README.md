# Time Tracking Kanban

A Flutter mobile application that combines **Kanban task management** with **Time Tracking** capabilities. This app integrates with the Todoist API to manage tasks across different lifecycle stages and tracks the exact time spent on each task.

## Features

- 📋 **Kanban Board**: Visualize and manage tasks in three columns (To Do, In Progress, Done)
- ⏱️ **Time Tracking**: Start a timer on any task to record time spent
- 💾 **Offline Support**: Works offline with local data synchronization
- 📊 **Task History**: View completed tasks with total time spent
- 💬 **Task Comments**: Add comments to tasks via Todoist API
- 🔄 **Auto Sync**: Automatically syncs data when connectivity is restored

## Architecture

This project follows **Clean Architecture** principles with a feature-first structure:

- **Data Layer**: Repositories, API Clients (Retrofit), Local Database (Drift), and DTOs
- **Domain Layer**: Entities, Abstract Repositories, and Use Cases
- **Presentation Layer**: UI Widgets and State Management (BLoC)

### State Management

The app uses **BLoC (Business Logic Component)** pattern for state management, providing a clear separation of concerns and testability.

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

### Unit Tests

Run all unit tests:

```bash
flutter test
```

Run tests for a specific file:

```bash
flutter test test/path/to/test_file.dart
```

### Integration Tests

Integration tests are configured to use mock data by default. To run tests against the real Todoist API:

1. Set `USE_REAL_API=true` in your `.env` file
2. Ensure `TODOIST_API_TOKEN` is set with a valid token
3. Run the integration tests:

```bash
flutter test test/core/network/todoist_api_integration_test.dart
```

**Note**: Integration tests that use the real API may create test data in your Todoist account. Tests attempt to clean up, but use caution.

### Test Coverage

Generate test coverage report:

```bash
flutter test --coverage
```

View the coverage report (requires `lcov`):

```bash
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Project Structure

```
lib/
├── core/                          # Core functionality
│   ├── errors/                    # Error handling
│   ├── network/                   # Network configuration
│   │   ├── todoist_api.dart      # Retrofit API client
│   │   ├── network_module.dart   # Dependency injection
│   │   └── todoist_response_interceptor.dart
│   ├── usecases/                  # Base use case classes
│   ├── utils/                     # Utility classes
│   └── widgets/                   # Shared widgets
├── features/
│   ├── tasks/                     # Task management feature
│   │   ├── data/                  # Data layer
│   │   │   ├── datasources/       # Data sources (local/remote)
│   │   │   ├── models/            # Data models/DTOs
│   │   │   └── repositories/      # Repository implementations
│   │   ├── domain/                # Domain layer
│   │   │   ├── entities/          # Business entities
│   │   │   ├── repositories/      # Abstract repositories
│   │   │   └── usecases/          # Business logic
│   │   └── presentation/          # Presentation layer
│   │       ├── bloc/              # BLoC state management
│   │       └── widgets/           # UI components
│   └── timer/                     # Time tracking feature
│       └── [similar structure]
├── di.dart                        # Dependency injection entry
├── di.config.dart                 # Generated DI code
└── main.dart                      # Application entry point

test/
├── core/                          # Core tests
├── features/                      # Feature tests
└── mocks/                         # Mock objects
```

## Technologies & Dependencies

### Core Dependencies

- **flutter_bloc**: State management using BLoC pattern
- **injectable** / **get_it**: Dependency injection
- **dio**: HTTP client for API requests
- **retrofit**: Type-safe REST client generator
- **drift**: Reactive database for local storage
- **flutter_dotenv**: Environment variable management
- **freezed**: Immutable classes and unions
- **json_annotation**: JSON serialization
- **equatable**: Value equality comparisons

### Development Dependencies

- **build_runner**: Code generation
- **mockito**: Mocking framework for tests
- **bloc_test**: Testing utilities for BLoC
- **flutter_lints**: Linting rules

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
