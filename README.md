# Android Hermes Agent

Magisk module that installs Python 3.14 + native deps + Hermes Agent on Android ARM64. No Termux needed.

## What it does

1. Installs Python 3.14.6 to `/data/hermes/` with all shared libs (ssl, sqlite3, ncurses, etc.)
2. Bundles pre-compiled native packages (psutil, cryptography, Pillow, bcrypt, etc.)
3. Installs `uv` (Rust package manager, statically linked)
4. Runs `pip install hermes-agent` automatically during module installation
5. Creates system-wide wrappers: `python3`, `pip3`, `uv`, `hermes`

## Installation

1. Clone this repo:
```bash
git clone https://github.com/weslleymirandadev/android-hermes-agent --depth 1
cd android-hermes-agent
```
2. Zip this Magisk Module:
```bash
chmod +x build
./build
```
3. Flash zip via Magisk Manager -> Modules -> Install from storage
4. Reboot
5. Open android shell via adb or any terminal and run:
```bash
hermes-build
```

## License

MIT
