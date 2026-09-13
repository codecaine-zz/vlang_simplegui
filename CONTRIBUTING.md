# Contributing to SimpleGUI

Thank you for your interest in contributing to **SimpleGUI**! We welcome contributions from developers of all skill levels.

## Code of Conduct

Please treat all community members with respect, patience, and kindness.

## Development Workflow

### 1. Prerequisites
- Install the [V Programming Language](https://vlang.io) (`v` version 0.4.x or later).
- macOS with Xcode Command Line Tools installed (`xcode-select --install`).

### 2. Repository Structure

The codebase is organized into focused directories:

- `./`: Core native GUI framework module (`controls.v`, `window.v`, `window.m`, `window.h`, `dialogs.v`, etc.).
- `scripts/`: Packaging and build scripts (`build.vsh`, `build_demos.vsh`, `capture_demos.vsh`).
- `tools/`: Standalone applications and tools (`ui_designer.v`, `vlang_simple_gui_previewer.v`).
- `tests/`: Modular test suites testing each component domain.
- `docs/`: Framework documentation and textbooks (`API.md`).
- `demos/`: Showcase applications and UI examples (`demos/main.v`).

### 3. Building and Testing

Run the test suite across all modular test files:
```bash
v test .
```

To run tests in the `tests/` directory specifically:
```bash
VJOBS=1 v test tests/
```

To verify that every GUI button has exactly one click handler and that CLI flags
do not shadow built-in help/version options:
```bash
v test tests/application_audit_test.v
```

To run the SimpleCLI parser and utility tests:
```bash
v test simplecli/
```

To build and run the main entry point:
```bash
v run demos/main.v
```

### 4. Code Formatting

All V code in the repository must be formatted using `v fmt`:
```bash
v fmt -w .
```

Verify formatting before submitting a pull request:
```bash
v fmt -verify .
```

### 5. API Design Principles

- **No Breaking Changes**: Maintain full backwards compatibility for public API signatures.
- **Pythonic / Delphi Ergonomics**: Keep function signatures simple, intuitive, and developer-friendly.
- **Debug Gating**: Gate debug `println` calls behind `$if debug { ... }`.
- **String Interpolation**: Prefer V string interpolation `${var}` over string concatenation.

## Submitting Pull Requests

1. Fork the repository and create a feature branch (`git checkout -b feature/my-feature`).
2. Ensure `VJOBS=1 v test .`, `v test tests/application_audit_test.v`, and `v fmt -verify .` succeed.
3. Commit your changes with clear, descriptive commit messages.
4. Push to your fork and submit a Pull Request to `main`.
