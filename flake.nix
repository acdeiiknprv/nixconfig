{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { nixpkgs, home-manager, ... }:
    let
      users = {
        me = {
          name = "Kevin Picard";
          username = "kevinp";
          homeDirectory = "/home/kevinp";
          email = "kevin.picard@planpay.com";
        };
        docker = {
          name = "Docker User";
          username = "root";
          homeDirectory = "/root";
          email = "docker@example.com";
        };
      };
      pkgsForSystem = { system }: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      homeConfigurations = {
        docker = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsForSystem { system = "x86_64-linux"; };
          modules = [
            ./home/default.nix
          ];
          extraSpecialArgs = {
            user = users.docker;
          };
        };
      };
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          pkgs = pkgsForSystem { system = "x86_64-linux"; };
          modules = [
            ./systems/nixos/configuration.nix
            ./systems/common/default.nix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.kevinp = {
                  imports = [
                    ./home/default.nix
                    ./home/graphical.nix
                  ];
                };

                extraSpecialArgs = {
                  user = users.me;
                };
              };
            }
          ];
        };
      };
    };
}
