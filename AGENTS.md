
# AGENTS.md — AirScope

## 1. Project Overview

AirScope is an Android air quality monitoring application developed using Flutter and Dart.

The application retrieves air quality information through Open-Meteo REST APIs.

This project is developed for a Mobile Programming course assignment.

## 2. Required Technologies

- Flutter
- Dart
- Material Design 3
- Open-Meteo Geocoding API
- Open-Meteo Air Quality API
- HTTP
- FutureBuilder
- SharedPreferences

Do not replace required technologies without a clear technical reason.

## 3. Core Assignment Requirements

The application must implement:

1. REST API integration.
2. Asynchronous UI using FutureBuilder.
3. Loading, Success, and Error states.
4. Local storage for the last searched city.

These requirements must remain part of the final application.

## 4. Architecture

Use a Feature-First architecture.

Separate responsibilities into:

### Domain
- Data models.
- Core business representations.

### Data
- API services.
- Repository implementations.
- Data parsing.

### Presentation
- Pages.
- Widgets.
- User interface.
- UI state handling.

### Core
- Shared theme.
- Constants.
- Reusable components.

Avoid unnecessary architectural complexity.

## 5. Coding Standards

- Use Dart null safety.
- Use descriptive names.
- Prefer const constructors.
- Keep functions focused.
- Avoid duplicated code.
- Handle exceptions explicitly.
- Avoid unnecessary dependencies.
- Keep business logic separate from presentation.

## 6. API Requirements

- Use official Open-Meteo endpoints.
- Validate API responses.
- Handle unsuccessful HTTP responses.
- Handle empty geocoding results.
- Handle missing or null values.
- Display US AQI scale clearly.
- Display the source of air quality data.

Do not present modeled data as direct sensor measurements.

## 7. UI Requirements

Read DESIGN.md before implementing interface changes.

- Use Material Design 3.
- Follow the established color palette.
- Build reusable components.
- Support different Android screen sizes.
- Avoid overflow.
- Implement loading, success, error, and empty states.
- Ensure every interactive component works.

## 8. Local Storage Requirements

Use SharedPreferences.

- Store the last successfully searched city.
- Do not overwrite saved data with failed searches.
- Restore the last searched city when the application starts.
- Handle missing stored values safely.

## 9. Anti-Slop Guidelines

Apply the Anti-Slop principles and instructions when available in the development environment.

- Avoid generic UI patterns without purpose.
- Avoid unnecessary visual decoration.
- Avoid duplicated components.
- Maintain design consistency.
- Prefer readable and maintainable code.
- Review the interface before considering a feature complete.

Never claim that an Anti-Slop tool or automated review has been executed unless it actually has.

## 10. Testing Requirements

After changes, run:

```bash
dart format .
flutter analyze
flutter test
```

Add tests for new business logic and repository behavior.

Report commands that could not be executed.

## 11. Git Workflow

- Implement one feature at a time.
- Use meaningful conventional commit messages.
- Do not combine unrelated features in one commit.
- Do not rewrite existing commit history without permission.
- Explain which files are created or modified.
- Let the student perform Git commits and pushes.

## 12. Development Workflow

1. Inspect existing project structure.
2. Read relevant project instructions.
3. Implement one feature at a time.
4. Review modified files.
5. Run relevant tests.
6. Explain the implementation.
7. Allow the student to commit the changes.
