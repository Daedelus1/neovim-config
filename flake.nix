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
  }: {
    # The HM module — imported by NixOS or standalone HM
    homeManagerModules.default = {pkgs, ...}: {
      programs.neovim = {
        enable = true;
        plugins = with pkgs.vimPlugins; [
          luasnip
          alpha-nvim
          # battery.nvim
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
          cmake-tools-nvim
        ];

        extraPackages = with pkgs; [
          nil
          clang-tools
          lua-language-server
          texlab
          ltex-ls
          glibc
          gdb
          lldb
          nodejs_24
          alejandra
          ripgrep
          # ... all your LSP servers
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
      ];
      xdg.configFile."nvim".source = ./.; # the repo itself is the config
    };

    # For standalone non-NixOS users
    homeConfigurations."ethans" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
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
  };
}
