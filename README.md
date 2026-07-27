# Android Hermes Agent

Magisk module that installs Python 3.14 + native deps + Hermes Agent on Android ARM64.

## What it does

1. Installs Python 3.14.6 to `/data/hermes/` with all shared libs (ssl, sqlite3, ncurses, etc.)
2. Bundles pre-compiled native packages (psutil, cryptography, Pillow, bcrypt, etc.)
3. Installs `uv` (Rust package manager, statically linked)
4. Runs `pip install hermes-agent` automatically during module installation
5. Creates system-wide wrappers: `python3`, `pip3`, `uv`, `hermes`

## Installation

1. Download `android-hermes-agent.zip` from releases
2. Magisk Manager -> Modules -> Install from storage
3. Reboot

## License

MIT
