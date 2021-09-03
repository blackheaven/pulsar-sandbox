{ compiler ? "ghc8106" }:
(import ./default.nix { inherit compiler; }).env
