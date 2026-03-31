{ den, ... }:
{
  # user aspect
  den.aspects.espdesign = {
    includes = [
      den.provides.primary-user
      (den.provides.user-shell "fish")
    ];

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.htop ];
      };

    # user can provide NixOS configurations
    # to any host it is included on
    provides.to-hosts.nixos =
      { pkgs, ... }:
      {
        services.displayManager.autoLogin.enable = true;
        services.displayManager.autoLogin.user = "espdesign";

        users.users.espdesign.hashedPassword = "$6$E/QTD2CFyhTAcsLb$t7tHro/Qp8G2JzWNYeJVWZnEmhvyY8DDPpUcn/hLogYGQuogdRW5Eap9eSPQ/DG/lANAwBfSMUxWVjnCGmSgu1";
      };
  };
}
