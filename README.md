# omarchy-yazi

**Yazi flavors for every Omarchy theme.** Change your theme with
`omarchy theme set <theme>` (or the quickshell switcher) and every yazi
window you open matches it — no per-app theming, no stale colors.

Generates a yazi flavor from each Omarchy theme's `colors.toml` palette and
installs a `theme-set` hook so the matching flavor is activated automatically
on every theme change.

## Install

```bash
omarchy plugin add https://github.com/Glen-Sumner/omarchy-yazi.git --enable
```

That's it. The plugin registers a headless shell service which:

1. generates flavors for all your themes into `~/.config/yazi/flavors/omarchy-*.yazi/`
2. points `~/.config/yazi/theme.toml` at the flavor of your current theme
   (your existing `theme.toml` is preserved at `theme.toml.pre-omarchy`)
3. watches the active theme and updates yazi's config whenever you change it

### Manual alternative

Don't want the shell service? `./install.sh` installs just the generator and
does a one-shot sync; re-run it after theme changes.

> Note: Yazi does not live-reload theme changes, so already-open windows keep
> their colors until you relaunch them. Every newly opened window follows the
> active theme automatically.

## How it works

```
omarchy theme set gruvbox
  └─ omarchy-theme-set applies the palette system-wide
       └─ current/theme.name changes
            └─ Yazi Theme Sync service notices
                 ├─ regenerates ~/.config/yazi/flavors/omarchy-gruvbox.yazi/
                 └─ repoints [flavor] dark/light in ~/.config/yazi/theme.toml
```

Both `[flavor] dark` and `light` are pointed at the same generated flavor,
so terminal background detection never picks the wrong palette.

### Palette schema handling

Omarchy themes come in three shapes; the generator understands all of them:

| Schema | Example themes | Notes |
|---|---|---|
| Semantic (`accent`, `muted`, `lighter_background`, …) | catppuccin, tokyo-night, solitude, … | stock Omarchy themes |
| ANSI-only (`color0`–`color15`) | moon-orbit, hinterlands | user-installed git themes |
| Alacritty-only | glory-antic | converted via omarchy's own tool |

Light/dark mode is auto-detected from background luminance when the theme
doesn't declare it.

## Manual use

```bash
omarchy-yazi-flavor              # regenerate + activate current theme's flavor
omarchy-yazi-flavor nord         # same, for one theme
omarchy-yazi-flavor --all        # rebuild every flavor
```

## Uninstall

```bash
./uninstall.sh   # removes hook + generator, restores original theme.toml,
                 # deletes generated omarchy-* flavors
```

## Requirements

- [Omarchy](https://omarchy.org/) (Hyprland-based Arch)
- [yazi](https://yazi-rs.github.io/) file manager

## License

MIT — see [LICENSE](LICENSE).
