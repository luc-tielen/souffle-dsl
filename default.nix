{ compiler ? "ghc884", pkgs ? import ./nix/packages.nix { } }:

with pkgs;

let
  inherit (haskell.lib) dontCheck doJailbreak addBuildTools;
  haskellPackages = haskell.packages.${compiler};
  souffle = callPackage ./nix/souffle.nix {};
  souffle-haskell-src = pkgs.fetchFromGitHub {
    owner = "luc-tielen";
    repo  = "souffle-haskell";
    rev = "7d26105affe8e1ead95033870e954ea352feb573";
    sha256 = "06igl7ws8mchsiy4ba3rfj03yksr19dcr2lmh74mlarwn2mw3m5f";
  };
  haskellPkgs = haskellPackages.override {
    overrides = self: super: {
      neat-interpolation = dontCheck super.neat-interpolation;
      type-errors-pretty = doJailbreak super.type-errors-pretty;
      hspec-hedgehog = self.callCabal2nix "hspec-hedgehog" (builtins.fetchTarball {
        url = "https://github.com/parsonsmatt/hspec-hedgehog/archive/0.0.1.1.tar.gz";
        sha256 = "sha256:1058x99b8sgqywrps36ajkib72d3qym3df1bypyd45vffz71fxb0";
      }) {};
      souffle-haskell = dontCheck (super.callCabal2nix "souffle-haskell" souffle-haskell-src {});
    };
  };
  source = nix-gitignore.gitignoreSource [ ] ./.;
  souffle-dsl = haskellPkgs.callCabal2nix "souffle-dsl" source {};
  drv = addBuildTools souffle-dsl [souffle pkgs.which];
in {
  souffle-dsl = drv;
  souffle-shell = haskellPkgs.shellFor {
    packages = p: [ drv ];
    buildInputs = with haskellPkgs; [
      cabal-install
      hpack
      hlint
      ghcid
    ];
    withHoogle = true;
  };
}
