{
  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };
  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
  }: let
    system = "x86_64-linux";
    # pkgs is now Stable
    pkgs-stable = nixpkgs.legacyPackages.${system};
    # unstable is now the Exception
    pkgs = nixpkgs-unstable.legacyPackages.${system};
    # Build r-nvim using unstable to get the latest bugfixes for the plugin
    r-nvim = pkgs-stable.vimUtils.buildVimPlugin {
      name = "r-nvim";
      src = pkgs.fetchFromGitHub {
        owner = "R-nvim";
        repo = "r.nvim";
        rev = "v0.99.3";
        hash = "sha256-oQSHHu6filJkAyH94yEvyTVuxA+5MU2dMOEAnsIjJKQ=";
      };
    };
    # R with all required packages for IDE features bundled together.
    # This ensures languageserver, lintr, and styler are all on the same R
    # library path that Neovim's LSP/lint/format tools will use.
    rWithPackages = pkgs.rWrapper.override {
      packages = with pkgs.rPackages;
        [
          languageserver # LSP backend (r_language_server)
          lintr # linter (nvim-lint)
          styler # formatter (conform.nvim)
          httpgd # SVG/HTTP plot device used by r.nvim for live plot viewing
        ]
        ++ [pkgs.R];
    };
  in {
    homeManagerModules.default = {pkgs, ...}: {
      programs.neovide = {
        enable = true;
        settings = {
          title_hidden = true;
        };
      };
      programs.neovim = {
        enable = true;
        plugins = with pkgs.vimPlugins;
          [
            luasnip
            alpha-nvim
            blink-cmp
            conform-nvim
            everforest
            fidget-nvim
            gitsigns-nvim
            lazydev-nvim
            lualine-nvim
            mini-icons
            mini-pairs
            mini-ai
            mini-surround
            neo-tree-nvim
            noice-nvim
            nui-nvim
            nvim-dap
            nvim-dap-ui
            nvim-lint
            nvim-nio
            nvim-notify
            nvim-treesitter
            telescope-fzf-native-nvim
            nvim-web-devicons
            plenary-nvim
            render-markdown-nvim
            rustaceanvim
            smear-cursor-nvim
            telescope-ui-select-nvim
            telescope-nvim
            todo-comments-nvim
            vimtex
            which-key-nvim
            ltex_extra-nvim
            r-nvim # R IDE: REPL, plot viewer, object browser, send-to-R
          ]
          ++ (with pkgs-stable.vimPlugins; [
            cmake-tools-nvim
          ])
          ++ (with pkgs.vimPlugins.nvim-treesitter-parsers; [
            bash
            c
            cpp
            make
            cmake
            diff
            gitignore
            go
            html
            ini
            lua
            luadoc
            r # already present — used by r.nvim for syntax/indent
            rnoweb
            regex
            rust
            markdown
            markdown_inline
            nix
            query
            vim
            vimdoc
            yaml
          ]);
        extraPackages = with pkgs; [
          nil
          clang-tools
          lua-language-server
          texlab
          ltex-ls
          glibc
          lldb
          alejandra
          ripgrep
          nodejs_24
        ];
      };
      home.packages = with pkgs; [
        cargo
        rustc
        rustfmt
        clippy
        rust-analyzer
        gcc
        gnumake
        cmake
        texliveFull
        mupdf
        xdotool
        fd
        pstree
        python315
        rWithPackages # R + languageserver + lintr + styler + httpgd
        # httpgd serves plots over HTTP; a browser or image viewer renders them.
        # zathura is already enabled below for PDF plots as fallback.
      ];
      programs.zathura.enable = true;
      xdg.configFile."nvim".source = ./.;
    };

    homeConfigurations."ethans" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        self.homeManagerModules.default
        {
          home.username = "ethans";
          home.homeDirectory = "/home/ethans";
          home.stateVersion = "25.05";
          programs.home-manager.enable = true;
        }
      ];
    };

    devShells.x86_64-linux.default = pkgs.mkShell {
      packages = with pkgs; [
        pkgs.home-manager
        lua-language-server
        nil
        clang-tools
        rust-analyzer
      ];
      shellHook = ''
        export NVIM_NIX=1
        echo "Reloading Home Manager..."
        home-manager switch --flake .#ethans
      '';
    };
  };
}
