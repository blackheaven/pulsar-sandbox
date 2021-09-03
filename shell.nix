let
  project = import ./default.nix {};
  pkgs = project.pkgs;
  shell = project.pulsar-sandbox.env;
in shell.overrideAttrs (attrs: { buildInputs = attrs.buildInputs ++ [ pkgs.ghc]; })
