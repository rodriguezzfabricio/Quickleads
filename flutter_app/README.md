# CrewCommand Flutter Scaffold

This folder is the production app scaffold for CrewCommand.

## Architecture

- Feature-first module layout under `lib/features/*`
- Global app shell in `lib/app/*`
- Riverpod for state management
- `go_router` for navigation
- Drift (SQLite) for local-first data and offline queue
- Supabase for auth/data/storage/functions
- FCM + local notifications for messaging prompts and reminders

## Theme Direction

Tokens align to the React prototype:
- Background: `#161618`
- Foreground: `#F5F5F7`
- Primary: `#007AFF`
- Glass surfaces with low-opacity white overlays

## Current Status

Flutter SDK is not available in this environment, so this is a source scaffold and structure baseline. It is ready to be completed in a Flutter-enabled environment.
