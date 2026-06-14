{
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    neovim-src = {
      url = "github:neovim/neovim/v0.12.0";
      flake = false;
    };
  };
  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    neovim-src,
  } @ inputs: let
    system = "x86_64-linux";
    pkgs-stable = nixpkgs.legacyPackages.${system};
    pkgs = nixpkgs-unstable.legacyPackages.${system};
    neovim-stable = pkgs.neovim-unwrapped.overrideAttrs (old: {
      version = "0.12.0";
      src = inputs.neovim-src;
      # Clear the old cmake build cache to avoid stale flags
      cmakeFlags = old.cmakeFlags or [];
    });
    rWithPackages = pkgs.rWrapper.override {
      packages = with pkgs.rPackages; [
        cli
        crayon
        glue
        httpgd
        insight
        jsonlite
        knitr
        languageserver
        lintr
        plotrix
        prettycode
        readxl
        rlang
        rmarkdown
        styler
        tikzDevice
        withr
      ];
    };
    r-nvim = pkgs-stable.vimUtils.buildVimPlugin {
      name = "r-nvim";
      src = pkgs.fetchFromGitHub {
        owner = "R-nvim";
        repo = "r.nvim";
        rev = "v0.99.3";
        hash = "sha256-oQSHHu6filJkAyH94yEvyTVuxA+5MU2dMOEAnsIjJKQ=";
      };
    };
  in {
    homeManagerModules.default = {...}: let
      pkgs-unstable = import inputs.nixpkgs-unstable {
        system = pkgs.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
      pkgs-stable = import inputs.nixpkgs {
        system = pkgs.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
    in {
      programs.neovide = {
        enable = true;
        settings = {
          title_hidden = true;
        };
      };
      programs.neovim = {
        enable = true;
        package = neovim-stable;
        withRuby = false;
        withPython3 = false;
        plugins = with pkgs-unstable.vimPlugins;
          [
            alpha-nvim
            blink-cmp
            conform-nvim
            everforest
            fidget-nvim
            gitsigns-nvim
            lazydev-nvim
            ltex_extra-nvim
            lualine-nvim
            luasnip
            mini-ai
            mini-icons
            mini-pairs
            mini-surround
            neo-tree-nvim
            noice-nvim
            nui-nvim
            nvim-dap
            nvim-dap-python
            nvim-dap-ui
            nvim-lint
            nvim-nio
            nvim-notify
            nvim-treesitter
            nvim-web-devicons
            plenary-nvim
            render-markdown-nvim
            rustaceanvim
            smear-cursor-nvim
            telescope-fzf-native-nvim
            telescope-nvim
            telescope-ui-select-nvim
            todo-comments-nvim
            vimtex
            which-key-nvim
            r-nvim
          ]
          ++ (with pkgs-stable.vimPlugins; [
            cmake-tools-nvim
          ])
          ++ (with pkgs-unstable.vimPlugins.nvim-treesitter-parsers; [
            bash
            c
            cmake
            cpp
            diff
            gitignore
            go
            html
            ini
            lua
            luadoc
            make
            markdown
            markdown_inline
            nix
            python
            query
            r
            regex
            rnoweb
            rust
            toml
            vim
            vimdoc
            yaml
          ]);
        extraPackages = with pkgs-unstable; [
          alejandra
          clang-tools
          eslint_d
          glibc
          lldb
          ltex-ls
          lua-language-server
          nil
          nodejs_22
          prettierd
          ripgrep
          tailwindcss_4
          texlab
          typescript-language-server
          vscode-langservers-extracted
        ];
      };
      home.packages = with pkgs-stable; [
        cargo
        clippy
        cmake
        fd
        fixjson
        gcc
        gnumake
        mupdf
        pandoc
        pstree
        rust-analyzer
        rustc
        rustfmt
        texliveFull
        typescript
        xclip
        xdotool
        (pkgs-unstable.python313.withPackages (ps: [
          ps.debugpy
          ps.pytest
        ]))
        pkgs-unstable.ruff
        pkgs-unstable.basedpyright
        rWithPackages
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
          home.stateVersion = "25.11";
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
        (pkgs.python313.withPackages (ps: [
          ps.debugpy
          ps.pytest
        ]))
      ];
      shellHook = ''

        export NVIM_NIX=1
        echo "Reloading Home Manager..."
        home-manager switch --flake .#ethans
      '';
    };
  };
}
