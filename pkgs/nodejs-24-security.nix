{
  fetchurl,
  lib,
  nodejs-slim,
  stdenvNoCC,
}:

let
  npmPatch =
    name:
    lib.findFirst (
      patch: builtins.baseNameOf patch == name
    ) (throw "Missing nixpkgs Node patch: ${name}") nodejs-slim.patches;
in
# Temporary upstream binary until nixpkgs includes the October 2026 security fixes.
stdenvNoCC.mkDerivation (final: {
  pname = "nodejs-slim";
  version = "24.22.1";

  src = fetchurl {
    url = "https://nodejs.org/dist/v${final.version}/node-v${final.version}-darwin-arm64.tar.xz";
    hash = "sha256-ZUunneYVVkfiIyGTK0Xyocy3BZdswzfJuOJ4vrCFpig=";
  };

  # Match nixpkgs' split outputs so nodejs_24 and its consumers use this runtime.
  outputs = [
    "out"
    "npm"
    "corepack"
  ];
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true; # Preserve the signed upstream executable.

  postPatch = ''
    # Retain nixpkgs' npm and sandboxed Darwin node-gyp behavior.
    patch -p3 -d lib/node_modules/npm < ${npmPatch "node-npm-build-npm-package-logic.patch"}
    awk '/^--- a\/deps\/npm\// { found = 1 } found' \
      ${npmPatch "gyp-patches-set-fallback-value-for-CLT-darwin.patch"} \
      | patch -p3 -d lib/node_modules/npm

    # The signed binary cannot embed its eventual Nix prefix; discover headers at runtime.
    substituteInPlace lib/node_modules/npm/node_modules/node-gyp/lib/configure.js \
      --replace-fail 'process.config.variables.use_prefix_to_find_headers' 'true' \
      --replace-fail 'const prefix = process.config.variables.node_prefix' \
        'const prefix = path.resolve(process.execPath, "..", "..")'
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out" "$npm/bin" "$npm/lib/node_modules" "$corepack/bin" "$corepack/lib/node_modules"
    cp -R . "$out/"
    mv "$out/lib/node_modules/npm" "$npm/lib/node_modules/"
    mv "$out/bin/npm" "$out/bin/npx" "$npm/bin/"
    mv "$out/lib/node_modules/corepack" "$corepack/lib/node_modules/"
    mv "$out/bin/corepack" "$corepack/bin/"

    HOST_PATH="$out/bin" patchShebangs --host "$npm" "$corepack"
    install -Dm644 ${nodejs-slim.setupHook} "$out/nix-support/setup-hook"

    runHook postInstall
  '';

  passthru = {
    inherit (nodejs-slim) python;
    interpreterName = "nodejs";
  };

  meta = nodejs-slim.meta // {
    changelog = "https://nodejs.org/en/blog/release/v${final.version}";
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
