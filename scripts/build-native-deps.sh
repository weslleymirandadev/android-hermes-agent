#!/system/bin/sh
# build-native-deps.sh - Compile jiter and pydantic-core on Android
# Run this with root on your device AFTER installing the module

HERMES_DATA=/data/hermes
TMP=/data/local/tmp/native_build
mkdir -p $TMP
cd $TMP

echo "=== Installing Rust for Android ARM64 ==="

# Download Termux Rust package
for deb in \
  rust_1.86.0-1_aarch64.deb \
  rust-std-aarch64-linux-android_1.86.0-1_aarch64.deb \
  rust-docs_1.86.0-1_aarch64.deb; do
  
  url="https://packages.termux.dev/apt/termux-main/pool/main/r/rust/$deb"
  echo "Downloading $deb..."
  curl -sL "$url" -o "$TMP/$deb"
  dpkg-deb -x "$TMP/$deb" "$TMP/rust_root"
done

RUST="$TMP/rust_root/data/data/com.termux/files/usr"
export PATH="$RUST/bin:$PATH"
export CARGO_HOME="$TMP/.cargo"
export RUSTUP_HOME="$TMP/.rustup"

# Add Android target
rustup target add aarch64-linux-android

echo ""
echo "=== Building jiter ==="
cd $TMP
git clone --depth 1 https://github.com/pydantic/jiter.git
cd jiter
cargo build --target aarch64-linux-android --release
find target -name "*.so" -exec cp {} $HERMES_DATA/lib/python3.14/site-packages/ \; 2>/dev/null || true

echo ""
echo "=== Building pydantic-core ==="
cd $TMP
git clone --depth 1 https://github.com/pydantic/pydantic-core.git
cd pydantic-core
cargo build --target aarch64-linux-android --release
find target -name "*.so" -exec cp {} $HERMES_DATA/lib/python3.14/site-packages/ \; 2>/dev/null || true

echo ""
echo "=== Installing Hermes Agent ==="
cd $HERMES_DATA
export LD_LIBRARY_PATH=$HERMES_DATA/lib
export UV_PYTHON=$HERMES_DATA/bin/python3-wrapper
$HERMES_DATA/bin/uv pip install hermes-agent

echo ""
echo "=== Done! ==="
echo "Test: hermes --version"
