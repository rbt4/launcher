# Ultimate Kids Game Launcher

## Overview

Ultimate Kids Game Launcher is a portable, full-featured game launcher for DOS, GBA, and CD-ROM games that runs directly from USB drives with no installation required. Perfect for preserving classic games and creating a kid-friendly interface to access your retro game collection.

## Key Features

- **Portable & No Installation**: Runs entirely from USB drive with no installation required
- **Multi-Platform Support**: Plays DOS, GBA, and CD-ROM games through emulators
- **Auto-Save System**: Automatically creates save states for games
- **ZIP Support**: Directly extracts and plays games from ZIP archives
- **Controller Support**: Map modern controllers to classic games
- **Game Statistics**: Tracks playtime and maintains favorites
- **Backup System**: Creates and restores backups of save states
- **User-Friendly Interface**: Simple menu system that kids can navigate

## Requirements

- Windows 7 or newer
- DOSBox-X for DOS and CD-ROM games (place in `emulators` folder)
- GBA emulator like mGBA or VisualBoyAdvance (place in `emulators` folder)
- Optional: 7-Zip for enhanced ZIP support (place 7z.exe in `emulators` folder)
- Optional: JoyToKey for controller support (place in `tools/JoyToKey` folder)

## Setup Instructions

1. **Download** the launcher and extract to a USB drive or folder
2. **Create folders** (the launcher will create these automatically on first run):
   - `games` - Place DOS games here
   - `gba` - Place GBA ROMs here
   - `iso` - Place CD-ROM images (ISO, BIN, CUE) here
   - `emulators` - Place DOSBox-X and GBA emulators here
   - `tools` - Place JoyToKey here (optional)
3. **Launch** by running `launcher.bat`

## Directory Structure

```
Ultimate Kids Game Launcher/
├── launcher.bat       - Main launcher script
├── games/             - DOS games (EXE, COM, BAT, ZIP)
├── gba/               - GBA ROMs (GBA, ZIP)
├── iso/               - CD-ROM images (ISO, BIN, CUE)
├── emulators/         - Emulators (DOSBox-X, mGBA, etc.)
├── saves/             - Auto-generated save files
│   ├── dos/           - DOS game saves
│   └── gba/           - GBA game saves
├── tools/             - Additional utilities
│   └── JoyToKey/      - Controller mapping tool
├── backups/           - Auto-generated backups
├── cache/             - Performance cache files
├── logs/              - Error and activity logs
└── temp/              - Temporary extraction directory
```

## Controller Setup

For controller support:
1. Download JoyToKey from [joytokey.net](https://joytokey.net/en/download)
2. Extract to `tools/JoyToKey` folder
3. Use the Controller Setup menu to configure mappings

## Recommended Emulators

- **DOS & CD-ROM**: [DOSBox-X](https://dosbox-x.com/) - More features than standard DOSBox
- **GBA**: [mGBA](https://mgba.io/) - Best accuracy and performance

## Known Issues

- Very long file paths (>240 characters) may cause issues
- Some special characters in filenames might need to be avoided
- Certain ZIP compression methods may not extract properly

## Credits

- Developed by: [rbt4](https://github.com/rbt4/launcher)
- Inspired by classic game frontends and kid-friendly interfaces

## License

This project is provided as open-source software. Feel free to modify and distribute according to your needs.
