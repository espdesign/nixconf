---
name: Den
description: Aspect-oriented, context-driven Dendritic Nix configuration framework
notes: |
  The `den/` folder in this repo is for examples and documentation only.
  Do not use it directly as templates for your own configuration.
  Reference it for patterns, then implement in your own modules.
commands:
  - query: "how to use den"
    response: |
      Den is an aspect-oriented Nix config framework. Key patterns:

      1. **Declare hosts/users/homes** in flake.nix:
         ```nix
         den.hosts.x86_64-linux.laptop.users.alice = {};
         den.homes.x86_64-linux."alice@laptop" = {};
         ```

      2. **Create aspects** (features) in module files:
         ```nix
         den.aspects.workstation = {
           nixos = { pkgs, ... }: { environment.systemPackages = [ pkgs.git ]; };
           darwin = ...;
           homeManager = ...;
           includes = [ den.provides.hostname den.provides.define-user ];
         };
         ```

      3. **Apply aspects** to hosts/users:
         ```nix
         den.hosts.x86_64-linux.laptop.include = [ den.aspects.workstation ];
         ```

      4. **Instantiate** in flake outputs:
         ```nix
         nixosConfigurations.laptop = lib.nixosConfiguration {
           modules = [ (den.lib.aspects.resolve "nixos" (den.ctx.host { host = den.hosts.x86_64-linux.laptop; })) ];
         };
         ```

      **Core concepts:**
      - **Aspects**: Functions taking context ({host}, {host, user}, {home}) returning Nix class configs (nixos, darwin, homeManager, hjem, maid, user, os)
      - **Parametric dispatch**: Functions only run when their required args are satisfied by context
      - **Context pipeline**: host → user → home stages with automatic aspect resolution
      - **Batteries**: Pre-built providers at `den.provides.*` (hostname, define-user, user-shell, forward, etc.)

      **Key source files to consult:**
      - `den/nix/lib/default.nix` - Core library (parametric, canTake, take)
      - `den/modules/` - OS framework (hosts, homes, schema, context wiring)
      - `den/templates/ci/modules/features/` - Every feature as isolated test
      - `den/docs/src/content/docs/` - Full documentation

      **Common patterns:**
      - `den.lib.perHost`, `den.lib.perUser`, `den.lib.perHome` - restrict aspects to context
      - `den._.forward` - create custom Nix classes by forwarding
      - `den.default` - config applied to all hosts/users/homes
      - `den.schema.host/user/home` - extensible metadata per entity type
      - `den.aspects.foo.provides.bar` - sub-aspects for modular config

      **Templates:**
      - `templates/default` - flake-parts + home-manager
      - `templates/minimal` - flakes only
      - `templates/noflake` - no flakes + npins
      - `templates/microvm` - MicroVM guests

      Run examples: `nix run github:vic/den#runnable-microvm` or `nix run github:vic/den`

  - query: "den create custom aspect"
    response: |
      Create an aspect in a module file under `modules/`:
      ```nix
      { den, ... }: {
        den.aspects.my-feature = {
          # Owned configs for each Nix class
          nixos = { pkgs, ... }: { services.foo.enable = true; };
          darwin = { pkgs, ... }: { services.foo.enable = true; };
          homeManager = { pkgs, ... }: { programs.foo.enable = true; };
          
          # Cross-platform (applies to nixos + darwin)
          os = { pkgs, ... }: { environment.systemPackages = [ pkgs.bat ]; };
          
          # User class (forwards to users.users.<name>)
          user = { pkgs, ... }: { packages = [ pkgs.helix ]; };
          
          # Include other aspects/batteries
          includes = [
            den.provides.hostname      # battery
            den.aspects.common        # another aspect
            (den.provides.user-shell "fish")  # parametric battery
          ];
          
          # Sub-aspects (modular pieces)
          provides = {
            editor = {
              homeManager.programs.helix.enable = true;
            };
          };
        };
      }
      ```

      **Parametric aspects** (auto-filtered by context):
      ```nix
      den.aspects.host-specific = { host, user }: {
        nixos = lib.mkIf host.isServer { services.foo.enable = true; };
      };
      ```

      Use `den.lib.perHost`, `den.lib.perUser`, `den.lib.perHome` to restrict scope explicitly.

      **Important: Stage the new module file in git**
      ```console
      git add modules/<new-aspect>.nix
      ```

      Source: `den/templates/ci/modules/features/parametric.nix`

  - query: "den batteries"
    response: |
      Batteries are pre-built providers at `den.provides.*` (also `den._.*`):

      **System batteries:**
      - `den._.define-user` - creates users.users.<name> + home.username/homeDirectory
      - `den._.hostname` - sets networking.hostName from host.hostName
      - `den._.primary-user` - adds wheel group, sets primary user
      - `den._.user-shell "fish"` - sets login shell
      - `den._.mutual-provider` - enables bidirectional host↔user config
      - `den._.tty-autologin "alice"` - enables TTY1 autologin
      - `den._.unfree [ "nvidia-x11" ]` - allows unfree packages
      - `den._.forward` - create custom Nix classes
      - `den._.import-tree` - auto-import directories

      **Usage:**
      ```nix
      den.default = {
        includes = [ den._.define-user den._.hostname ];
      };
      den.aspects.alice.includes = [ (den._.user-shell "fish") ];
      ```

      **Custom classes via forward:**
      ```nix
      myForward = { host, user }: den._.forward {
        each = [ "dev" "gaming" ];
        fromClass = _: "role";
        intoClass = _: host.class;
        intoPath = _: [ "roles" ];
        fromAspect = _: den.aspects.${user.aspect};
      };
      den.ctx.user.includes = [ myForward ];
      ```

      Source: `den/modules/aspects/provides/`

  - query: "den test config"
    response: |
      **Testing/Debugging Den configs:**

      ```console
      # Evaluate any config option (use --raw for strings only)
      nix eval .#nixosConfigurations.<host>.config.<option>

      # Show generated module for an aspect/class (use --json for structured data)
      nix eval .#nixosConfigurations.<host>.config.den.aspects.<aspect>.<class> --json

      # Show all flake outputs
      nix flake show
      ```

      **Note:** Don't use `--raw` for boolean values (will error "cannot coerce boolean to string")

      **Examples:**
      ```console
      # Check if GDM is enabled (boolean - no --raw)
      nix eval .#nixosConfigurations.framework.config.services.gdm.enable

      # View the nixos module for gnome-desktop aspect
      nix eval .#nixosConfigurations.framework.config.den.aspects.gnome-desktop.nixos --json
      ```

   - query: "den git staging"
     response: |
       **New module files must be staged in git** for the flake to pick them up.

       `den` uses `inputs.import-tree ./modules` which reads from the git tree.

       ```console
       # Stage new module files
       git add modules/gnome-desktop.nix
       git add modules/<new-aspect>.nix
       # Or stage all new files
       git add modules/
       ```

       Then test with:
       ```console
       nix flake show
       nix eval .#nixosConfigurations.<host>.config.services.gdm.enable
       ```

   - query: "den add user password"
     response: |
       **User passwords should be added to the user aspect file, not hosts.nix.**

       Example in `modules/espdesign.nix`:
       ```nix
       provides.to-hosts.nixos = { pkgs, ... }: {
         users.users.espdesign.hashedPassword = "...";
       };
       ```

       Use `mkpasswd -m sha-512 <password>` to generate the hash.
