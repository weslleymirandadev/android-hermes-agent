#!/system/bin/sh

# Android Hermes Agent - Magisk Module Installer
# Installs Python 3.14 + native deps + Hermes Agent

HERMES_DATA=/data/hermes
HERMES_BIN=$HERMES_DATA/bin

echo ""
echo "=============================="
echo " Android Hermes Agent"
echo " github.com/weslleymirandadev/"
echo "         android-hermes-agent"
echo "=============================="
echo ""

# Copy everything from module to /data/hermes
echo "Installing Python 3.14 + native deps..."
rm -rf $HERMES_DATA 2>/dev/null
cp -r $MODPATH/system/hermes $HERMES_DATA

# Set permissions
chmod -R 755 $HERMES_DATA
find $HERMES_DATA/lib -name "*.so*" -exec chmod 644 {} \; 2>/dev/null || true
chmod 755 $HERMES_DATA/bin/python3.14
chmod 755 $HERMES_DATA/bin/pip*
chmod 755 $HERMES_DATA/bin/uv
chmod 755 $HERMES_DATA/bin/uvx

# Fix pip shebangs
for f in pip pip3 pip3.14; do
  if [ -f "$HERMES_BIN/$f" ]; then
    sed -i 's|#!/data/data/com.termux/files/usr/bin/python3.14|#!/data/hermes/bin/python3.14|' "$HERMES_BIN/$f"
  fi
done

# Create python3-wrapper for uv
cat > $HERMES_BIN/python3-wrapper << 'WRAP'
#!/system/bin/sh
export LD_LIBRARY_PATH=/data/hermes/lib
exec /data/hermes/bin/python3.14 "$@"
WRAP
chmod 755 $HERMES_BIN/python3-wrapper

# Create writable paths
touch $HERMES_DATA/.python_history 2>/dev/null
mkdir -p $HERMES_DATA/.cache/uv 2>/dev/null

# Install pre-compiled native wheels (jiter, pydantic-core)
echo "Installing native wheels..."
export LD_LIBRARY_PATH=/data/hermes/lib
for whl in $HERMES_DATA/wheels/*.whl; do
  echo "  $(basename $whl)..."
  $HERMES_BIN/pip3 install "$whl" 2>&1
done

echo ""
echo "=============================="
echo " Python 3.14.6 + native wheels installed!"
echo "=============================="
echo ""
echo "Commands: python3, pip3, uv"
echo ""
echo "To install Hermes Agent, run after reboot (root required):"
echo "  $ hermes-build "
echo ""
