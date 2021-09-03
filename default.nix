{ compiler ? "ghc8106" }:

let
  githubTarball = owner: repo: rev:
    builtins.fetchTarball { url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz"; };

  nixpkgsSrc = commit:
    githubTarball "NixOS" "nixpkgs" commit;

  pkgs = import (nixpkgsSrc "503209808cd613daed238e21e7a18ffcbeacebe3") { inherit config; };

  supernovaSrc = githubTarball "hetchr" "supernova" "351903754a40a0d75d660e7e3336b801608bf3dc";
  
  config = {
    packageOverrides = pkgs: rec {
      haskell = pkgs.haskell // {
        packages = pkgs.haskell.packages // {
          ${compiler} = pkgs.haskell.packages."${compiler}".override {
            overrides = self: super: {
              supernova = pkgs.haskell.lib.dontCheck (pkgs.haskell.lib.doJailbreak (pkgs.haskell.lib.unmarkBroken (super.callCabal2nix "supernova" "${supernovaSrc}/lib" {})));
            };
          };
        };
      };
    };
  };
  
in pkgs.haskell.packages.${compiler}.callPackage ./apache-pulsar.nix { }
