![hUGETracker](https://github.com/SuperDisk/hUGETracker/assets/1688837/def3b70d-dbe4-4b9b-8b74-58b1efcea02c)
---

This is a fork of [hUGETracker](https://github.com/SuperDisk/hUGETracker), the music editing suite for the Gameboy. This fork adds Impulse Tracker-style keyboard shortcuts and other workflow improvements.

For the original project, check out [the homepage](https://nickfa.ro/index.php/hUGETracker), the [upstream repo](https://github.com/SuperDisk/hUGETracker), or the [hUGETracker Discord server](https://discord.gg/abbHjEj5WH).

# Changes in this fork

## Impulse Tracker-style keyboard shortcuts

The keyboard layout has been reworked to match [Impulse Tracker](https://en.wikipedia.org/wiki/Impulse_Tracker) / [Schism Tracker](https://schismtracker.org/) conventions.

### View navigation

Tabs are accessed via function keys:

| Action | Key |
|--------|-----|
| General tab | F1 |
| Patterns tab | F2 |
| Instruments tab | F3 |
| Waves tab | F4 |

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

A full set of IT-style Cmd+key block operations:

| Shortcut | Action |
|----------|--------|
| Cmd+B | Mark block begin |
| Cmd+E | Mark block end |
| Cmd+D | Quick select (16 rows from cursor) |
| Cmd+L | Select entire column |
| Cmd+U | Deselect |
| Cmd+Z | Cut block |
| Cmd+C | Copy block |
| Cmd+P | Paste block |
| Cmd+M | Mix paste |
| Cmd+O | Overwrite paste |
| Cmd+R | Repeat paste |
| Cmd+K | Interpolate values in selection |
| Cmd+Q | Transpose selection up |
| Cmd+A | Transpose selection down |
| Cmd+S | Set instrument on selection |
| Cmd+F | Double block length |
| Cmd+G | Halve block length |

### Base octave

| Shortcut | Action |
|----------|--------|
| Ctrl+1 – Ctrl+6 | Set base octave (0–5) |
| Numpad * | Increase base octave |
| Numpad / | Decrease base octave |

### Instrument selection

| Shortcut | Action |
|----------|--------|
| Ctrl+Up | Increment current instrument |
| Ctrl+Down | Decrement current instrument |
| Shift+= | Increment current instrument |
| Shift+- | Decrement current instrument |

### Undo/redo

Undo and redo are now dedicated actions that only activate when the pattern grid is focused:

| Shortcut | Action |
|----------|--------|
| Ctrl+Z | Undo |
| Ctrl+Y / Ctrl+Shift+Z | Redo |

### Order matrix

| Shortcut | Action |
|----------|--------|
| Cmd+Ctrl+D | Duplicate order row |
| Cmd+Ctrl+R | Replicate order row |

### Row insert/delete

| Shortcut | Action |
|----------|--------|
| Insert | Insert row in current channel |
| Ctrl+Insert / Shift+Insert | Insert row in all channels |
| Backspace | Delete row in current channel |
| Ctrl+Backspace | Delete row in all channels |

### Value editing

| Shortcut | Action |
|----------|--------|
| Ctrl+Scroll Up/Down | Increment/decrement value by 1 |
| Ctrl+Shift+Scroll Up/Down | Increment/decrement value by octave/large step |
| Ctrl++/- | Increment/decrement value by 1 |
| Ctrl+Shift++/- | Increment/decrement value by 10 |

## Other changes

- **WAV export without FFmpeg**: WAV rendering no longer requires FFmpeg
- **Song cleanup**: Menu option to remove unused patterns and merge duplicates
- **Individual FX nibble editing**: Edit each nibble of effect parameters separately
- **Bottom bar FX help**: Shows effect command documentation in the bottom status bar
- **Auto-switch instrument**: Navigating to a cell with an instrument column value automatically selects that instrument
- **Advance on FX edits**: Cursor advances by the configured row step when editing effect columns
- **Playback always loops**: Song preview always loops regardless of the loop button state
- **Patterns tab auto-focuses grid**: Switching to the Patterns tab now automatically focuses the pattern grid, so you can start editing immediately
- **Default row step is 1**: Row step defaults to 1 instead of 0
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
