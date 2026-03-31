{ den, ... }:
{
  # host aspect
  den.aspects.framework = {
    includes = [
      den.aspects.gnome-desktop
    ];

    # host NixOS configuration
    nixos =
      { pkgs, ... }:
      {
        imports = [ ./_nixos/framework-hardware.nix ];
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;
        environment.systemPackages = [ pkgs.hello ];
      };

    # host provides default home environment for its users
    provides.to-users = {
      homeManager =
        { pkgs, ... }:
        {
          home.packages = [ pkgs.vim ];
        };
      nixos = { pkgs, ... }: { };
    };
  };
}
