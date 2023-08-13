{ lib
, stdenv
, fetchFromGitHub
, python3
, texlive
, pdf2svg
}:

stdenv.mkDerivation {
  pname = "inkscape-writetex";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "wanglongqi";
    repo = "WriteTex";
    rev = "bab62e1e85ebd68981c0e79fe525cbcc68fbbbc7";
    sha256 = "XWwkuw+Um/cflRWj0eIgQUxJLrk2DLDmx7K+pMWvIlI=";
  };

  buildInputs = [
    texlive.combined.scheme-basic
    pdf2svg
  ];

  nativeCheckInputs = [
    python3.pkgs.inkex
    python3.pkgs.pytestCheckHook
  ];

  dontBuild = true;

  doCheck = true;

  installPhase = ''
    runHook preInstall

    cd "$src/1.0.x"

    install -Dt "$out/share/inkscape/extensions" *.inx *.py

    runHook postInstall
  '';

  meta = with lib; {
    description = "Inkscape extension which removes all matrix transforms by applying them recursively to shapes";
    homepage = "https://github.com/Klowner/inkscape-applytransforms";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ jtojnar ];
    platforms = platforms.all;
  };
}
