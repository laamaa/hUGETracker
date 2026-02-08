# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

hUGETracker is a cross-platform Game Boy music tracker/editor written in Object Pascal using the Lazarus IDE and Free Pascal Compiler (FPC). It allows composing chiptune music that runs on actual Game Boy hardware. The project is public domain.

## Build System

### Prerequisites
- **Lazarus IDE** (v3.0+) with Free Pascal Compiler
- **RGBDS** (v0.8.0) — Game Boy assembler toolchain (`rgbasm`, `rgblink`, `rgbfix`)
- **SDL2** development libraries
- **FFmpeg** (for audio export)

### Building

Register package dependencies first (one-time):
```bash
lazbuild --add-package-link src/rackctls/RackCtlsPkg.lpk
lazbuild --add-package-link src/bgrabitmap/bgrabitmap/bgrabitmappack.lpk
```

Build the main application:
```bash
lazbuild src/hUGETracker.lpi --build-mode="Production Linux"   # or "Production Mac" / "Production Windows"
```

Build the CLI conversion tool:
```bash
lazbuild src/uge2source/uge2source.lpi --build-mode=Release
```

Development build (default build mode, includes debug info):
```bash
lazbuild src/hUGETracker.lpi
```

### Platform Setup

Each platform has a setup script that copies fonts and compiles `halt.gb` (the Game Boy ROM used for song preview):
- Linux: `./setup-linux.sh` — copies PixeliteTTF.ttf, compiles halt.gb to `src/lib/Development/x86_64-linux/`
- macOS: `./setup-mac.sh`
- Windows: `setup-windows.cmd`

The halt.gb compilation requires RGBDS and the hUGEDriver submodule:
```bash
rgbasm -E -I src/hUGEDriver -o hUGEDriver.obj src/hUGEDriver/hUGEDriver.asm
rgbasm -I src/hUGEDriver/include -o halt.obj src/halt.asm
rgblink -o halt.gb -n halt.sym halt.obj hUGEDriver.obj
rgbfix -vp0xFF halt.gb
```

### Git Submodules

The repo uses submodules (not recursive). Initialize with `git submodule update --init`:
- `src/hUGEDriver` — Game Boy sound driver
- `src/Pascal-SDL-2-Headers` — SDL2 Pascal bindings
- `src/rackctls` — UI rack controls (Lazarus package)
- `src/bgrabitmap` — Bitmap graphics library (Lazarus package)

### CI

GitHub Actions (`.github/workflows/build.yml`) builds on Ubuntu 24.04, macOS 14, and Windows 2025. No automated test suite exists; CI validates successful compilation on all three platforms.

## Architecture

### Language and Conventions
- Object Pascal in Delphi compatibility mode (`{$MODE Delphi}` or `{$MODE objfpc}`)
- GUI forms defined in `.lfm` files (Lazarus visual form designer)
- Platform-specific code uses conditional compilation (`{$ifdef MSWINDOWS}`, `{$ifdef DARWIN}`, `{$ifdef LINUX}`)

### Core Data Flow

1. **User edits** patterns/instruments in the tracker UI (`tracker.pas`, `trackergrid.pas`)
2. **Data stored** in memory using song/instrument structures (`song.pas`, `hugedatatypes.pas`)
3. **Preview/playback** runs through an embedded Game Boy emulator: Z80 CPU (`z80cpu.pas`) + sound hardware (`sound.pas`) + machine state (`machine.pas`), driven by a timer-based main loop (`mainloop.pas`)
4. **Save** serializes to `.uge` file format with version migration support (V1–V6)
5. **Export** generates RGBDS assembly or GBDK C source code (`codegen.pas`), or renders to WAV (`rendertowave.pas`)

### Key Source Files (all in `src/`)

| File | Role |
|------|------|
| `hUGETracker.lpr` | Application entry point; platform-specific font loading |
| `tracker.pas` | Main tracker window — UI logic, undo/redo, menus |
| `trackergrid.pas` | Pattern grid editor control |
| `hugedatatypes.pas` | Core data types: `TCell`, `TPattern`, `TInstrument`, `TWave` |
| `song.pas` | Song serialization with versioned formats (TSongV1–V6) |
| `instruments.pas` | Converts instruments to Game Boy hardware registers (NR10–NR44) |
| `codegen.pas` | Compiles songs to ASM/C source and assembles to ROM via RGBDS |
| `constants.pas` | GB register addresses, note mappings, `UGE_FORMAT_VERSION` |
| `z80cpu.pas` | Game Boy Z80 CPU emulator (for song preview) |
| `sound.pas` | Game Boy audio hardware emulation |
| `machine.pas` | GB memory/hardware state management |
| `mainloop.pas` | Emulation timing and audio callback |

### Secondary Tools

- `src/uge2source/` — Standalone CLI tool for batch-converting `.uge` files to C/ASM source. Shares `codegen.pas` and data types with the main app.

### Song Format

The `.uge` binary format is at version 6 (`UGE_FORMAT_VERSION` in `constants.pas`). Songs contain: name, artist, comment, instruments (up to 15), waves (up to 16), patterns (64 cells each across 4 channels), order matrix, ticks-per-row, and custom routines. Older versions are automatically migrated on load.

### Game Boy Audio Model

The tracker maps to the Game Boy's 4 hardware sound channels:
- **CH1/CH2**: Square wave (pulse) channels with sweep/envelope
- **CH3**: Programmable waveform channel
- **CH4**: Noise channel

Each channel has dedicated hardware registers (NR10–NR44) defined in `constants.pas` and emulated in `sound.pas`.

### Keyboard Shortcuts

Shortcuts are implemented using Lazarus `TAction` objects:
- **Defined in `src/tracker.lfm`** — search for `object <Name>Action: TAction` to find an action's definition
- **Handlers in `src/tracker.pas`** — the `OnExecute` property maps to a method (e.g., `PlayStartActionExecute`)
- **Primary shortcut**: `ShortCut` property (numeric Lazarus `TShortCut` keycode)
- **Secondary shortcuts**: `SecondaryShortCuts.Strings` with human-readable strings (e.g., `'F5'`, `'Ctrl+S'`)

To add a new shortcut to an existing action, add a `SecondaryShortCuts.Strings` block in the `.lfm` file. To create a new action, add both a `TAction` in the `.lfm` and a handler method in `tracker.pas`.

Key action groups and their locations in `src/tracker.lfm`:

| Action group | Actions | ~Line |
|---|---|---|
| Playback | `PlayStartAction`, `PlayCursorAction`, `PlayOrderAction`, `StopAction` | ~3068 |
| View navigation | `GotoGeneralAction`, `GotoPatternsAction`, `GotoInstrumentsAction`, `GotoWavesAction`, `GotoCommentsAction` | ~3136 |

View navigation actions switch tabs via `PageControl1.TabIndex` (0=General, 1=Patterns, 2=Instruments, 3=Waves, 4=Comments). The pattern grid control is `TrackerGrid` (a `TTrackerGrid` from `trackergrid.pas`, subclass of `TCustomControl`).
