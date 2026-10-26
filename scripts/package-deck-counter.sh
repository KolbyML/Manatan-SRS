#!/usr/bin/env bash
# Builds a local approval artifact. Never uploads, publishes, or modifies Git.
set -euo pipefail
repo_root="$(cd "$(dirname "$0")/.." && pwd)"
example_dir="$repo_root/examples/deck-counter"
output_dir="$repo_root/target/deck-counter"
build_dir="$repo_root/target/deck-counter-build"
mkdir -p "$output_dir"

cargo build --manifest-path "$example_dir/Cargo.toml" --locked \
  --target wasm32-unknown-unknown --release --target-dir "$build_dir"
wasm-tools component new "$build_dir/wasm32-unknown-unknown/release/deck_counter.wasm" \
  -o "$output_dir/deck-counter.wasm"
wasm-tools validate --features component-model "$output_dir/deck-counter.wasm"

bundle_dir="$(mktemp -d "${TMPDIR:-/tmp}/manatan-deck-counter.XXXXXX")"
trap 'rm -f "$bundle_dir/manifest.json" "$bundle_dir/deck-counter.wasm" "$bundle_dir/LICENSE.txt" "$bundle_dir/deck-counter.mext"; rmdir "$bundle_dir"' EXIT
cp "$example_dir/manifest.json" "$bundle_dir/manifest.json"
cp "$output_dir/deck-counter.wasm" "$bundle_dir/deck-counter.wasm"
cp "$repo_root/LICENSE" "$bundle_dir/LICENSE.txt"
chmod 644 "$bundle_dir/manifest.json" "$bundle_dir/deck-counter.wasm" "$bundle_dir/LICENSE.txt"
TZ=UTC touch -t 198001010000 "$bundle_dir/manifest.json" "$bundle_dir/deck-counter.wasm" "$bundle_dir/LICENSE.txt"
(
  cd "$bundle_dir"
  TZ=UTC zip -q -X deck-counter.mext manifest.json deck-counter.wasm LICENSE.txt
)
cp "$bundle_dir/deck-counter.mext" "$output_dir/deck-counter-0.1.0.mext"
shasum -a 256 "$output_dir/deck-counter-0.1.0.mext"
echo "Local package ready: $output_dir/deck-counter-0.1.0.mext"
echo 'Nothing published.'
