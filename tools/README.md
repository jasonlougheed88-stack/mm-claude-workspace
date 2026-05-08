# Tools

All scripts run from terminal. Make sure they're executable (`chmod +x tools/*.sh`).

| Script | Purpose | Usage |
|--------|---------|-------|
| `build.sh` | Build app for physical device | `./tools/build.sh` or `./tools/build.sh clean` |
| `check_errors.sh` | Build and show only compile errors | `./tools/check_errors.sh` |
| `stream_logs.sh` | Stream app logs (requires Xcode debug session) | `./tools/stream_logs.sh` or `./tools/stream_logs.sh DeckScreen` |
| `check_thompson_state.sh` | Read alpha/beta from Core Data SQLite | `./tools/check_thompson_state.sh` |
| `check_api.sh` | Test JSearch API key is valid | `./tools/check_api.sh` |
| `find_todos.sh` | Find all TODO/FIXME in codebase | `./tools/find_todos.sh` |
| `generate_icon.sh` | Regenerate M&M app icon | `./tools/generate_icon.sh` |

## Log Categories
Filter `stream_logs.sh` by these category names:
- `DeckScreen`
- `ContentView`
- `JobDiscovery`
- `PersistenceController`
