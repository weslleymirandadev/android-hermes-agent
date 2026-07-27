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

# Create writable paths
touch $HERMES_DATA/.python_history 2>/dev/null
mkdir -p $HERMES_DATA/.cache/uv 2>/dev/null

# Load environment
. $HERMES_DATA/env.sh

echo "Python 3.14.6 + native deps installed!"
echo ""
echo "=============================="
echo " Installing Hermes Agent"
echo "=============================="
echo ""

# Install Hermes Agent with full environment
$HERMES_BIN/uv pip install \
  hermes-agent 2>&1

echo ""
echo "=============================="
echo " Android Hermes Agent installed!"
echo "=============================="
echo ""
echo "Commands: python3, pip3, uv, hermes"
echo "Config:   source /data/hermes/env.sh"
echo ""
echo "Test: python3 --version"
echo "       hermes --version"
echo ""
