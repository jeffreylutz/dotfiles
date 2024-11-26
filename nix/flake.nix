{
  description = "Top level NixOS Flake";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    # Unstable Packages
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Disko
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # Home Manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Alacritty theme
    alacritty-theme.url = "github:alexghr/alacritty-theme.nix";
    alacritty-theme.inputs.nixpkgs.follows = "nixpkgs";

    # Templ
    templ.url = "github:a-h/templ";
    templ.inputs.nixpkgs.follows = "nixpkgs";

    # Ags
    ags.url = "github:Aylur/ags";
    ags.inputs.nixpkgs.follows = "nixpkgs";

    # Matugen
    matugen.url = "github:InioX/matugen?ref=v2.2.0";
    matugen.inputs.nixpkgs.follows = "nixpkgs";

    # NixVim
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    # Zen browser
    zen-browser.url = "github:MarceColl/zen-browser-flake";
  };

  outputs = {
    self,
    nixpkgs,
    disko,
    home-manager,
    alacritty-theme,
    templ,
    nixpkgs-unstable,
    ags,
    ...
  } @ inputs: let
    inherit (self) outputs;

    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];

    hosts = [
      {name = "itachi";}
      {
        name = "karasu";
        gaps = false;
        monitors = [
          {
            name = "eDP-1";
            dimensions = "preferred";
            position = "0x0";
            scale = 1.566667;
            internal = true;
            framerate = 144;
            transform = 0;
          }
        ];
        cursor = 64;
      }
      {
        name = "chidori";
        gaps = false;
        monitors = [
          {
            name = "eDP-2";
            width = "2560";
            height = "1600";
            dimensions = "2560x1600";
            position = "0x0";
            scale = 1.6;
            framerate = 60;
            internal = true;
            transform = 0;
          }
        ];
        cursor = 64;
      }
      {
        name = "amaterasu";
        gaps = true;
        monitors = [
          {
            name = "desc:IDI Elgato Prom. 0x01348D27";
            dimensions = "1024x600";
            position = "-1024x0";
            scale = 1;
            framerate = 60;
            transform = 0;
          }
          {
            name = "desc:BNQ BenQ RD320UA 49R01325019";
            dimensions = "preferred";
            position = "0x0";
            scale = 2;
            framerate = 60;
            transform = 0;
          }
          {
            name = "desc:Invalid Vendor Codename - RTK J584T05 0x20231127";
            dimensions = "3840x2160";
            position = "auto-right";
            scale = 2;
            framerate = 60;
            transform = 0;
          }
        ];
        cursor = 64;
      }
    ];

    forAllSystems = fn: nixpkgs.lib.genAttrs systems (system: fn {pkgs = import nixpkgs {inherit system;};});
  in {
    overlays = import ./overlays {inherit inputs;};

    formatter = forAllSystems ({pkgs}: pkgs.alejandra);

    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});

    nixosConfigurations = builtins.listToAttrs (map (host: {
        name = host.name;
        value = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
            meta = {
              hostname = host.name;
            };
          };
          system = "x86_64-linux";
          modules = [
            # Modules
            disko.nixosModules.disko
            # System Specific
            ./machines/${host.name}/hardware-configuration.nix
            ./machines/${host.name}/disko-config.nix
            # General
            ./configuration.nix
            # Home Manager
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.jeff = import ./home/home.nix;
              home-manager.extraSpecialArgs = {
                inherit inputs;
                meta = host;
              };
            }
          ];
        };
      })
      hosts);
  };
}
