{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    home-manager,
  }: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {
    homeManagerModules.default = {pkgs, ...}: {
      programs.neovim = {
        enable = true;
        plugins = with pkgs.vimPlugins; [
          luasnip
          alpha-nvim
          blink-cmp
          cmake-tools-nvim
          conform-nvim
          everforest
          fidget-nvim
          gitsigns-nvim
          lazydev-nvim
          lualine-nvim
          mini-icons
          mini-pairs
          mini-ai
          mini-nvim
          neo-tree-nvim
          noice-nvim
          nui-nvim
          nvim-autopairs
          nvim-dap
          nvim-dap-lldb
          nvim-dap-go
          nvim-dap-ui
          nvim-lint
          nvim-lspconfig
          nvim-nio
          nvim-notify
          nvim-treesitter
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
        ];
        extraPackages = with pkgs; [
          nil
          clang-tools
          lua-language-server
          texlab
          ltex-ls
          glibc
          lldb
          nodejs_24
          alejandra
          ripgrep
        ];
      };
      home.packages = with pkgs; [
        cargo
        rustc
        rustfmt
        clippy
        rust-analyzer
        python315
        gcc
        cmake
        texliveFull
        mupdf
        xdotool
      ];
      programs.zathura.enable = true;
      xdg.configFile."nvim".source = ./.;
    };

    homeConfigurations."ethans" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs; # reuse the pkgs from let block
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
