{
  fetchurl,
  lib,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (final: {
  pname = "tsrs";
  version = "0.20.1-ts7.1.0-beta";

  src = fetchurl {
    url = "https://registry.npmjs.org/@tsrs/darwin-arm64/-/darwin-arm64-${final.version}.tgz";
    hash = "sha256-wJJhTCkAsQnGbYD6Kq2j042tLaL5JACwWOOSjK9QB+0=";
  };

  dontConfigure = true;
  dontBuild = true;
  dontFixup = true; # Preserve the signed upstream executable.

  installPhase = ''
    runHook preInstall

    # The native binary resolves its standard library declarations beside itself.
    mkdir -p "$out/lib/tsrs" "$out/bin"
    cp -R . "$out/lib/tsrs/"
    ln -s "$out/lib/tsrs/tsrs" "$out/bin/tsrs"

    runHook postInstall
  '';

  meta = {
    description = "Rust port of the TypeScript compiler and language server";
    homepage = "https://github.com/oxc-project/tsrs";
    license = lib.licenses.asl20;
    mainProgram = "tsrs";
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
