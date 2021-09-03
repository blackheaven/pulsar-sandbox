# shell.nix
let
  project = import ./default.nix;
in
  project.shellFor {
    # ALL of these arguments are optional.

    # List of packages from the project you want to work on in
    # the shell (default is all the projects local packages).
    packages = ps: with ps; [
      pulsar-sandbox
    ];

    # Builds a Hoogle documentation index of all dependencies,
    # and provides a "hoogle" command to search the index.
    withHoogle = true;

    # Some common tools can be added with the `tools` argument
    tools = {
      cabal = "3.2.0.0";
    };
    # See overlays/tools.nix for more details

    # Some you may need to get some other way.
    buildInputs = [ (import <nixpkgs> {}).git ];

    # Prevents cabal from choosing alternate plans, so that
    # *all* dependencies are provided by Nix.
    exactDeps = true;
  }
