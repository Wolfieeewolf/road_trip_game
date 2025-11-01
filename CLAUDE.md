# Road Trip Game Development Guide

## Build Commands
- Run app: `flutter run -d windows` or `.\run.bat`
- Clean and run: `.\run_and_clean.bat`
- Get dependencies: `flutter pub get`
- Format code: `dart format lib`
- Analyze code: `flutter analyze`
- Run tests: `flutter test`
- Run single test: `flutter test test/path_to_test.dart`

## Code Style Guidelines
- **Imports**: Group Flutter, then third-party, then project imports
- **Classes**: Use immutable pattern with required constructor params
- **State Management**: Use Provider pattern where appropriate
- **Naming**: CamelCase for classes, camelCase for variables/methods
- **Documentation**: Doc comments for public APIs and complex methods
- **Error Handling**: Use try/catch with meaningful error messages
- **Models**: Implement toJson/fromJson for all data models
- **Design Patterns**: Follow factory constructor pattern, copyWith for immutability
- **Type Safety**: Use strong typing with non-nullable types when possible

Follows Flutter's style guide via flutter_lints package.