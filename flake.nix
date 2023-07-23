{
  description = "Iosevka Iaso fonts";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }: 

  utils.lib.eachSystem [ "x86_64-linux" ] (system:
    let
    pkgs = import nixpkgs {
          inherit system;
    };

    in {
      packages.default = pkgs.stdenvNoCC.mkDerivation {
        name = "josevka";
        dontUnpack = true;
        buildInputs = with pkgs; [ python311Packages.brotli python311Packages.fonttools ];
        buildPhase = let
          josevka-code = pkgs.iosevka.override {
            privateBuildPlan = builtins.readFile ./build-plans.toml;
            set = "josevka-code";
      }; in 
      ''
      mkdir -p ttf
          for ttf in ${josevka-code}/share/fonts/truetype/*.ttf; do
            cp $ttf .
            echo "processing $ttf"
              name=`basename -s .ttf $ttf`
              pyftsubset \
                $ttf \
                --output-file="$name".woff2 \
                --flavor=woff2 \
                --layout-features=* \
                --no-hinting \
                --desubroutinize \
                --unicodes="U+0000-0170,U+00D7,U+00F7,U+2000-206F,U+2074,U+20AC,U+2122,U+2190-21BB,U+2212,U+2215,U+F8FF,U+FEFF,U+FFFD,U+00E8"
              mv *.ttf ttf
          done
      '';
       installPhase = ''
          mkdir -p $out
          cp *.woff2 $out
          cp ${src/family.css} $out/family.css
        '';
    };
});
} 