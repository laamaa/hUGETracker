![hUGETracker](https://github.com/SuperDisk/hUGETracker/assets/1688837/def3b70d-dbe4-4b9b-8b74-58b1efcea02c)
---

This is a fork of [hUGETracker](https://github.com/SuperDisk/hUGETracker), the music editing suite for the Gameboy. This fork adds Impulse Tracker-style keyboard shortcuts and other workflow improvements.

For the original project, check out [the homepage](https://nickfa.ro/index.php/hUGETracker), the [upstream repo](https://github.com/SuperDisk/hUGETracker), or the [hUGETracker Discord server](https://discord.gg/abbHjEj5WH).

# Changes in this fork

## Impulse Tracker-style keyboard shortcuts

The keyboard layout has been reworked to match [Impulse Tracker](https://en.wikipedia.org/wiki/Impulse_Tracker) / [Schism Tracker](https://schismtracker.org/) conventions.

### View navigation

Tabs are now accessed with Ctrl+Number instead of Alt+Letter:

| Action | Original | New |
|--------|----------|-----|
| General tab | Alt+G | Ctrl+1 |
| Patterns tab | Alt+P | Ctrl+2 (also F2) |
| Instruments tab | Alt+I | Ctrl+3 (also F3) |
| Waves tab | Alt+W | Ctrl+4 |
| Comments tab | Alt+C | Ctrl+5 |
| Routines tab | Alt+R | Ctrl+6 |

### Playback

F6 and F7 are swapped to match IT conventions:

| Action | Original | New |
|--------|----------|-----|
| Play current pattern (looped) | F7 | F6 |
| Play from cursor | F6 | F7 |

### Pattern editing

New note input behaviors matching IT:

| Key | Action |
|-----|--------|
| `.` (period) | Clear current cell and advance cursor |
| Delete | Clear note and instrument at cursor |

### Block/selection operations (new)

A full set of IT-style Alt+key block operations:

| Shortcut | Action |
|----------|--------|
| Alt+B | Mark block begin |
| Alt+E | Mark block end |
| Alt+D | Quick select (16 rows from cursor) |
| Alt+L | Select entire column |
| Alt+U | Deselect |
| Alt+Z | Cut block |
| Alt+C | Copy block |
| Alt+P | Paste block |
| Alt+M | Mix paste |
| Alt+O | Overwrite paste |
| Alt+R | Repeat paste |
| Alt+K | Interpolate values in selection |
| Alt+Q | Transpose selection up |
| Alt+A | Transpose selection down |
| Alt+S | Set instrument on selection |
| Alt+F | Double block length |
| Alt+G | Halve block length |

### Instrument selection

| Shortcut | Action |
|----------|--------|
| Ctrl+Up | Increment current instrument |
| Ctrl+Down | Decrement current instrument |

### Undo/redo

Undo and redo are now dedicated actions that only activate when the pattern grid is focused:

| Shortcut | Action |
|----------|--------|
| Ctrl+Z | Undo |
| Ctrl+Y / Ctrl+Shift+Z | Redo |

## Other changes

- **Playback always loops**: Song preview always loops regardless of the loop button state
- **Patterns tab auto-focuses grid**: Switching to the Patterns tab now automatically focuses the pattern grid, so you can start editing immediately
- **macOS ARM64 (Apple Silicon) support**: Mac build targets `aarch64-darwin` instead of `x86_64-darwin`
- **CI improvements**: Default CI builds macOS only; all platforms can be triggered manually via `workflow_dispatch`. Added caching for Homebrew, FFmpeg, SDL2, and RGBDS builds

# Build instructions

The only requirements to build hUGETracker are a recent version of [Lazarus](https://www.lazarus-ide.org/) for your platform, [RGBDS](https://rgbds.gbdev.io/), and [SDL2](https://www.libsdl.org/).

On Windows, the setup script will download SDL2 for you.

```bat
:: Download this repo
git clone --recursive https://github.com/SuperDisk/hUGETracker

:: Go into the project directory
cd hUGETracker

:: Let Lazarus know about the dependencies that HT uses
lazbuild --add-package-link src/rackctls/RackCtlsPkg.lpk
lazbuild --add-package-link src/bgrabitmap/bgrabitmap/bgrabitmappack.lpk

:: At this point, you'll successfully be able to build hUGETracker.
:: However, in order to run properly, it needs some extra files (SDL, halt.gb, fonts, etc)
:: so run the following script to automatically set that up.

setup-windows.cmd
:: or
./setup-mac.sh
:: or
./setup-linux.sh

:: Now, you can either build and run hUGETracker from within Lazarus,
:: or run one of the following to just build a binary:

lazbuild hUGETracker.lpi --build-mode="Production Windows"
lazbuild hUGETracker.lpi --build-mode="Production Mac"
lazbuild hUGETracker.lpi --build-mode="Production Linux"

```

# License

hUGETracker and hUGEDriver are dedicated to the public domain.
