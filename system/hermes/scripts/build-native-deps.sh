#!/system/bin/sh
# hermes-build - Compile native Rust deps (jiter, pydantic-core) on device
# Installs Rust via Termux, compiles, then installs Hermes Agent

HERMES_DATA=/data/hermes
TMP=/data/local/tmp/native_build
mkdir -p $TMP
cd $TMP

echo ""
echo "=============================="
echo " Hermes Native Deps Builder"
echo "=============================="
echo ""

# Load Hermes environment
. $HERMES_DATA/env.sh

echo "[1/5] Downloading Rust for Android ARM64..."
for deb in \
  rust_1.86.0-1_aarch64.deb \
  rust-std-aarch64-linux-android_1.86.0-1_aarch64.deb; do
  
  url="https://packages.termux.dev/apt/termux-main/pool/main/r/rust/$deb"
  echo "  $deb..."
  curl -sL "$url" -o "$TMP/$deb"
  dpkg-deb -x "$TMP/$deb" "$TMP/rust_root"
done

RUST="$TMP/rust_root/data/data/com.termux/files/usr"
export PATH="$RUST/bin:$PATH"
export CARGO_HOME="$TMP/.cargo"

rustup target add aarch64-linux-android

echo ""
echo "[2/5] Building jiter..."
cd $TMP
rm -rf jiter
git clone --depth 1 https://github.com/pydantic/jiter.git
cd jiter
cargo build --target aarch64-linux-android --release
echo "Copying jiter .so..."
find target -name "*.so" -exec cp {} $HERMES_DATA/lib/python3.14/site-packages/ \; 2>/dev/null || true

echo ""
echo "[3/5] Building pydantic-core..."
cd $TMP
rm -rf pydantic-core
git clone --depth 1 https://github.com/pydantic/pydantic-core.git
cd pydantic-core
cargo build --target aarch64-linux-android --release
echo "Copying pydantic-core .so..."
find target -name "*.so" -exec cp {} $HERMES_DATA/lib/python3.14/site-packages/ \; 2>/dev/null || true

echo ""
echo "[4/5] Installing Hermes Agent..."
cd $HERMES_DATA
$HERMES_DATA/bin/uv pip install hermes-agent 2>&1

echo ""
echo "[5/5] Cleaning up..."
rm -rf $TMP

echo ""
echo "=============================="
echo " Hermes Agent installed!"
echo "=============================="
echo "Test: hermes --version"
