{ den, lib, pkgs, ... }:
{
  den.aspects.gnome-desktop = {
    nixos = { pkgs, ... }: {
      services.displayManager.gdm.enable = true;
      services.desktopManager.gnome.enable = true;
    };

    darwin = { pkgs, ... }: { };

    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        gnome.gnome-tweaks
        gnome.gnome-system-monitor
        gnome.adwaita-icon-theme
      ];

      dconf.settings = {
        "/org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = "adwaita-dark";
          icon-theme = "Adwaita";
        };
        "/org/gnome/desktop/peripherals/mouse" = {
          natural-scroll = true;
        };
      };
    };

    provides.extensions = {
      homeManager = { pkgs, ... }: {
        home.packages = with pkgs; [
          gnomeExtensions.gsconnect
        ];
      };
    };
  };
}
