# WezTerm Configuration

GPU-accelerated terminal with Lua-based modular configuration.

## Key Features

- **Performance**: WebGpu GPU acceleration
- **UI**: Gruvbox theme, 92% transparency, custom tab styling
- **Multiplexing**: Tmux-style leader key (`Ctrl+x`)
- **Copy Mode**: Vim-style navigation and text selection

## Configuration Structure

```
wezterm/
├── wezterm.lua          # Main entry point
├── keybinds.lua         # Key bindings (13KB)
├── ui.lua               # Visual theming
├── events.lua           # Event handling
├── utils.lua            # Utility functions
├── os.lua               # Platform detection
└── win.lua              # Windows/WSL settings
```

## Essential Key Bindings

### Leader Key: `Ctrl+x`

```lua
Ctrl+x c               -- New tab
Ctrl+x n/p             -- Next/previous tab
Ctrl+x &               -- Close tab
Ctrl+x |               -- Split horizontal
Ctrl+x -               -- Split vertical
Ctrl+x z               -- Zoom pane
Ctrl+x x               -- Close pane
```

### Copy Mode: `Ctrl+x [`

```lua
h/j/k/l                -- Navigation
w/b/e                  -- Word movement
^/$                    -- Line start/end
v/V                    -- Visual/line selection
y/yy                   -- Copy selection/line
q/Escape               -- Exit
```

### Direct Bindings

```lua
Alt+Tab                -- Tab switching
Alt+h/j/k/l            -- Pane navigation
Alt+Shift+Ctrl+h/j/k/l -- Pane resizing
Ctrl+plus/minus        -- Font size
```

## Core Configuration

### Performance Settings

```lua
-- GPU acceleration
front_end = "WebGpu"
webgpu_power_preference = "HighPerformance"

-- Font optimization
font = "UDEV Gothic 35NFLG"
font_size = 16.0
```

### Visual Theme

```lua
color_scheme = "Gruvbox Dark"
window_background_opacity = 0.92
tab_bar_at_bottom = true
use_fancy_tab_bar = false
```

### Platform Detection

```lua
-- Automatic Windows/macOS configuration switching
local is_windows = utils.is_windows()
local config = {}

if is_windows then
    config.default_domain = "WSL:Ubuntu"
end
```

## Troubleshooting

```bash
# Check GPU support
wezterm ls-fonts --list-system

# Performance debugging
wezterm start --config 'front_end="Software"'

# Reset configuration
mv ~/.config/wezterm ~/.config/wezterm.backup
```

## Maintenance

```bash
# Update WezTerm
brew upgrade wezterm

# Verify configuration
wezterm check
```
