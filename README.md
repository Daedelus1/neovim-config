# Daedelus' Neovim Configuration

## Dependencies

Requires `npm` for Pyright. \
Requires `ripgrep` for searches. \
Requires either `gcc` or `clang` for Treesitter.

## Snippets

### General

- Toggle Autocomplete
  - Trigger: `;aut` in `Normal Mode`

---

### Markdown

- Environment Commands
  - Enter Inline Math : `;im`
  - Enter Display Math : `;mm`
- Math (All also available in `Tex` Math Environments)
  - Fraction : `.ff`
  - Limit : `.lim`
  - Definite Integral : `.din`
  - Indefinite Integral : `.ind`
  - Matrix : `.([bBpvV])(%d+)x(%d+)%s`
  - Homogeneous Matrix `.([bBpvV])(%d+)h(%d+)%s`
