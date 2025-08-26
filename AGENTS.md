# Repository Guidelines

## Architecture & BLoC Workflow
- Layers: Presentation (BLoC/Cubit) → Interactor (use cases) → Repository (data: Drift/remote). Presentation delegates all business logic to Interactors.
- DI: `get_it` registers Repo → Interactor → Bloc. Example: `registerSingleton<UserRepository>(...)`, `registerSingleton<UserInteractor>(UserInteractorImpl(repo: getIt()))`, `registerFactory(() => UserBloc(getIt()))`.
- State model: keep a single state with per-operation maps: `Map<Op, Status> status`, `Map<Op, Failure?> errors` where `Op`∈{load, refresh, create, update, delete, paginate, search} and `Status`∈{idle, loading, success, failure}. Avoid scattered `isLoading` flags.
- Events: past-tense, specific (e.g., `UsersLoadRequested`, `UserUpdated`, `UserSearchChanged`). No UI-specific events (snackbars, dialogs).
- Concurrency: use `bloc_concurrency` transformers: loading/pagination → `droppable()`, search → `debounce(const Duration(milliseconds: 400))`. Long ops must not block others.
- Streams: blocs subscribe to interactor streams in constructor and cancel in `close()`. Cross-bloc communication only via interactors/streams.
- Navigation: `NavigationBloc` drives `AppRouteState`/`PageConfig`; `AppRouterDelegate` listens. Expense modals are toggled via events and route-state flags.
- UI rules: minimize rebuilds with `BlocBuilder(buildWhen: ...)`/`BlocSelector`; side-effects only in `BlocListener`.

## Project Structure & Module Organization
- lib/core: shared utilities (navigation, theme, service locator, Drift database).
- lib/features/*: feature-first folders with domain, data, and presentation (BLoC) layers.
- lib/generated/l10n and lib/l10n: generated localizations and ARB sources.
- ios/: iOS runner project and tests; docs/: design notes.

Example: `lib/features/expense/presentation/bloc/expense_bloc.dart` and `lib/core/data/database/app_database.dart`.

## Build, Test, and Development Commands
- flutter pub get: install dependencies.
- dart run build_runner build --delete-conflicting-outputs: generate Drift/Freezed/JSON code.
- flutter gen-l10n: regenerate localization files from `lib/l10n/*.arb`.
- flutter analyze && dart format .: static analysis and auto-format.
- flutter test: run unit/widget tests.
- flutter run -d ios | flutter build ios --release: run/build for iOS.

## Coding Style & Naming Conventions
- Indentation: 2 spaces; prefer const constructors and immutable widgets.
- Files: snake_case (`add_expense_modal.dart`); classes: UpperCamelCase; members: lowerCamelCase; private: leading `_`.
- Keep features self-contained; BLoC triplet naming: `SomethingBloc`, `SomethingEvent`, `SomethingState`.
- Linting via `analysis_options.yaml` (`flutter_lints`). Fix analyzer warnings before commit.

## Testing Guidelines
- Use `flutter_test`, `bloc_test`, `mocktail`.
- Place tests in `test/`, name `*_test.dart`.
- Write BLoC tests with `blocTest` (events → expected states), and widget tests for screens.

## Commit & Pull Request Guidelines
- History shows short, imperative messages (e.g., "fixed bugs", "added new navigation"). Use imperative mood and keep summaries under 72 chars. Optional type prefixes: `feat:`, `fix:`, `refactor:`.
- PRs: include a clear description, linked issues, screenshots for UI changes, reproduction/testing steps, and any schema or localization updates.
- Run codegen, analyzer, formatter, and tests before opening a PR.

## Localization & Codegen Notes
- After changing ARB or data models, re-run code generation (`build_runner`, `gen-l10n`). Commit generated files where this repo already commits them.
## Contribution Guardrails
- Don’t modify `pubspec.yaml`, CI, platform folders (`android/`, `ios/`, `web/`), or workspace tools without an explicit task.
- Work within a single feature scope under `lib/features/<feature>/...` and avoid adding dependencies unless requested.
