{ lib, stdenv, fetchurl, fetchpatch
, autoreconfHook, bison, glm, flex, wrapQtAppsHook, cmake, pkg-config
, freeglut, ghostscriptX, imagemagick, fftw, eigen, libtirpc
, boehmgc, libGLU, libGL, mesa, ncurses, readline, gsl, libsigsegv
, python3, qtbase, qtsvg, boost
, zlib, perl, curl
, texliveSmall, texinfo
, darwin
}:

stdenv.mkDerivation rec {
  version = "2.88";
  pname = "asymptote";

  outputs = [ "out" "man" "info" "doc" "tex" ];

  src = fetchurl {
    url = "mirror://sourceforge/asymptote/${version}/asymptote-${version}.src.tgz";
    hash = "sha256-DecadD+m7pORuH3Sdcs/5M3vUbN6rhSkFoNN0Soq9bs=";
  };

  patches = [
    (fetchpatch {
      # partial fix for macOS XDR/V3D support (LDFLAGS change seems like an unrelated bugfix)
      name = "restore-LDFLAGS-dont-look-for-tirpc-under-MacOS.patch";
      url = "https://github.com/vectorgraphics/asymptote/commit/7e17096b22d18d133d1bc5916b6e32c0cb24ad10.patch";
      hash = "sha256-olCFzqfZwWOAjqlB5lDPXYRHU9i3VQNgoR0cO5TmW98=";
    })
  ];

  nativeBuildInputs = [
    autoreconfHook
    bison
    flex
    bison
    texinfo
    wrapQtAppsHook
    cmake
    pkg-config
    (texliveSmall.withPackages (ps: with ps; [ epsf cm-super ps.texinfo media9 ocgx2 collection-latexextra ]))
  ];

  buildInputs = [
    ghostscriptX imagemagick fftw eigen
    boehmgc ncurses readline gsl libsigsegv
    zlib perl curl qtbase qtsvg boost
    (python3.withPackages (ps: with ps; [ cson numpy pyqt5 ]))
  ] ++ lib.optionals stdenv.isLinux [ libtirpc ];

  propagatedBuildInputs = [
    glm
  ] ++ lib.optionals stdenv.isLinux [
    freeglut libGLU libGL mesa.osmesa
  ] ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
    OpenGL GLUT Cocoa
  ]);

  dontWrapQtApps = true;

  # Do not build $tex/ls-R which will be generated by texlive.combine
  preConfigure = ''
    HOME=$TMP
    substituteInPlace Makefile.in \
      --replace-fail 'install: install-notexhash install-texhash' 'install: install-notexhash install-asy'
    prependToVar configureFlags "--with-latex=$tex/tex/latex" "--with-context=$tex/tex/context/third"
  '';

  # do not use bundled libgc.so
  configureFlags = [ "--enable-gc=system" ]
    # TODO add open_memstream to enable XDR/V3D on Darwin (requires memstream or >=10.13 Apple SDK)
    ++ lib.optional stdenv.isDarwin "--enable-xdr=no";

  env.NIX_CFLAGS_COMPILE = "-I${boehmgc.dev}/include/gc";

  postInstall = ''
    rm "$out"/bin/xasy
    makeQtWrapper "$out"/share/asymptote/GUI/xasy.py "$out"/bin/xasy --prefix PATH : "$out"/bin

    mv "$info"/share/info/asymptote/*.info "$info"/share/info/
    sed -i -e 's|(asymptote/asymptote)|(asymptote)|' "$info"/share/info/asymptote.info
    rmdir "$info"/share/info/asymptote
    rm -f "$info"/share/info/dir

    install -Dt $out/share/emacs/site-lisp/${pname} $out/share/asymptote/*.el
  '';

  dontUseCmakeConfigure = true;

  enableParallelBuilding = true;
  # Missing install depends:
  #   ...-coreutils-9.1/bin/install: cannot stat 'asy-keywords.el': No such file or directory
  #   make: *** [Makefile:272: install-asy] Error 1
  enableParallelInstalling = false;

  meta = with lib; {
    description =  "A tool for programming graphics intended to replace Metapost";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.raskin ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
