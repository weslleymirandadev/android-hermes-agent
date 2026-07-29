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
echo "Installing Python 3.14..."
rm -rf $HERMES_DATA 2>/dev/null
cp -r $MODPATH/system/hermes $HERMES_DATA

# Set permissions
chmod -R 755 $HERMES_DATA
find $HERMES_DATA/lib -name "*.so*" -exec chmod 644 {} \; 2>/dev/null || true
chmod 755 $HERMES_DATA/bin/python3.14
chmod 755 $HERMES_DATA/bin/pip*

# Fix pip shebangs
for f in pip pip3 pip3.14; do
  if [ -f "$HERMES_BIN/$f" ]; then
    sed -i 's|#!/data/data/com.termux/files/usr/bin/python3.14|#!/data/hermes/bin/python3.14|' "$HERMES_BIN/$f"
  fi
done
# Create writable paths
touch $HERMES_DATA/.python_history 2>/dev/null

echo "Python 3.14 Installed!"

export LD_LIBRARY_PATH=/data/hermes/lib
export PATH=$PATH:/data/hermes/bin

VENV=/data/hermes/venv

echo ""
echo "██╗  ██╗███████╗██████╗ ███╗   ███╗███████╗███████╗"
echo "██║  ██║██╔════╝██╔══██╗████╗ ████║██╔════╝██╔════╝"
echo "███████║█████╗  ██████╔╝██╔████╔██║█████╗  ███████╗"
echo "██╔══██║██╔══╝  ██╔══██╗██║╚██╔╝██║██╔══╝  ╚════██║"
echo "██║  ██║███████╗██║  ██║██║ ╚═╝ ██║███████╗███████║"
echo "╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚══════╝"
echo ""

rm -rf $VENV
cd /data/hermes
python3 -m venv $VENV
source $VENV/bin/activate

python3 -m pip install hermes-agent
