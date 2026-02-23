# SimpleLog Custom Lints

This package enforces architecture and i18n rules for the app.

## Expected Layer Folders

The lints detect layers from folder names in `lib/`:

- `/presentation/` (or `/ui/`)
- `/application/`
- `/domain/`
- `/data/`
- `/core/` (shared; treated as allowed from any layer)

Feature-first structure is supported when these folders exist inside features, for example:

- `lib/features/airports/presentation/...`
- `lib/features/airports/application/...`

## Allowed Dependency Direction

The `layer_boundary_enforcement` rule uses this graph:

- `presentation -> application`
- `application -> domain`
- `data -> domain`

Also allowed:

- same-layer imports (for each layer)
- imports to `/core/`
- external package imports

Disallowed examples:

- `presentation -> data`
- `presentation -> domain`
- `application -> data`
- `domain -> application|data|presentation`
- `data -> application|presentation`

## File Naming Conventions

The `file_naming_conventions` rule enforces:

- `*_screen.dart` only in presentation/ui folders
- `*_repository.dart` only in data folders
- `*_use_case.dart` only in application folders

Public class suffixes are also aligned with file suffixes:

- `*Screen` <-> `*_screen.dart`
- `*Repository` <-> `*_repository.dart`
- `*UseCase` <-> `*_use_case.dart`

## Other Enforced Rules

- `no_hardcoded_widget_strings`:
  No hardcoded user-facing string literals in widget constructor arguments.
- `no_direct_db_access_from_ui`:
  No direct DB/infrastructure imports from UI/presentation files.
- `no_business_logic_in_widgets`:
  No direct `UseCases` instantiation in widgets; flags `if` branches with `await` inside `build()`.

## Notes

- The lints are strict by design and may report many issues on legacy code.
- Fixing violations incrementally is expected.
