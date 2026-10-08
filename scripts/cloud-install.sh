#!/usr/bin/env bash
set -euo pipefail

# Reuse the existing checkout; cloud tasks are already isolated.
golden_script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
golden_repo_root="$(cd -- "$golden_script_dir/.." && pwd)"
source "$golden_script_dir/cloud-activate.sh"
mkdir -p "$golden_setup_root/downloads" "$npm_config_cache"

if [ "$(uname -s)" != Linux ] || [ "$(uname -m)" != x86_64 ]; then
  printf '%s\n' 'This cloud installer supports Linux x86_64.' >&2
  exit 1
fi
command -v curl >/dev/null
command -v sha256sum >/dev/null
command -v cc >/dev/null
command -v npm >/dev/null
node --input-type=module -e 'const [major, minor] = process.versions.node.split(".").map(Number); if (!((major === 20 && minor >= 19) || major > 22 || (major === 22 && minor >= 12))) throw new Error("Vite requires Node 20.19+ or 22.12+"); console.log("Node", process.versions.node);'

golden_rustup_url=https://static.rust-lang.org/rustup/archive/1.29.1/x86_64-unknown-linux-gnu
curl --fail --show-error --silent --location --retry 2 --connect-timeout 15 --max-time 120 --proto '=https' --tlsv1.2 "$golden_rustup_url/rustup-init" --output "$golden_setup_root/downloads/rustup-init"
curl --fail --show-error --silent --location --retry 2 --connect-timeout 15 --max-time 60 --proto '=https' --tlsv1.2 "$golden_rustup_url/rustup-init.sha256" --output "$golden_setup_root/downloads/rustup-init.sha256"
(
  cd "$golden_setup_root/downloads"
  sha256sum --check rustup-init.sha256
)
chmod u+x "$golden_setup_root/downloads/rustup-init"
if [ ! -x "$CARGO_HOME/bin/rustup" ]; then
  "$golden_setup_root/downloads/rustup-init" -y --profile minimal --default-toolchain 1.99.0 --no-modify-path --component rustfmt,clippy
fi
rustup toolchain install 1.99.0 --profile minimal --component rustfmt --component clippy
rustup default 1.99.0
rustc --version
cargo --version

cd "$golden_repo_root/tools/environment-smoke/backend"
cargo build --locked
cd "$golden_repo_root/tools/environment-smoke/frontend"
npm ci --no-audit --no-fund
npm run typecheck
npm run build

git -C "$golden_repo_root" status --short
