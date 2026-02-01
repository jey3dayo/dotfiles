# WezTerm Configuration

Modern GPU-accelerated terminal emulator with comprehensive Lua-based configuration, designed as a feature-rich alternative to Alacritty.

## ✨ Key Features

- **🎨 Modern UI**: Gruvbox theme with 92% transparency and custom tab styling
- **⚡ Performance**: WebGpu GPU acceleration for smooth rendering
- **🔧 Modular Config**: Lua-based configuration with organized module system
- **🌐 Cross-Platform**: macOS/Windows support with WSL integration
- **⌨️ Tmux-Style**: Leader key system (`Ctrl+x`) for terminal multiplexing
- **📱 Copy Mode**: Vim-style navigation and text selection

## 📈 Performance & Features

| Component      | Technology                      | Benefit                        |
| -------------- | ------------------------------- | ------------------------------ |
| Rendering      | WebGpu GPU acceleration         | Smooth scrolling, low latency  |
| Font           | UDEV Gothic 35NFLG + Nerd Fonts | Crisp text, icon support       |
| Transparency   | 92% opacity                     | Modern glass effect            |
| Tab Management | Custom Lua styling              | Visual feedback, process names |

## 🏗️ Architecture

### Modular Structure

```
wezterm/
├── wezterm.lua          # Main configuration entry point
├── ui.lua               # Visual theming and tab styling
├── keybinds.lua         # Key bindings and input handling
├── utils.lua            # Utility functions and helpers
├── os.lua               # Platform-specific configuration
└── win.lua              # Windows-specific settings (WSL)
```

### Configuration Philosophy

- **Separation of Concerns**: Each module handles specific functionality
- **Platform Detection**: Automatic Windows/macOS configuration switching
- **Utility Functions**: Shared helpers for common operations
- **Extensibility**: Easy to add new features and customizations

## 🎮 Key Bindings

### Leader Key System: `Ctrl+x`

Following tmux-style conventions for familiar workflow.

#### Tab Management

```lua
Ctrl+x c               -- Create new tab
Ctrl+x n               -- Next tab
Ctrl+x p               -- Previous tab
Ctrl+x &               -- Close tab (with confirmation)
```

#### Pane Operations

```lua
Ctrl+x |               -- Split horizontally
Ctrl+x -               -- Split vertically
Ctrl+x z               -- Zoom/unzoom pane
Ctrl+x x               -- Close pane
```

#### Copy Mode: `Ctrl+x [`

Vim-style text selection and navigation.

```lua
h/j/k/l                -- Cursor movement
w/b/e                  -- Word navigation
^/$                    -- Line start/end
f/F <char>             -- Find character
/                      -- Search
v                      -- Visual selection
V                      -- Line selection
y                      -- Copy and exit
yy                     -- Copy line
q/Escape               -- Exit copy mode
```

### Direct Bindings

```lua
Alt+Tab / Alt+Shift+Tab  -- Tab switching
Alt+h/j/k/l             -- Pane navigation
Alt+Shift+Ctrl+h/j/k/l  -- Pane resizing
Ctrl+plus/minus         -- Font size adjustment
Cmd/Ctrl+Click          -- Open links
```

## 🎨 Visual Configuration

### Color Scheme

```lua
color_scheme = "Gruvbox dark, hard (base16)"

-- Custom tab colors
local TAB_BAR_BG = "#222"
local ACTIVE_TAB_BG = "#778AC5"
local NORMAL_TAB_BG = "#191f26"
```

### Typography

```lua
font = wezterm.font_with_fallback({
  "UDEV Gothic 35NFLG",
  "Inconsolata Nerd Font",
  "Noto Color Emoji",
})
font_size = 16.0
```

### Window Settings

```lua
window_background_opacity = 0.92
window_decorations = "RESIZE"
native_macos_fullscreen_mode = true
initial_cols = 180
initial_rows = 50
```

## 🔧 Advanced Features

### Custom Tab Styling

- **Arrow Separators**: Unicode right arrows between tabs
- **Process Names**: Show running command or working directory
- **Hover Effects**: Visual feedback with bold text
- **New Tab Button**: Styled consistently with theme

### GPU Acceleration

```lua
webgpu_preferred_adapter = gpus[1]
front_end = "WebGpu"
-- Fallback: "OpenGL" for compatibility
```

### Platform-Specific Features

#### macOS Integration

- **Native Decorations**: Proper window controls
- **Fullscreen Mode**: True macOS fullscreen support
- **Font Rendering**: Optimized for Retina displays

#### Windows/WSL Support

- **WSL Detection**: Automatic Ubuntu environment setup
- **Path Conversion**: Windows path handling
- **Font Fallbacks**: Consistent rendering across platforms

## 🛠️ Utility Functions

### Path Manipulation

```lua
-- Expand ~ to home directory
convert_home_dir(path)

-- Collapse home directory to ~ for display
abbreviate_home_dir(path)

-- Extract filename from path
basename(path)

-- Combine path conversion with basename
convert_useful_path(path)
```

### Table Operations

```lua
-- Concatenate arrays
array_concat(array1, array2)

-- Deep merge for complex configs
merge_tables(table1, table2)
```

### Font Handling

```lua
-- Create font with fallbacks
font_with_fallback({
  "Primary Font",
  "Fallback Font",
  "Emoji Font",
})
```

## ⚙️ Configuration Options

### Mouse Behavior

```lua
mouse_bindings = {
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "NONE",
    action = wezterm.action.CompleteSelection("ClipboardAndPrimarySelection"),
  },
  {
    event = { Up = { streak = 1, button = "Right" } },
    mods = "NONE",
    action = wezterm.action.CompleteSelection("Clipboard"),
  },
}
```

### Key Tables

```lua
-- Resize mode with timeout
key_tables = {
  resize_pane = {
    { key = "h", action = wezterm.action.AdjustPaneSize({ "Left", 1 }) },
    { key = "l", action = wezterm.action.AdjustPaneSize({ "Right", 1 }) },
    -- ... more resize bindings
  },
}
```

### Performance Tuning

```lua
-- Scrollback and memory
scrollback_lines = 10000

-- Animation settings
animation_fps = 60
max_fps = 60

-- Cursor settings
default_cursor_style = "BlinkingBlock"
cursor_blink_rate = 800
```

## 🔍 Debug & Troubleshooting

### Configuration Debugging

```lua
-- Enable debug logging
wezterm.log_info("Debug message")

-- Check GPU adapter
wezterm.log_info("GPU: " .. tostring(wezterm.gui.enumerate_gpus()[1]))

-- Platform detection
wezterm.log_info("Platform: " .. wezterm.target_triple)
```

### Common Issues

```bash
# Font rendering issues
fc-cache -fv  # Refresh font cache

# GPU acceleration problems
wezterm ls-fonts  # List available fonts
wezterm show-keys # Display key bindings

# Configuration errors
wezterm --config-file /path/to/config.lua
```

### Performance Monitoring

```lua
-- Monitor resource usage
config.front_end = "WebGpu"  -- vs "OpenGL"
config.webgl_power_preference = "HighPerformance"
```

## 📊 Customization Examples

### Theme Variants

```lua
-- Light theme variant
if appearance:find("Light") then
  config.color_scheme = "Gruvbox Light"
  config.window_background_opacity = 0.95
end
```

### Workspace-Specific Settings

```lua
-- Project-specific configurations
wezterm.on("format-window-title", function(tab, pane, tabs, panes, config)
  local cwd = pane.current_working_dir
  if cwd and cwd:find("my-project") then
    return "Project: " .. basename(cwd)
  end
  return "WezTerm"
end)
```

### Custom Commands

```lua
-- Add custom key bindings
config.keys = {
  {
    key = "t",
    mods = "CMD|SHIFT",
    action = wezterm.action.SpawnCommandInNewTab({
      args = { "htop" },
    }),
  },
}
```

## 🔗 Integration Points

### Shell Integration

- **Directory Detection**: Automatic working directory display
- **Process Monitoring**: Show running command in tab title
- **Exit Codes**: Visual feedback for command success/failure

### External Tools

- **Tmux Compatibility**: Leader key system matches tmux workflow
- **Vim Integration**: Copy mode mirrors vim navigation
- **Git Workflow**: Optimized for development tasks

## 📋 Maintenance

### Regular Updates

```bash
# Update WezTerm
brew upgrade wezterm

# Check configuration
wezterm show-config

# Validate key bindings
wezterm show-keys | grep "Ctrl+x"
```

### Configuration Management

```lua
-- Version check
if wezterm.version >= "20240101-000000" then
  -- New feature configuration
end

-- Backwards compatibility
local has_feature = pcall(require, "wezterm.feature")
```

### Backup Strategy

```bash
# Backup configuration
cp -r ~/.config/wezterm ~/.config/wezterm.backup

# Version control
git add wezterm/
git commit -m "Update WezTerm configuration"
```

## 🚀 Use Cases

### Development Workflow

1. **Primary Terminal**: Alternative to Alacritty with more features
2. **Multi-Session**: Tab-based workflow with visual feedback
3. **Cross-Platform**: Consistent experience across systems
4. **Integration**: Seamless with existing dotfiles ecosystem

### Advanced Usage

- **Remote Development**: SSH session management
- **Container Work**: Docker/WSL integration
- **Presentation**: High-DPI display optimization
- **Accessibility**: Customizable visual feedback

---

_Feature-rich terminal alternative optimized for modern development workflows._
