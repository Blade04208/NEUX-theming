{
  description = "NEUX GTK and icon themes";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forEachSystem = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forEachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        rec {
          neux-gtk-theme = pkgs.stdenv.mkDerivation {
            pname = "neux-gtk-theme";
            version = "0.1.0";

            src = ./gtk;

            nativeBuildInputs = [ pkgs.dart-sass ];

            buildPhase = ''
              runHook preBuild

              sass --style=expanded --no-source-map scss/gtk-3.0.scss gtk-3.0/gtk.css
              sass --style=expanded --no-source-map scss/gtk-4.0.scss gtk-4.0/gtk.css

              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall

              mkdir -p $out/share/themes
              cp -r . $out/share/themes/NEUX
              find $out -name '*.scss' -delete

              runHook postInstall
            '';

            meta = {
              description = "NEUX GTK 3/4 theme";
              platforms = pkgs.lib.platforms.linux;
            };
          };

          neux-icon-theme = pkgs.stdenv.mkDerivation {
            pname = "neux-icon-theme";
            version = "0.1.0";

            src = ./icon;

            nativeBuildInputs = [ pkgs.gtk3 ];

            dontBuild = true;

            installPhase = ''
              runHook preInstall

              mkdir -p $out/share/icons
              cp -r . $out/share/icons/NEUX
              gtk-update-icon-cache --quiet --force $out/share/icons/NEUX

              runHook postInstall
            '';

            meta = {
              description = "NEUX icon theme";
              platforms = pkgs.lib.platforms.linux;
            };
          };

          default = neux-gtk-theme;
        }
      );

      overlays.default = final: prev: {
        inherit (self.packages.${final.system}) neux-gtk-theme neux-icon-theme;
      };

      checks = forEachSystem (system: self.packages.${system});
    };
}
