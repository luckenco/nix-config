{
  fetchurl,
  lib,
  stdenvNoCC,
}:

let
  version = "18.11.1";
  buildId = "20261015-150252-7cc9129";
in
stdenvNoCC.mkDerivation {
  pname = "omp-latest";
  inherit version;

  src = fetchurl {
    url = "https://build.stencil.so/d/omp/${buildId}/omp-darwin-arm64";
    hash = "sha256-vesWJrmdwp2EQUbqeUDTZ+YbEDK3fhx3iAEl83nKLdo=";
  };

  dontUnpack = true;
  # Preserve the signed Bun executable and its embedded payload.
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 "$src" "$out/bin/omp"

    runHook postInstall
  '';

  meta = {
    description = "Oh My Pi coding agent";
    homepage = "https://omp.sh";
    license = lib.licenses.mit;
    mainProgram = "omp";
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
