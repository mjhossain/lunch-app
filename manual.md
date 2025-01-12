# Lunch Timer App Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [File Structure](#file-structure)
3. [Core Components](#core-components)
4. [State Management](#state-management)
5. [Theming and Customization](#theming-and-customization)
6. [Local Storage](#local-storage)
7. [Development Setup](#development-setup)
8. [Future Enhancements](#future-enhancements)

## Project Overview
The Lunch Timer App is a Flutter-based productivity tool designed to help users manage their lunch breaks effectively. Key features include:
- Countdown timer with pause/resume functionality
- Task management system
- Persistent storage of tasks
- Notifications for break reminders
- Customizable lunch duration

## File Structure
ib/
├── components/
│ ├── timer_display.dart
│ ├── timer_controls.dart
│ ├── task_input.dart
│ ├── task_list.dart
├── models/
│ ├── lunch_note.dart
├── pages/
│ ├── timer_page.dart
│ ├── tasks_page.dart
├── main.dart


### Core Files
1. **main.dart**: Entry point of the application
2. **models/lunch_note.dart**: Data model for tasks
3. **pages/timer_page.dart**: Main timer interface
4. **pages/tasks_page.dart**: Task management interface
5. **components/**: Reusable UI components

## Core Components

### TimerDisplay
- Displays the countdown timer and clock-out time
- Handles time formatting
- Shows reminder times

### TimerControls
- Contains timer control buttons (Start, Stop, Pause)
- Duration adjustment controls
- Visual feedback for timer states

### TaskInput
- Text input field for adding new tasks
- Submit button for task creation
- Input validation

### TaskList
- Displays list of tasks
- Handles task completion toggling
- Supports task reordering
- Visual feedback for completed tasks

## State Management
The app uses basic Flutter state management with `setState()`. Key state variables include:

### Timer State
- `_lunchDuration`: Default lunch duration in minutes (default: 60)
- `_remainingTime`: Current countdown time in seconds
- `_isRunning`: Timer running state (true/false)
- `_clockOutTime`: Calculated clock-out time
- `_pauseTime`: Time when timer was paused
- `_pausedDuration`: Duration of pause

### Task State
- `_notes`: List of LunchNote objects
- `_notesController`: Text editing controller for task input
- `_currentIndex`: Current page index (0 = Timer, 1 = Tasks)

## Theming and Customization

### Color Scheme
The app uses Material 3 theming. Colors can be customized in `main.dart`:



### Customizable Colors
1. **Primary Color**: Change `seedColor` in `ColorScheme.fromSeed()`
2. **Surface Colors**: Modify in `TimerPage` container decorations
3. **Text Colors**: Adjust in `TimerDisplay` and `TaskList` components
4. **Icon Colors**: Set in `TimerControls` and navigation bar

### Typography
Customize text styles in individual components:
- `TimerDisplay`: `displayLarge`, `titleMedium`, `headlineSmall`
- `TaskList`: `titleLarge`, `bodyMedium`

## Local Storage
The app uses `SharedPreferences` for persistent storage:
- Tasks are stored as JSON strings
- Storage methods:
  - `_loadNotes()`: Loads saved tasks on app start
  - `_saveNotes()`: Saves current task list
- Data structure:
{
"text": "Task description",
"isCompleted": false
}



## Development Setup

### Requirements
- Flutter SDK (version 3.0 or higher)
- Dart (version 2.17 or higher)
- Android Studio/VSCode

### Running the App
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Use `flutter run` to start the app

### Dependencies
- flutter_local_notifications: For reminder notifications
- shared_preferences: For local storage

## Future Enhancements
1. Dark mode support
2. Cloud sync for tasks
3. Customizable notification sounds
4. Break history tracking
5. Multi-language support
6. Advanced task categories
7. Pomodoro timer integration
8. Widget support for home screen
9. Analytics integration
10. User authentication

## Troubleshooting
- **Timer not working**: Check `_startTimer()` and `_timer` implementation
- **Tasks not saving**: Verify `SharedPreferences` initialization
- **UI issues**: Check widget constraints and theme settings
- **Notifications not showing**: Ensure proper notification permissions

## Contribution Guidelines
1. Fork the repository
2. Create a new branch for your feature
3. Follow existing code style
4. Write unit tests for new features
5. Submit a pull request with detailed description

## License
[MIT License](LICENSE)