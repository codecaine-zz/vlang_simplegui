# V macOS Native Window

A small macOS-native GUI starter project written in V, designed to feel approachable for programmers coming from Python, Delphi, or VBA.

## What this project does

This project combines:

- a lightweight V-side wrapper for creating GUI controls
- a native Cocoa bridge for real macOS windows and controls
- a beginner-friendly API for adding named controls, setting/getting values, and attaching event handlers

It is intended to make GUI programming feel more direct and less manual than the raw Cocoa/Objective-C approach.

## Features

- Create named controls such as labels, text inputs, text areas, buttons, checkboxes, and number fields
- Set and read values by control name
- Support multiple controls of the same kind using distinct names
- Attach simple event handlers for clicks and value changes
- Open a real native macOS window with a built-in demo
- Support native keyboard shortcuts: **CMD + F** to toggle full screen, **CMD + Q** to quit the application

## Example

```v
fn main() {
    mut gui := new_simple_window('My App', 700, 500)

    gui.add_input('name', 'Ada')
    gui.add_button('run', 'Run')

    gui.on_change('name', on_name_changed)
    gui.on_click('run', on_run_clicked)

    gui.run()
}

fn on_name_changed(value string) {
    println('name changed: ${value}')
}

fn on_run_clicked() {
    println('run clicked')
}
```

## Screenshots

### 1. Vertical Stack Style (Default Layout)
![Vertical Stack Style](screenshots/stack_style.png)

### 2. Grid & Row Layout (Columns aligned side-by-side)
![Grid Layout](screenshots/grid_style.png)

### 3. Interactive Keypad Calculator
![Calculator](screenshots/calculator.png)

### 4. Advanced Preferences Settings Editor
![Settings Editor](screenshots/settings_editor.png)

### 5. Database Query Viewer & Filter
![Data Viewer](screenshots/data_viewer.png)

### 6. Scheduled Timer Loader Task
![Timer Demo](screenshots/timer_demo.png)

### 7. Interactive List & Image Selector Dashboard
![List & Image Demo](screenshots/list_image.png)

### 8. Interactive Events & State Controller
![Events Demo](screenshots/events_demo.png)

## Requirements

- macOS
- V installed and available on your PATH
- Xcode Command Line Tools

## Run the demos

This project supports two different layout styles:
1. **Vertical Stack Style**: The default linear, top-to-bottom layout.
2. **Grid / Row-based Style**: Allows grouping multiple controls side-by-side inside rows.

### Run the main demo (which combines both styles):
```bash
v run .
```

### Run the Stack Style demo:
```bash
v run demos/stack_style.v
```

### Run the Grid Style demo:
```bash
v run demos/grid_style.v
```

### Run the Calculator demo:
```bash
v run demos/calculator.v
```

### Run the Settings Editor demo:
```bash
v run demos/settings_editor.v
```

### Run the Data Viewer/Filter demo:
```bash
v run demos/data_viewer.v
```

### Run the Timer & Progress loader demo:
```bash
v run demos/timer_demo.v
```

### Run the List & Image Preview Selector demo:
```bash
v run demos/list_image_demo.v
```

### Run the Interactive Events & States demo:
```bash
v run demos/events_demo.v
```

### Run the Native Menu Bar & Text Shortcuts demo:
```bash
v run demos/menu_demo.v
```


## Run tests

```bash
v test .
```

## Project files

- [main.v](main.v) — example app and demo entry point
- [simplegui/simplegui.v](simplegui/simplegui.v) — beginner-friendly wrapper API module
- [simplegui/window.m](simplegui/window.m) — native macOS bridge implementation
- [simplegui/window.h](simplegui/window.h) — bridge declarations used by V
- [simplegui_test.v](simplegui_test.v) — regression tests for the wrapper API
- [demos/stack_style.v](demos/stack_style.v) — demo of clean, vertical form stacking
- [demos/grid_style.v](demos/grid_style.v) — demo of side-by-side row-based grids
- [demos/calculator.v](demos/calculator.v) — interactive math calculator showing nested grid rows
- [demos/settings_editor.v](demos/settings_editor.v) — advanced dashboard containing date picker, color wells, modes
- [demos/data_viewer.v](demos/data_viewer.v) — mock database user records lookup table with filters
- [demos/timer_demo.v](demos/timer_demo.v) — background timer tasks updating progress indicators periodically
- [demos/list_image_demo.v](demos/list_image_demo.v) — interactive list selector previewing mockup screenshots in real time
- [demos/events_demo.v](demos/events_demo.v) — advanced event listener triggers for hover, focus, lose focus (blur), and window resizes
- [demos/menu_demo.v](demos/menu_demo.v) — demo of standard macOS application menus and text editing shortcuts

## Notes

The goal of this project is to provide a simple, high-abstraction GUI layer that feels familiar to people who are used to event-driven environments like Delphi, VBA, or Python-based UI toolkits.
