#!/system/bin/sh

# Android Hermes Agent - post-fs-data (runs on every boot)
# Handles ALL environment variables needed for Python/pip/uv/Hermes

HERMES_DATA=/data/hermes
MODULE_SRC=/data/adb/modules/android-hermes-agent/system/hermes

# --- FILE CHECK: ensure files exist if /data was wiped ---
if [ ! -f "$HERMES_DATA/bin/python3.14" ] && [ -d "$MODULE_SRC" ]; then
  cp -r "$MODULE_SRC" "$HERMES_DATA"
  chmod -R 755 "$HERMES_DATA"
  find "$HERMES_DATA/lib" -name "*.so*" -exec chmod 644 {} \; 2>/dev/null || true
fi

# --- WRITABLE PATHS: create if missing ---
touch $HERMES_DATA/.python_history 2>/dev/null
mkdir -p $HERMES_DATA/.cache/uv 2>/dev/null

# --- ENVIRONMENT VARIABLES: exported for all child processes ---
# Python: find shared libraries (.so files)
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HERMES_DATA/lib
# Python REPL: history file (avoids "Read-only filesystem" warning)
export PYTHON_HISTORY=$HERMES_DATA/.python_history
# uv: writable cache directory
export XDG_CACHE_HOME=$HERMES_DATA/.cache
export UV_CACHE_DIR=$HERMES_DATA/.cache/uv
# uv: which Python interpreter to use (wrappers set LD_LIBRARY_PATH)
export UV_PYTHON=$HERMES_DATA/bin/python3-wrapper
# PATH: ensure hermes/python/pip/uv are accessible
export PATH=$PATH:$HERMES_DATA/bin
