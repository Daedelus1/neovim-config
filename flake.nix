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
  } @ inputs: let
    system = "x86_64-linux";
    pkgs-stable = nixpkgs.legacyPackages.${system};
    pkgs = nixpkgs-unstable.legacyPackages.${system};
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
        plugins = with pkgs-unstable.vimPlugins;
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
            r-nvim
          ]
          ++ (with pkgs-stable.vimPlugins; [
            cmake-tools-nvim
          ])
          ++ (with pkgs-unstable.vimPlugins.nvim-treesitter-parsers; [
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
            r
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
        extraPackages = with pkgs-unstable; [
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
      home.packages = with pkgs-stable; [
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
        pandoc
        (pkgs-unstable.rWrapper.override {
          packages = with pkgs-unstable.rPackages; [
            lintr
            languageserver
            styler
            httpgd
            cli
            jsonlite
            glue
            withr
            rlang
            crayon
            prettycode
            plotrix
            tikzDevice
            readxl
            insight
            rmarkdown
            knitr
          ];
        })
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
      ];
      shellHook = ''
        export NVIM_NIX=1
        echo "Reloading Home Manager..."
        home-manager switch --flake .#ethans
      '';
    };
  };
}
