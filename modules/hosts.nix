# defines all hosts + users + homes.
# then config their aspects in as many files you want
{
  # espdesign user at framework host.
  den.hosts.x86_64-linux.framework.users.espdesign = { };

  # define an standalone home-manager for espdesign
  # den.homes.x86_64-linux.espdesign = { };

  # be sure to add nix-darwin input for this:
  # den.hosts.aarch64-darwin.apple.users.alice = { };

  # other hosts can also have user espdesign.
  # den.hosts.x86_64-linux.south = {
  #   wsl = { }; # add nixos-wsl input for this.
  #   users.espdesign = { };
  #   users.orca = { };
  # };
}
