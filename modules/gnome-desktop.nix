{
  den,
  lib,
  pkgs,
  ...
}:
{
  den.aspects.gnome-desktop = {
    nixos =
      { pkgs, ... }:
      {
        services.displayManager.gdm.enable = true;
        services.desktopManager.gnome.enable = true;

        environment.systemPackages = with pkgs; [
          gnomeExtensions.appindicator
        ];
      };

    # darwin = { pkgs, ... }: { };

    homeManager =
      { pkgs, config, ... }:
      {
        home.file.".local/share/backgrounds/wallpaper-molly.jpg".source = ./static/wallpaper-molly.jpg;

        # 2. Configure GNOME Settings
        dconf = {
          enable = true;
          settings = {
            "org/gnome/shell" = {
              disable-user-extensions = false;
              # Enable the app indicator extension (tray icons)
              enabled-extensions = [ "appindicatorsupport@rgcjonas.gmail.com" ];
              favorite-apps = [
                "org.gnome.Nautilus.desktop"
                "firefox.desktop"
                "com.mitchellh.ghostty.desktop"
              ];
            };

            "org/gnome/desktop/interface" = {
              show-battery-percentage = true;
              clock-format = "12h";
              color-scheme = "prefer-dark";
            };

            # Set desktop background for dark and light mode
            "org/gnome/desktop/background" = {
              picture-uri = "file://${config.home.homeDirectory}/.local/share/backgrounds/wallpaper-molly.jpg";
              picture-uri-dark = "file://${config.home.homeDirectory}/.local/share/backgrounds/wallpaper-molly.jpg";
            };
          };
        };

      };

    # provides.extensions = {
    #   homeManager =
    #     { pkgs, ... }:
    #     {
    #       home.packages = with pkgs; [
    #         gnomeExtensions.gsconnect
    #       ];
    #     };
    # };
  };
}
