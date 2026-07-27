#!/data/data/com.termux/files/usr/bin/bash
# hermes-build for Termux - compile jiter + pydantic-core for Android ARM64
# Run this INSIDE Termux after: pkg install rust git python-pip

set -e

HERMES_DATA=/data/hermes
SITE_PACKAGES=$HERMES_DATA/lib/python3.14/site-packages
TMP=/data/local/tmp/hermes_build
mkdir -p $TMP
cd $TMP

echo ""
echo "=== Hermes Native Deps Builder (Termux) ==="
echo ""

# Check requirements
for cmd in rustc cargo git python3 pip3; do
  if ! command -v $cmd &>/dev/null; then
    echo "ERROR: $cmd not found. Run: pkg install rust git python"
    exit 1
  fi
done

echo "Rust version: $(rustc --version)"
echo "Target: aarch64-linux-android (native)"

# Install maturin for building Python Rust packages
pip3 install maturin --quiet

echo ""
echo "[1/3] Building jiter..."
rm -rf jiter
git clone --depth 1 https://github.com/pydantic/jiter.git
cd jiter
maturin build --release --out $TMP/output 2>&1 | tail -5

echo ""
echo "[2/3] Building pydantic-core..."
cd $TMP
rm -rf pydantic-core
git clone --depth 1 https://github.com/pydantic/pydantic-core.git
cd pydantic-core
maturin build --release --out $TMP/output 2>&1 | tail -5

echo ""
echo "[3/3] Installing wheels..."
mkdir -p $SITE_PACKAGES
for whl in $TMP/output/*.whl; do
  echo "Installing $(basename $whl)..."
  # Extract wheel directly into site-packages
  unzip -qo "$whl" -d $TMP/wheel_extract
  cp -r $TMP/wheel_extract/*.dist-info $SITE_PACKAGES/ 2>/dev/null || true
  # Find and copy .so files
  find $TMP/wheel_extract -name "*.so" -exec cp {} $SITE_PACKAGES/ \; 2>/dev/null || true
  find $TMP/wheel_extract -type d -not -path "*/.*" | while read dir; do
    base=$(basename "$dir")
    if [ "$base" != "." ] && [ -d "$dir" ] && ! echo "$base" | grep -q "dist-info\|__pycache__"; then
      [ -d "$SITE_PACKAGES/$base" ] || cp -r "$dir" "$SITE_PACKAGES/" 2>/dev/null || true
    fi
  done
  rm -rf $TMP/wheel_extract
done

echo ""
echo "=== Installing Hermes Agent ==="
export LD_LIBRARY_PATH=$HERMES_DATA/lib
export PIP_REQUIRE_VIRTUALENV=false
pip3 install hermes-agent

echo ""
echo "=== Done! ==="
echo "Test: hermes --version"
echo "Then exit Termux and use 'hermes' from anywhere."
rm -rf $TMP
