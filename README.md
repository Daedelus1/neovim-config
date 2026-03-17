# Daedelus' Neovim Configuration
## Installation
### NixOS
If you are using NixOS, Home-Manager, and Flakes, add the following flake into `flake.nix`
```nix
inputs = {
  nvim-config = {
    url = "github:Daedelus1/neovim-config";
  };
  ...
};
```
and add the following into your `home.nix`.
```nix
{
  imports = [inputs.nvim-config.homeManagerModules.default];
  ...
}
```
### Windows
If you are on Windows, make sure `fd`, `gcc`, `rustc`, and `ripgrep` are installed, then you can clone the
repo via github to `$User\Appdata\Local\nvim`

### Other OS
If you are on a system with `nix`, you can simply clone the github repository and run `nix-develop`.

## Notes
- If you are tinkering with the config, you can rebuild it with `nix develop --impure`
- To find keymaps, type `<Space>sk` to open a Telescope window.
