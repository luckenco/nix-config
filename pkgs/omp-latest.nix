{
  fetchurl,
  lib,
  stdenvNoCC,
}:

let
  version = "18.13.1";
  buildId = "20261027-005706-0838d2a";
in
stdenvNoCC.mkDerivation {
  pname = "omp-latest";
  inherit version;

  src = fetchurl {
    url = "https://build.stencil.so/d/omp/${buildId}/omp-darwin-arm64";
    hash = "sha256-+cZuhyXPEypt4xsjIZCK4cQ8Zo3hLJHerzaNJcAZR9g=";
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
