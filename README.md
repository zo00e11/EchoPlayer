# EchoPlayer

A minimal macOS audio player with a warm retro aesthetic. Built with SwiftUI.

<p align="center">
  <img src="screenshot.png" width="400" alt="EchoPlayer">
</p>

[中文](README.zh.md)

## Features

- **Drag & Drop** — Drop audio files directly into the player to start playing
- **Folder Playlist** — Set a playlist folder, EchoPlayer auto-scans and watches for new tracks
- **24-Band Visualizer** — Smooth animated frequency bars that react to the music
- **Playback Controls** — Play/pause, next, previous, seekable progress bar
- **Speed Control** — 0.5x to 2.0x playback speed
- **Volume & Balance** — Independent volume and stereo balance sliders
- **Repeat Modes** — Off / Repeat One / Repeat All
- **Keyboard Shortcuts** — Space (play/pause), Arrow keys (seek ±10s, volume ±10%)
- **Glassmorphism UI** — Warm cream background with translucent glass card, orange accents
- **Power Toggle** — Retro on/off switch with Morse code startup sound

## Supported Formats

MP3 · WAV · FLAC · M4A · AAC · OGG · WMA

## Requirements

- macOS 14.0+ (Sonoma)
- Xcode 15+ to build from source

## Build

```bash
git clone https://github.com/zo00e11/EchoPlayer.git
cd EchoPlayer
open EchoPlayer.xcodeproj
```

Build and run with `Cmd + R`.

## Project Structure

```
EchoPlayer/
├── Audio/
│   ├── AudioEngine.swift          # Core playback engine
│   └── AudioEngine+FolderWatcher.swift  # Playlist folder scanning & persistence
├── Views/
│   ├── TitleBar.swift             # Song info header
│   ├── EqualizerView.swift        # 24-band animated visualizer
│   ├── ProgressBar.swift          # Seekable track progress
│   ├── SliderRow.swift            # Reusable labeled slider
│   └── PlaylistSheet.swift        # Playlist overlay
├── Theme/
│   ├── Colors.swift               # Color palette (warm orange / cream)
│   └── GlassEffect.swift          # Glassmorphism modifiers
├── ContentView.swift              # Main layout
└── EchoPlayerApp.swift            # App entry point
```

## License

MIT
