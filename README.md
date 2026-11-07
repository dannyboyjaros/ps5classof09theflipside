# Class of '09: The Flip Side — unofficial PS5 homebrew runtime

A native PS5 homebrew app that runs **Class of '09: The Flip Side** from assets
you already own. It is not Ren'Py and not a Sony product. The game's `.rpyc`
scripts are decompiled once into a compact bytecode file, and a small C runtime
interprets that bytecode on the console using the PS5's VideoOut, Pad, and
AudioOut services.

Built on the Class of '09 PS5 runtime work by **CatsAndGats** and the
**The Re-Up** adaptation of the same engine, retargeted for The Flip Side:
the five-way opening rotation, the picnic/laptop-era phone UI, the five-message
ending tracker, the new-message menu alert, and the smoke and Hatman overlays.

- Title ID: **PPSA09011**
- App folder: `kit/dist/PPSA09011/`
- Content ID: `UP0000-PPSA09011_00-CLASS09FSPS5HOME`

## What works

- Native main menu using The Flip Side's own button art, logo, sparkle effect,
  and animated mall background, with the phone inbox access badge
- Boot splash: `WCsplash.webm` then `logosplash.webm`
- **107 labels** and **3,475 voiced lines** with the game's timed voice tracks
  (every line auto-advances on the voice's clock; Cross advances early)
- **9 choice menus** with their conditions
- Every background, sprite, flip, and sampled ATL slide/fade, including the
  120-frame smoke and 10-frame Hatman overlays
- **All videos** decoded directly from the game's original VP8 + Vorbis
  `.webm` files with libvpx and libvorbis: opening narration, WCsplash,
  logosplash, the four ending videos, the three secret videos, and the
  animated main-menu background
- The game's cutscene dialogue: yellow Helvetica Narrow with a black outline,
  no text box (`csbox`)
- The five-message ending tracker, including the 0098 inbox message, the
  unlockable secret videos, and the phone open/close presentation
- The `New Message!` animation on the main menu after a new ending
- Voice, ambient loops, menu music, and UI sound effects
- 36 save slots with thumbnails, save/load, options, and About
- DualSense and keyboard input

## What is not perfect

- Not Ren'Py: arbitrary screens, the phone/PDA quick menu, custom Python, and
  custom transitions are not interpreted. Only the subset the exporter emits
  runs.
- Video is decoded in software with libvpx/libvorbis. The PS5 CPU handles
  1080p30 VP8 comfortably, but this path is newer than the JPEG frame-pack
  fallback and should be checked on each firmware if you see dropped frames.
  The old `C09V` JPEG frame packs are still supported as an optional fallback
  for the host build or a console where WebM playback is not wanted.
- The Flip Side's `search_engine_screen` exists in `screens.rpyc` but no
  in-story `call screen` reaches it, so the laptop is present in the runtime
  but normally unused.
- Hardware behaviour (`/app0`, `/download0`, audio) has been exercised on the
  PS5 through the directory-style app folder; the host build is also verified.

### Video playback

The runtime demuxes WebM itself, decodes VP8 with libvpx, and decodes the
Vorbis audio to a temporary WAV that the existing mixer plays. The original
`.webm` files live under `assets/game/`; there is no frame extraction step.
The optional `C09V` fallback (a 28-byte header, a `uint32` offset per frame,
then JPEG frames) is still supported when `assets/videos/packs/*.pkv` exists.

## Build

Work from the repository root.

### 1. Decompile and export the bytecode

The exporter reads the game's `.rpyc` with the bundled Python 2.7 (Ren'Py 7.5
pickle layout):

```powershell
"..\Class of 09 The Flip Side\lib\py2-windows-x86_64\python.exe" tools\export_script.py "..\Class of 09 The Flip Side\game"
```

Output: `build/script.json` (6,440 ops, 107 labels, 5 endings, 0 unsupported).

### 2. Optional: build JPEG fallback packs (host / compatibility)

This step is **not needed for the PS5 WebM build**. It exists only if you want
the `C09V` fallback path. It needs WSL/Linux with ffmpeg:

```bash
tools/prepare_video_packs.sh "/mnt/c/.../Class of 09 The Flip Side/game" build/videos 720 8
# the animated main-menu background
tools/pack_one.sh "/mnt/c/.../game/gui/menu 2/BG living.webm" build/videos BG_living 720 8 30
```

Stage them with `tools/stage_assets.py ... --packs`. Without `--packs`, the
original `.webm` files are staged instead.

### 3. Stage the assets

```bash
python3 tools/stage_assets.py "/mnt/c/.../Class of 09 The Flip Side/game" build kit/assets
```

Writes `kit/assets/script.json`, `kit/assets/game/` (887 files, about 970 MB
including the original videos), and `kit/GAME_FILES.txt`. No frame packs are
copied unless `--packs` is passed.

### 4. Build the PS5 app (WSL2)

```bash
kit/build_flipside.sh
```

Uses the starter pipeline in `kit/` (signed `eboot.bin`, clean-room
`libc.prx`). Output: `kit/dist/PPSA09011/` and `PPSA09011.zip`.

Or from PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File build_ps5.ps1
```

### 5. Host build (Windows, SDL2)

```powershell
cmake -S . -B build -G Ninja -DSDL2_DIR=...
cmake --build build
build\class09_runtime.exe build\script.json "..\Class of 09 The Flip Side\game"
```

The host build uses the JPEG packs by default. On a Linux host with
libvpx/libvorbis/SDL2 development packages, `-DC09FS_WEBM=ON` builds the same
WebM path the PS5 uses.

Saves and screenshots go to `build/saves`.

## Controls

| Action | DualSense | Keyboard |
| --- | --- | --- |
| Advance / confirm | Cross | Enter / Space |
| Back one line | Circle | Esc |
| Navigate | D-pad | Arrows |
| In-game menu | Options | Tab |
| Ending tracker (main menu) | Triangle | T |
| Change an option | D-pad left/right | Left/Right |

## Diagnostics

- `C09FS_AUTOSTART=1` starts a new game; `C09FS_START_LABEL=<label>`
  jumps to a label.
- `C09FS_TRACKER=1` opens the ending tracker (with `build/saves/seen.txt`).
- `C09FS_CAPTURE=<ms>` writes one screenshot; F12 takes one on demand.
- `C09FS_TEST_BACK=<ms>` triggers one dialogue rollback for testing.
- `C09FS_SAVE_DIR=<dir>` overrides the save folder on the console build.
- F9 dumps interpreter state to the log.

## Repository layout

- `src/` — the portable C runtime and the SDL2 host entry point.
- `src/webm.c` — the WebM/Matroska demuxer and VP8/Vorbis playback.
- `kit/src/` — the same runtime plus the PS5 backend used by the console build.
- `tools/endings_c09fs.json` — the five inbox messages shown by the tracker.
- `tools/export_script.py` — decompiles the game's `.rpyc` to `script.json`.
- `tools/stage_assets.py` — copies only the files the runtime loads.
- `kit/` — PS5 starter pipeline, packaging, and presentation assets.

## Legal

Class of '09: The Flip Side and its assets belong to their developers and
publishers. This project is for personal use with a copy of the game you own.
Do not upload or redistribute the app folder, its ZIP, or any extracted assets.
The runtime contains no jailbreak, exploit, or DRM-circumvention code.

Unofficial fan project. Not affiliated with the developers, publishers, or
Sony. The first-game runtime this is based on is by **CatsAndGats**; the Re-Up
adaptation and this Flip Side port follow the same clean-room approach.
